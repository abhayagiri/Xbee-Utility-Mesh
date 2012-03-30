#include <LiquidCrystal.h>
//#include <MemoryTest.h>
//#include <PSTRUtils.h>

#include "variables.h"

LiquidCrystal lcd(15,12,16,17,18,10); 

void setup () {
    Serial.end(); //in case we are called from resetRelayduino();
    Serial.begin (9600);
    lcd.begin (20,4);
    pinMode (mRelay1,OUTPUT);
    pinMode (mRelay2,OUTPUT);
    pinMode (va, OUTPUT);
    pinMode (vb, OUTPUT);
    pinMode (vc, OUTPUT);
    pinMode (ledA, OUTPUT);
    pinMode (ledB, OUTPUT);
    pinMode (ledC, OUTPUT);

    controlMode = 1; //default to auto mode

    //init psi averageing array
    for(int i=0; i<NUM_PSI_SAMPLES; i++)
        psiValues[i] = 210;

    //close all valves
    lcd.clear(); 
    lcd.home(); 
    lcd.blink();
    lcd.print("Reset valves...");
    setValveState(7);
    
    //send AWK packets
    lcd.clear(); lcd.home();
    lcd.print("Sending AWK packets");
    for (int i=0; i<15; i++) {
      sendSerialAwk(XBEE, "ANY");
      delay(1000);
    }
    Serial.flush(); //clear buffer in case of extra reset pkts
    lcd.clear();
    lcd.noBlink();
    
    nextSecond = 1000;
    timer0_millis = 0;

    // for invoking the code in the Memory tab - 
    // usefull for troubleshooting string literal problems
//    printMemoryProfile(300000);
}


void loop ()  {  

    ba = bb = bc = bd = 0;   //reset buttons
    updateTime();            //keeps track of seconds
    txandtr();               //get serial data and buttons

    valvestate();            //sets the valve state string
    sensorCheck();           //check the psi 
    menuOpt();
    updateLCD();
}

void menuOpt() {
    if (ba==1) {               //ba was pressed - begin reset timer
        resetRelayduino();
    }
    if (bb==1){                //bb was pressed - cycle manual and auto conrtrol modes
        if (controlMode == 0) {
            controlMode = 1;
            snprintf (title, 16, "Manual Mode");
            printInfo ();
        } 
        else if (controlMode == 1) {
            resetAutoMode();
        }
    }

    if (bc==1) {                 //bc was pressed
        if (controlMode == 0 || controlMode == 1) {
            snprintf (title, 16, "Step Up...");
            printInfo ();
            openFunct();
        }
    }

    if (bd==1) {                  //bd was pressed
        if (controlMode == 0 || controlMode == 1) {
            snprintf (title, 16, "Step Down...");
            printInfo ();
            closeFunct();
        }
    } 
}

void valvestate(){ 
    if (currState==0) snprintf (vopen, 16, "NONE");
    if (currState==1) snprintf (vopen, 16, "A   ");
    if (currState==2) snprintf (vopen, 16, "C   ");
    if (currState==3) snprintf (vopen, 16, "AC  ");
    if (currState==4) snprintf (vopen, 16, "B   ");
    if (currState==5) snprintf (vopen, 16, "AB  ");
    if (currState==6) snprintf (vopen, 16, "BC  ");
    if (currState==7) snprintf (vopen, 16, "ABC ");
}

void resetAutoMode() {
    controlMode = 0;
    valveWaitTimer = 0;
    snprintf (title, 16, "Auto Mode");
    printInfo ();
}

void resetRelayduino() {
  ba = bb = bc = bd = 0; //reset buttons
  unsigned char countDown = 5;
  
  //reset when countdown expires, unless a button is pressed
  lcd.clear(); lcd.home(); 
  lcd.print("Reset in "); lcd.print( countDown );
  while ( (!(ba||bb||bc||bd)) && (countDown > 0) ) {
    if (newSecond) {
      lcd.setCursor(0,9); lcd.print(countDown--);
    }
    txandtr(); //see if any buttons get pressed
    updateTime(); // so seconds continue to get counted
  }
  if (!(ba||bb|bc||bd)) setup(); //reset if no buttons were presse
  else nextLCDUpdate = millis(); //otherwise, force LCD update
}

void updateTime() {
    if (newSecond)
        newSecond = false;

    if (millis() >= nextSecond) {
        nextSecond += 1000;
        currSecond++;
        newSecond = true;
    }  
}
















