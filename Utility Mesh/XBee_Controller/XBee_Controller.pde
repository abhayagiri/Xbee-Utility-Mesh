
//#include <stdio.h>
//#include <string.h>
#include <LiquidCrystal.h>
//#include <avr/pgmspace.h>
#include "variables.h"

//############################################################
// Commonly changed variables kept here instead of variables.h

// set to true if you want to use the Upper Water Shed
#define USE_HydroWatts	true

//Location Name (XB ID)
#define XBEE    "MUB"

// LED Pins for Roamer
//#define    LED_1    A3
//#define    LED_2    A4
//#define    LED_3    A5
// LED Pins for MUB
#define    LED_1    10
#define    LED_2    11
#define    LED_3    12

#define   BACKLIGHTL_PIN    8

// Roamer (LilyPad) Controller
//LiquidCrystal lcd(7,6,5,4,3,2);
// MUB (Duemilanove) Controller
LiquidCrystal lcd(2,3,4,5,6,7);

//############################################################

void setup() {
  // LED pins
  pinMode(LED_1,OUTPUT);
  pinMode(LED_2,OUTPUT);
  pinMode(LED_3,OUTPUT);


  // Using pin 13 to power backlight of LCD (and other things) so must be high
  pinMode(13,OUTPUT);
  digitalWrite(13,HIGH);

  //MUB controller backlight on pin 9, so it can be toggled
  pinMode(BACKLIGHTL_PIN,OUTPUT);
  digitalWrite(BACKLIGHTL_PIN,HIGH);

  // Startup LCD screen for display
  lcd.begin(16, 2);

  /*	Initialize all data to to keep garbage data out of array
   		and to set sane defaults.					*/
  // start with serial receive buffer
  for (int i = 0; i < KEYS_MAX; i++) {
    memset(rx.data[i].key,'\0',ENT_SIZE);
    memset(rx.data[i].val,'\0',ENT_SIZE);
  }
  // tank structs next
  strcpy(tanks[FWT].id, "FWT");
  strcpy(tanks[TWT].id, "TWT");
  strcpy(tanks[RDG].id, "RDG");
  for (int i = 0; i < TANK_NUM; i++)
    tanks[i].level = -9;	// -9 default since it is out of range of

  // battery struct next
  memset(battery.id,'\0',ID_LENGTH);
  battery.status = -9;	// -9 because it is out of range of used values for status
  sprintf(battery.volts, "0.00");
  sprintf(battery.hourVolts, "0.00");
  battery.watts = -9;	// -9 is an impossible value so use it as default
  // and make sure hydro wattage starts at an impossible level
  hydroWatts.watts = -1;
  hydroWatts.kwhToday = -1;
  hydroWatts.kwhYesterday = -1;
  // set valves open string to "????")
  sprintf(turbine.valves,"????");
  // and psi to impossible number
  turbine.psi = -9;
  turbine.mode = -9;
  //initalize valveOp data
  memset(valveOp.id,'\0',ID_LENGTH);
  memset(valveOp.op,'\0',6);

  // Make sure lcd prints on startup
  config.dispChanged = true;   

  // Start serial port at 9600 bps, used for getting data from XBee
  Serial.begin(9600);
  
  //printMemoryProfile();
  //delay(300000);
}

void loop() {

  updateTimer(&timer);

//--------------------------------------------
// Button stuff
//--------------------------------------------

  // Read buttons and act based on their states, save last button states too
  // stuff typically happens on the button-up, this allows us to use long
  // button presses as special functions, eg. ping mode and backlight control
  buttonLast = button;
  readButtons(&button);

  //handle backlight oy, veh! - any button press change should turn on BL
  if ( !blightPersistMode && (  //only set backlightTimer if we were not in persist mode on the button press
       (!buttonLast.a1 && button.a1) || (!buttonLast.a2 && button.a2) || 
       (!buttonLast.b1 && button.b1) || (!buttonLast.b2 && button.b2) || 
       ((buttonLast.b1 || buttonLast.b2)&&(!button.b1 && !button.b2))) &&
       buttonTimer < 5000) {
    backlightTimer = BACKLIGHT_TIME;
    digitalWrite(BACKLIGHTL_PIN, HIGH);
  } 

  // Change display modes based on button states
  setDisplayMode(&config,&button,&buttonLast,DISPLAY_MODES);

//  // Turbine setting for buttons
//  //send valve control packet if we are not already processing one
//  if (config.displayMode == 1 && 
//     ((buttonLast.a1 && !button.a1) || (buttonLast.a2 && !button.a2)) && 
//     valveCommandState == 0 && buttonTimer < 5000) {
//      sendButtons(&config, &button, &buttonLast, XBEE, "TRB");
//      buttonLast.a1 ? valveCommandState=1 : valveCommandState=3; //set valve command state
//  }

  // Turbine setting for buttons
  //send valve control packet if we are not already processing one
  if (config.displayMode == 1 && 
     ((buttonLast.a1 && !button.a1) || (buttonLast.a2 && !button.a2)) && 
      buttonTimer < 5000) {
      turbineMenuButtonHandler(&button, &buttonLast);
  }

  //Engage ping mode?
  if (!pingMode && config.displayMode == 0 && buttonTimer > 10000 && button.a1) {
    pingMode = true;
  }
  
  //backlight persist mode on?           
  if (buttonTimer > 10000 && buttonTimer < 10100 && button.a2) { 
    //got long a2 press - toggle the bl mode
    if (blightPersistMode) {
      blightPersistMode = false;
      digitalWrite(BACKLIGHTL_PIN, LOW);
    } else {
      blightPersistMode = true;
      
      int i = 3; //blink 3x
      while(i-->0) {
          delay(50); digitalWrite(BACKLIGHTL_PIN, LOW);
          delay(50); digitalWrite(BACKLIGHTL_PIN, HIGH);
      } 
    }
    buttonTimer = 11000; //avoids double-tripping the if()
  }

//-------------------------------------------------------
// Done with button stuff - except timer at very bottom!
//-------------------------------------------------------

  // Set hydro program error flag
  if (hydroWatts.watts < WATTS_ERROR_LEVEL && hydroWatts.watts >= 0)
    hydroError = true;
  else {
    hydroError = false;
  }

  //----------STATUS LED------------//
  // Upper Hydro Shed Watt production checking
  // LED will signal error if it drops below 300 watts
  if (hydroError)
    hydroErrorLED(hydroWatts.watts);
  // Otherwise just show the same status as Sauna LEDs
  else
    updateStatusLED(battery.status, &timer);

  //----------LCD SCREEN-----------//
  // reprint LCD every 2 many seconds
  if (hydroError && !config.pauseCounter) {
    if (timer.justOverflowed) {
      lcd.clear();
      lcd.setCursor(0,0);
      if (timer.sec%2)
        lcd.print("   EMERGENCY");
      else
        lcd.print("TURBINE FAILURE");
    }
  }
  else if ((config.dispChanged || (timer.sec%30 == 0 && timer.justOverflowed)) && !config.pauseCounter ) {
    config.dispChanged = false; //reset flag
    updateDisplay(&config, &timer, &turbine, &hydroWatts, &battery, tanks);

  }

  
  if (trbCmd.cmdState >= Sending && config.displayMode == 1) { //deal with valve command stuff
    if (timer.justOverflowed) {//per-second ops
      config.pauseCounter = 2;
      
      //Update display
      lcd.clear(); 
      switch (trbCmd.cmdState) {
        case Sending: 
          lcd.print("Sending"); 
          break;
        case OpsInProg: 
          lcd.print("Op in progress"); 
          valveCommandTimer += 25; //add valve op time
          break;
        case AwkRcvd: 
          lcd.print("Cmd complete"); 
          trbCmd.cmdState = NotSending;
          trbCmd.currField = 0;
          config.pauseCounter = 5;
          break;
      } lcd.blink();
      
      //send packets until some response recv'd or timer exp.
      if (trbCmd.cmdState == Sending && (timer.sec % 2) == 0)
        sendTurbineCommand();
      
      //decrement, test timer
      if (--valveCommandTimer == 0) { 
        lcd.clear(); lcd.print("Cmd Timeout");
        trbCmd.cmdState = NotSending;
        trbCmd.currField = 0; //so cursor is not on "send"
      }
    }//per-second ops
  }

  //handle ping mode
  if (pingMode) {
    char line1[17] = "";
    char line2[17] = "";
    char idTmp[5] = "";
    char *currLine;
    short numPongs = 0;

    config.pauseCounter = 2; //keeps displaay from being overwriten during ping mode
    updateProgressIndicator();

    for ( int i=0; i<numPongTimers; i++ ) {
      if (i <= 3)
        currLine = line1;
      else
        currLine = line2;

      memset(idTmp, ' ', ID_LENGTH); //set string to blanks
      if (pongTimers[i].heardFrom){ //only put the string in if we have herad from them since the ping started
        strlcpy(idTmp, pongTimers[i].id, ID_LENGTH);
      }
      idTmp[3] = ' '; idTmp[4] = '\0';
      if ( loopMillis > pongTimers[i].staleTime ) //uppercase if we heard from them recently
        for (int j=0; j<strlen(idTmp); j++)
          idTmp[j] = tolower(idTmp[j]);
      strlcat(currLine, idTmp, 16);
    }

    appendToEnd(line2, progressor, 16); //progress indicator at end

    if ( strcmp(line1, pongLine1) || strcmp(line2, pongLine2)) {  
      print2lines(line1,line2);
      strlcpy(pongLine1, line1, 17);
      strlcpy(pongLine2, line2, 17);
    }

    if (timer.justOverflowed) {
      if (timer.sec % 2 == 0) { //send ping every X sec
        Serial.print("~XB=");
        Serial.print(XBEE);
        Serial.print(",PT=PING~");
      }
    }

    if ( button.b1 || button.b2 || //either latching button will cancel
        ((buttonLast.a1 && !button.a1) || (buttonLast.a2 && !button.a2)) &&
        buttonTimer < 5000 ) { //either rocker state cancels on button-up
      for (int i=0; i<numPongTimers; i++) //reset all pong timers
        pongTimers[i].heardFrom = false;
      config.pauseCounter = 0; //allow display to be handled normally again
      config.dispChanged = true;
      
      pingMode = false;
    }
  }



  //------------Serial Data-----------//
  if (!getSerialData(rx.str)) {
    parseData(rx.data,rx.str);
    // Make sure this transmission includes a packet type and
    // XB identification tag
    if (keyExists(rx.data,"PT") && keyExists(rx.data,"XB")) {
      // Deal with valve op packets
      if (strcmp(getDataVal(rx.data,"XB"),"TRB") == 0 && 
        (strcmp(getDataVal(rx.data,"PT"),"VOP") == 0) || (strcmp(getDataVal(rx.data,"PT"),"AWK") == 0))
        handleValveOpPacket(rx.data); 

      if ( pingMode && strcmp(getDataVal(rx.data,"PT"),"PONG") == 0)
        handlePongPacket(rx.data);

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
          saveBatteryData(&battery,rx.data);
      }

      // Check for and save any Hydro data
      if (strcmp(getDataVal(rx.data,"PT"),"WTT") == 0) {
        if (strcmp(getDataVal(rx.data,"XB"),"GTS") == 0)
          saveHydroWattsData(&hydroWatts,rx.data);
      }

      config.dispChanged = true; //update screen when new data arrives
    }
  }

  // count down until menu unpauses after command send or awknowledged
  if (config.pauseCounter && timer.justOverflowed) {
    config.pauseCounter--;
  }

  //backlight auto-off
  if (timer.justOverflowed) {
    if (backlightTimer > 0 && !pingMode && !config.pauseCounter)
      --backlightTimer;
    else if (backlightTimer <= 0 && !blightPersistMode)
      digitalWrite(BACKLIGHTL_PIN,LOW);
  }
  
  //update timer for detecting long button presses
  if ((buttonLast.a1 && button.a1) || (buttonLast.a2 && button.a2))
      buttonTimer += 1;
  else
      buttonTimer = 0;
}

void updateElipsis() {
  if (timer.justOverflowed) {
    if (strcmp(elipsis, "   ") == 0)
      sprintf(elipsis, ".  ");
    else if (strcmp(elipsis, ".  ") == 0)
      sprintf(elipsis, ".. ");
    else if (strcmp(elipsis, ".. ") == 0)
      sprintf(elipsis, "...");
    else if (strcmp(elipsis, "...") == 0)
      sprintf(elipsis, "   ");
  }
}

void updateProgressIndicator() {
  if (loopMillis > 10000 + progressTimer)
    progressTimer = loopMillis;
  if (loopMillis > progressTimer) {
    progressIndex += 1;
    progressTimer += 1000;
    if (progressIndex >= progStrLength)
      progressIndex = 0;
    progressor = progStr[progressIndex];
  }
}

