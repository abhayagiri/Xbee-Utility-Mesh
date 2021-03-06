#include <stdio.h>
#include <stdarg.h>
#include <SPI.h>
#include <Ethernet.h>
#include <Udp.h>
#include <avr/pgmspace.h>
#include "variables.h"

//############################################################
// Commonly changed variables kept here instead of variables.h

// set to true if you want to use the Upper Water Shed
#define USE_HydroWatts	true

//Location Name (XB ID)
#define XBEE    "VST"

//############################################################

// Initialize the Ethernet server library
// with the IP address and port you want to use 
// (port 80 is default for HTTP):
Server server(80);

void setup() {
  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);
  Udp.begin(ntpPort);
  server.begin();

  //setup alert LED
  pinMode(ALERT_LED, OUTPUT);
  digitalWrite(ALERT_LED, LOW);

  /*	Initialize all data to to keep garbage data out of array
   		and to set sane defaults.					*/
  // start with serial receive buffer
  for (int i = 0; i < KEYS_MAX; i++) {
    memset(rx.data[i].key,'\0',ENT_SIZE);
    memset(rx.data[i].val,'\0',ENT_SIZE);
  }
  // tank structs next
  for (int i = 0; i < TANK_NUM; i++) {
    memset(tanks[i].id,'\0',ID_LENGTH);
    tanks[i].level = -9;	// -9 default since it is out of range of
    // possible values for water tank levels
  }
  tanks[TWT].tankCap = 2500;
  tanks[FWT].tankCap = 5000; 
  tanks[RDG].tankCap = 7500; //if the well and one big tank are open

  // battery struct next
  memset(battery.id,'\0',ID_LENGTH);
  battery.status = -9;	// -9 because it is out of range of used values for status
  memset(battery.volts,'\0',ID_LENGTH);
  memset(battery.hourVolts,'\0',ID_LENGTH);
  battery.watts = -9;	// -9 is an impossible value so use it as default
  // and make sure hydro wattage starts at an impossible level
  hydroWatts.watts = -1;
  hydroWatts.kwhToday = -1;
  hydroWatts.kwhYesterday = -1;
  // set valves open string to "????")
  sprintf(turbine.valves,"????");
  // and psi to impossible number
  turbine.psi = -9;

  //initalize alerts
  alerts[0] = &twtAlert;
  alerts[1] = &fwtAlert;
  alerts[2] = &rdgAlert;
  alerts[3] = &battAlert;
  alerts[4] = &psiAlert;

  // Start serial port at 9600 bps, used for getting data from XBee
  Serial.begin(9600);
//  debugPrintln_p(PSTR("Setup finished"));

  //    printMemoryProfile();
  //    delay(300000);
}

void loop() {
  // run unpdate time function
  updateTimer(&timer);

  // calculate change in minutes since data was recieved
  battery.dmin = timePastMinutes(&timer,&(battery.timeStamp));
  turbine.dmin = timePastMinutes(&timer,&(turbine.timeStamp));
  hydroWatts.dmin = timePastMinutes(&timer,&(hydroWatts.timeStamp));
  tanks[TWT].dmin = timePastMinutes(&timer,&(tanks[TWT].timeStamp));
  tanks[FWT].dmin = timePastMinutes(&timer,&(tanks[FWT].timeStamp));
  tanks[RDG].dmin = timePastMinutes(&timer,&(tanks[RDG].timeStamp));

  // listen for incoming clients

  Client client = server.available();
  if (client) {
    while (client.connected()) {
      if (client.available()) {

        char c = '\0';
        char optStr[32] = "";
        boolean gotRequest = true;
        boolean gotOpts = false;

        //check if the connection is an HTTP GET request
        char httpGet[] = "GET ";
        for (int i=0; i<strlen(httpGet); i++)
          if ((c=client.read()) != httpGet[i])
            gotRequest = false;

//        if (gotRequest)
//         debugPrintln_p(PSTR("got request"));
//        else
//          debugPrintln_p(PSTR("not http"));

        if (gotRequest) { //look for options
          while ( (c != '\n') && (c != '?') )
            c = client.read(); //flush characters up to the ?

          if (c == '?') { //found option string - load into optStr
            gotOpts = true;
            int i = 0;
            while ( (c != ' ') && i < 31)
              optStr[i++] = (c = client.read());
            optStr[--i] = '\0'; //kill the trailing space character
//            debugPrint_p(PSTR("Option String: \""));
//            debugPrint(optStr);
//            debugPrintln_p(PSTR("\""));              
            while (c != ' ') //flush remaining option chars
              c = client.read(); 
          }
//          else
//            debugPrintln_p(PSTR("No option string"));
        }    

        while (client.available()) // print out the rest of the request
//          debugPrint((char)client.read());

        //now serve the request  
        if (gotRequest) { 

          if (!timeSet) {

            if (!gotOpts) {//request time from internet, else ask the user
              if (setTimeViaNTP() != 0) //if we don't succeed with the IP method
                printTimeSetPage(client); //do it manually
              else //otherwise, proceed to main page
                printMainPage(client);
            }

            else if (strstr_P(optStr, PSTR("setTime=")) == optStr) { //process time string
              int hour=0, minute=0;
              char *dashLoc = strchr(optStr, '-');

              if (dashLoc != NULL) {
                *dashLoc = '\0'; //set the dash to null, send substrings to atoi()
                hour = atoi(optStr+8);
                minute = atoi(dashLoc+1);
                if (minute < 60 && hour < 24) {
                  timer.hour = hour; 
                  timer.min = minute; 
                  timer.sec = 0;
                  timer.justOverflowed = true;
                  timeSet = true;
                  printRedirect(client);
                }
              }
            }
          }

          else if (webState == WEB_NORMAL && !gotOpts) //normal request
            printMainPage(client);

          else if (webState == WEB_NORMAL && gotOpts) {//handle html buttons            

              boolean foundCommand = false;
            //check for valid option string
            if ((strstr_P(optStr, PSTR("valveOp=")) == optStr)
              && optStr[8]>='0' && optStr[8]<='7' && optStr[9]=='\0')
            {
              webCmdTimer.msgStr = valveSetMsg;
              webCmdTimer.opStr = valveOpStr;
              webCmdTimer.packetStr = valveSetPacket;
              webCmdTimer.stateReq = atoi(&optStr[8]);
              webCmdTimer.timeout = 60;
              webCmdTimer.wrap = true;
              foundCommand = true;
            }
            else if ((strstr_P(optStr, PSTR("modeOp=")) == optStr)
              && (optStr[7]=='0' || optStr[7]=='1') && optStr[8]=='\0') // Auto (1) vs. manual mode at turbine
            {
              webCmdTimer.msgStr = modeSetMsg;
              webCmdTimer.opStr = modeOpStr;
              webCmdTimer.packetStr = modeSetPacket;
              webCmdTimer.stateReq = atoi(&optStr[7]);
              webCmdTimer.timeout = 60;
              webCmdTimer.wrap = true;
              foundCommand = true;
            }
            else if (strcmp_P(optStr, PSTR("pumpOp=on")) == 0) { //unused at present, was intended for ridge pump.
              webCmdTimer.msgStr = pumpStartMsg;
              webCmdTimer.opStr = pumpOpStr;
              webCmdTimer.packetStr = pumpStartPacket;
              webCmdTimer.timeout = 60;
              webCmdTimer.wrap = true;
              foundCommand = true;
            }
            else if (strcmp_P(optStr, PSTR("pumpOp=off")) == 0) {
              webCmdTimer.msgStr = pumpStopMsg;
              webCmdTimer.opStr = pumpOpStr;
              webCmdTimer.packetStr = pumpStopPacket;
              webCmdTimer.timeout = 60;
              webCmdTimer.wrap = true;
              foundCommand = true;
            }
            
            // Following  if statements handle the various ping options; all or selected destination.
            else if (strcmp_P(optStr, PSTR("ping=send")) == 0) {
              webCmdTimer.msgStr = pingMsg;
              webCmdTimer.opStr = pingOpStr;
              webCmdTimer.packetStr = pingPacket;
              webCmdTimer.pongList[0] = '\0';
              webCmdTimer.timeout = 300;
              webCmdTimer.wrap = false;
              foundCommand = true;
            }
            
            else if (strcmp_P(optStr, PSTR("ping=TWT")) == 0) {
              webCmdTimer.msgStr = pingMsg;
              webCmdTimer.opStr = pingOpStr;
              webCmdTimer.packetStr = pingPacketTWT;
              webCmdTimer.pongList[0] = '\0';
              webCmdTimer.timeout = 300;
              webCmdTimer.wrap = false;
              foundCommand = true;
            }
            
                        
            else if (strcmp_P(optStr, PSTR("ping=TRB")) == 0) {
              webCmdTimer.msgStr = pingMsg;
              webCmdTimer.opStr = pingOpStr;
              webCmdTimer.packetStr = pingPacketTRB;
              webCmdTimer.pongList[0] = '\0';
              webCmdTimer.timeout = 300;
              webCmdTimer.wrap = false;
              foundCommand = true;
            }
       
            
            else if (strcmp_P(optStr, PSTR("ping=FWT")) == 0) {
              webCmdTimer.msgStr = pingMsg;
              webCmdTimer.opStr = pingOpStr;
              webCmdTimer.packetStr = pingPacketFWT;
              webCmdTimer.pongList[0] = '\0';
              webCmdTimer.timeout = 300;
              webCmdTimer.wrap = false;
              foundCommand = true;
            }
                 
            else if (strcmp_P(optStr, PSTR("ping=RDG")) == 0) {
              webCmdTimer.msgStr = pingMsg;
              webCmdTimer.opStr = pingOpStr;
              webCmdTimer.packetStr = pingPacketRDG;
              webCmdTimer.pongList[0] = '\0';
              webCmdTimer.timeout = 300;
              webCmdTimer.wrap = false;
              foundCommand = true;
            }
            else if (strcmp_P(optStr, PSTR("ping=SNA")) == 0) {
              webCmdTimer.msgStr = pingMsg;
              webCmdTimer.opStr = pingOpStr;
              webCmdTimer.packetStr = pingPacketSNA;
              webCmdTimer.pongList[0] = '\0';
              webCmdTimer.timeout = 300;
              webCmdTimer.wrap = false;
              foundCommand = true;
            }
            else if (strcmp_P(optStr, PSTR("ping=GTS")) == 0) {
              webCmdTimer.msgStr = pingMsg;
              webCmdTimer.opStr = pingOpStr;
              webCmdTimer.packetStr = pingPacketGTS;
              webCmdTimer.pongList[0] = '\0';
              webCmdTimer.timeout = 300;
              webCmdTimer.wrap = false;
              foundCommand = true;
            }
            
            
            else if ((strstr_P(optStr, PSTR("dismiss=")) == optStr)) {
              // part of the "Alerts" function
              //foundCommand=false here, no timeout required
              
              int i = atoi(&optStr[8])-1;
              if (i>=0 && i<NUM_ALERTS)
                alerts[i]->dismissed=true;
            }

            if (foundCommand) {
              //set timestamp
              webCmdTimer.timeStamp = timer;

              //send command
              prog_char *strPtr = webCmdTimer.packetStr; //we are modifying the pointer during printout - see the PROGMEM functions tab
              while (pgm_read_byte(strPtr) != 0x00) {
                if (pgm_read_byte(strPtr) == '%') {
                  Serial.print(webCmdTimer.stateReq); 
                  strPtr++;
                } 
                else
                  Serial.print(pgm_read_byte(strPtr++));
              }

              webState = WEB_CMD_SENT; //set webState to command sent state
              //send refresh page                                
              printRedirect_p( client,
              webCmdTimer.opStr,
              webCmdTimer.msgStr,
              myUrl,
              PSTR("3"),
              webCmdTimer.wrap);
            }
            else
              printRedirect(client);
          }
          //got options during a webcommand - means abandon ping for now

          else if (webState == WEB_CMD_SENT) {
            if (gotOpts) //kill web command on any request but the main page
              webCmdTimer.timeout = 0;
            //check timer - if ok, resend timeout page; if not, send failure info, reset webState
            if (timePastSeconds(&timer, &(webCmdTimer.timeStamp)) > webCmdTimer.timeout) {
              boolean ping = (webCmdTimer.opStr == pingOpStr ? true : false);
              printRedirect_p( client,
              (ping ? PSTR("Ping Complete") : PSTR("Command Timed Out")),
              (ping ? PSTR("Ping Complete") : PSTR("Command timed out: no response")),
              myUrl,
              PSTR("3"), false);
              webState = WEB_NORMAL;
            }
            else if (webCmdTimer.opStr == pingOpStr) { //handling a ping
              printPingRedirect_p( client,
              webCmdTimer.opStr,
              webCmdTimer.pongList,
              myUrl,
              PSTR("2") );

              prog_char *strPtr = webCmdTimer.packetStr; //we are modifying the pointer during printout - see the PROGMEM functions tab
              while (pgm_read_byte(strPtr) != 0x00)
                Serial.print(pgm_read_byte(strPtr++));
            }
            else {
              printRedirect_p( client,
              webCmdTimer.opStr,
              webCmdTimer.msgStr,
              myUrl,
              PSTR("2"), 
              webCmdTimer.wrap );

              if (webCmdTimer.wrap == true) {//we have not heard from the turbine yes
                prog_char *strPtr = webCmdTimer.packetStr; //we are modifying the pointer during printout - see the PROGMEM functions tab
                while (pgm_read_byte(strPtr) != 0x00) {
                  if (pgm_read_byte(strPtr) == '%') {
                    Serial.print(webCmdTimer.stateReq); 
                    strPtr++;
                  } 
                  else
                    Serial.print(pgm_read_byte(strPtr++));
                }
              }
            }
          }
          else if (webState == WEB_CMD_ACKNOWLEDGED) {
            //send ACK page, reset webState;
            printRedirect_p( client,
            PSTR("Command finished"),
            PSTR("Acknowlement received - command finished."),
            myUrl,
            PSTR("3"),
            false );
            webState = WEB_NORMAL;              
          }

          //close connection when done
          client.stop();

        }//if gotRequest
      } //if client available
    } // while client connected
  } // if client


  //------------Serial Data-----------//
  if (getSerialData(rx.str) == 0) {
    parseData(rx.data,rx.str);
    // Make sure this transmission includes a packet type and
    // XB identification tag
    if (keyExists(rx.data,"PT") && keyExists(rx.data,"XB")) {
      // Check for and save any Tank data
      if (strcmp(getDataVal(rx.data,"PT"),"TNK") == 0) {
        if (strcmp(getDataVal(rx.data,"XB"),"TWT") == 0)
          saveTankData(TWT,rx.data);
        if (strcmp(getDataVal(rx.data,"XB"),"FWT") == 0)
          saveTankData(FWT,rx.data);
        if (strcmp(getDataVal(rx.data,"XB"),"RDG") == 0)
          saveTankData(RDG,rx.data);
      }

      // Check for and save any Turbine data
      if (strcmp(getDataVal(rx.data,"PT"),"TRB") == 0) {
        if (strcmp(getDataVal(rx.data,"XB"),"TRB") == 0) {
          saveTurbineData(&turbine,rx.data);
        }
      }

      // Check for and save any Battery data
      if (strcmp(getDataVal(rx.data,"PT"),"PWR") == 0) {
        if (strcmp(getDataVal(rx.data,"XB"),"SNA") == 0)
        {
          saveBatteryData(&battery,rx.data);
        }    
      }

      // Check for and save any Hydro data
      if (strcmp(getDataVal(rx.data,"PT"),"WTT") == 0) {
        if (strcmp(getDataVal(rx.data,"XB"),"GTS") == 0)
          saveHydroWattsData(&hydroWatts,rx.data);
      }

      // Check for ping request
      if (strcmp(getDataVal(rx.data,"PT"),"PING") == 0 &&
        (!keyExists(rx.data,"DST") || strcmp(getDataVal(rx.data,"DST"),XBEE) == 0)) {
        Serial.print("~XB=");
        Serial.print(XBEE);
        Serial.print(",PT=PONG~");
      }
      // Check for web command awk packets
      if (webState == WEB_CMD_SENT) {

        if (webCmdTimer.opStr == valveOpStr ||
          webCmdTimer.opStr == modeOpStr) {//waiting on valve op?
          if (strcmp(getDataVal(rx.data,"XB"),"TRB") == 0 ) {
            if (strcmp(getDataVal(rx.data,"PT"),"VOP") == 0) {
              webCmdTimer.timeout = 25;
              webCmdTimer.timeStamp = timer;
              webCmdTimer.msgStr = 
                PSTR("Received packet: valve operations in progress");
              webCmdTimer.wrap = false;
            }
            else if (strcmp(getDataVal(rx.data,"PT"),"AWK") == 0)
              webState = WEB_CMD_ACKNOWLEDGED;
          }
        }

        else if (webCmdTimer.opStr == pumpOpStr) {
          if (strcmp(getDataVal(rx.data,"XB"),"RDG") == 0 ) 
            if (strcmp(getDataVal(rx.data,"PT"),"AWK") == 0) 
              webState = WEB_CMD_ACKNOWLEDGED;
        }

        else if (webCmdTimer.opStr == pingOpStr) {
          //Serial.println("in code");
          if (strcmp(getDataVal(rx.data, "PT"), "PONG") == 0) {
            //Serial.println("caught pong");
            char *pongList = webCmdTimer.pongList;

            //if we havent heard this pong yet
            if (strstr(pongList, getDataVal(rx.data, "XB")) == NULL) {
              int len = strlen(pongList);
              if (len > 0 && len < 30) { //add space
                pongList[len] = ' ';
                pongList[len+1] = '\0';
              }
              strlcat(pongList, getDataVal(rx.data, "XB"), 32);
            }
          }
        }
      }
    }
  }

  //check alerts and handle LED
  if (timer.justOverflowed) {
    boolean alertsActive = false;
    for (int i=0; i<NUM_ALERTS; i++) {
      if (alerts[i]->active && !(alerts[i]->dismissed))
        alertsActive = true;
    }

    if (alertsActive)
      if (ledOn) {
        digitalWrite(ALERT_LED, LOW); 
        ledOn = false;
      } 
      else {
        digitalWrite(ALERT_LED, HIGH); 
        ledOn = true;
      }
    else 
      digitalWrite(ALERT_LED, LOW);
  }

  //get time from NTP every so often - internal clock is junk
  if (timer.justOverflowed &&
    timer.sec == 0 ) {
    setTimeViaNTP();
    
    //send time packet
    Serial.print("~XB="); 
    Serial.print(XBEE);
    Serial.print(",PT=TOD,H="); 
    Serial.print(timer.hour);
    Serial.print(",M="); 
    Serial.print(timer.min);
    Serial.print("~");
  }

}
















