#include <stdio.h>
#include <string.h>
#include <SPI.h>
#include <Ethernet.h>
#include "variables.h"

//############################################################
// Commonly changed variables kept here instead of variables.h

// set to true if you want to use the Upper Water Shed
#define USE_HydroWatts	false

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
    server.begin();

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
    // battery struct next
    memset(battery.id,'\0',ID_LENGTH);
    battery.status = -9;	// -9 because it is out of range of used values for status
    memset(battery.volts,'\0',ID_LENGTH);
    memset(battery.hourVolts,'\0',ID_LENGTH);
    battery.watts = -9;	// -9 is an impossible value so use it as default
    // and make sure hydro wattage starts at an impossible level
    hydroWatts.watts = -1;
    // set valves open string to "????")
    sprintf(turbine.valves,"????");
    // and psi to impossible number
    turbine.psi = -9;
    
    // Start serial port at 9600 bps, used for getting data from XBee
    Serial.begin(9600);
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
        // an http request ends with a blank line
        boolean currentLineIsBlank = true;
        while (client.connected()) {
            if (client.available()) {
                char c = client.read();
                // if you've gotten to the end of the line (received a newline
                // character) and the line is blank, the http request has ended,
                // so you can send a reply
                if (c == '\n' && currentLineIsBlank) {
                    // send a standard http response header
                    client.println("HTTP/1.1 200 OK");
                    client.println("Content-Type: text/html");
                    client.println();
                    // Page HTML goes here

                    client.println("<html><head><title>Abhayagiri XBee Utility Mesh</title>");
                    client.println("</head><body bgcolor=\"DarkGoldenRod\"><div align=center>");

                    // Battery Info
                    client.print("<table border=1><tr><td><b>Battery</b></td><td><b>");
                    client.print(battery.dmin);
                    client.println(" Minutes Old</b></td></tr>");
                    client.print("<tr><td>Voltage</td><td>");
                    client.print(battery.volts);
                    client.println("V</td></tr>");
                    client.print("<tr><td>Hour Average</td><td>");
                    client.print(battery.hourVolts);
                    client.println("V</td></tr>");
                    client.print("<tr><td>Load</td><td>");
                    client.print(battery.watts);
                    client.println("W</td></tr>");
                    client.print("<tr><td>Status</td><td>");
                    client.print(battery.status);
                    client.println("</td></tr>");
                    client.println("</table><br>");

                    // Turbine Info
                    client.print("<table border=1><tr><td><b>Turbine</b></td><td><b>");
                    client.print(turbine.dmin);
                    client.println(" Minutes Old</b></td></tr>");
                    client.print("<tr><td>Valves Open</td><td>");
                    client.print(turbine.valves);
                    client.println("</td></tr>");
                    client.print("<tr><td>PSI</td><td>");
                    client.print(turbine.psi);
                    client.println("</td></tr>");
                    client.println("</table><br>");

                    // Hydro Inverter Info
                    client.print("<table border=1><tr><td><b>Hydro Inverter</b></td><td><b>");
                    client.print(hydroWatts.dmin);
                    client.println(" Minutes Old</b></td></tr>");
                    client.print("<tr><td>Watts Produced</td><td>");
                    client.print(hydroWatts.watts);
                    client.println("</td></tr>");
                    client.println("</table><br>");

                    // Tank Info
                    // Two Water Tanks
                    client.print("<table border=1><tr><td><b>Two Water Tanks</b></td><td><b>");
                    client.print(tanks[TWT].dmin);
                    client.println(" Minutes Old</b></td></tr>");
                    client.print("<tr><td>Level</td><td>");
                    client.print(tanks[TWT].level);
                    client.println("</td></tr>");
                    client.println("</table><br>");
                    // Four Water Tanks
                    client.print("<table border=1><tr><td><b>Four Water Tanks</b></td><td><b>");
                    client.print(tanks[FWT].dmin);
                    client.println(" Minutes Old</b></td></tr>");
                    client.print("<tr><td>Level</td><td>");
                    client.print(tanks[FWT].level);
                    client.println("</td></tr>");
                    client.println("</table><br>");
                    // Ridge
                    client.print("<table border=1><tr><td><b>Ridge Water Tanks</b></td><td><b>");
                    client.print(tanks[RDG].dmin);
                    client.println(" Minutes Old</b></td></tr>");
                    client.print("<tr><td>Level</td><td>");
                    client.print(tanks[RDG].level);
                    client.println("</td></tr>");
                    client.println("</table><br>");

                    client.println("</div></body></html>");
                    // HTML Ends Here

                    break;
                }
                if (c == '\n') {
                    // you're starting a new line
                    currentLineIsBlank = true;
                } 
                else if (c != '\r') {
                    // you've gotten a character on the current line
                    currentLineIsBlank = false;
                }
            }
        }
        // give the web browser time to receive the data
        delay(1);
        // close the connection:
        client.stop();
    }

    //------------Serial Data-----------//
    if (getSerialData(rx.str) == 0) {
        //Serial.println(rx.str);
        parseData(rx.data,rx.str);
        // Make sure this transmission includes a packet type and
        // XB identification tag
        if (keyExists(rx.data,"PT") && keyExists(rx.data,"XB")) {
            // Check for and save any Tank data
            if (strcmp(getDataVal(rx.data,"PT"),"TNK") == 0) {
                if (strcmp(getDataVal(rx.data,"XB"),"TWT") == 0)
                    saveTankData(&tanks[TWT],rx.data);
                if (strcmp(getDataVal(rx.data,"XB"),"FWT") == 0)
                    saveTankData(&tanks[FWT],rx.data);
                if (strcmp(getDataVal(rx.data,"XB"),"RDG") == 0)
                    saveTankData(&tanks[RDG],rx.data);
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
                if (strcmp(getDataVal(rx.data,"XB"),"UWS") == 0)
                    saveHydroWattsData(&hydroWatts,rx.data);
            }
        }
    }
}











