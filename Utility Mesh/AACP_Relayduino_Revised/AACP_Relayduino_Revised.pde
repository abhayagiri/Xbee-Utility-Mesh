#include <LiquidCrystal.h>
//#include <MemoryTest.h>
//#include <PSTRUtils.h>

#include "variables.h"

LiquidCrystal lcd(15,12,16,17,18,10); 

void setup () {
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

  // for invoking the code in the Memory tab - 
  // usefull for troubleshooting string literal problems
  //  printMemoryProfile();
  //  delay(300000);
}


void loop ()  {  
  
  ba = bb = bc = bd = 0;   //reset buttons
  updateTime();            //keeps track of seconds
  txandtr();               //get serial data and buttons
  
  valvestate();
  sensorCheck();
  updateRatioMode();
  menuOpt();
  updateLCD();
}

void menuOpt() {
  if (ba==1) {               //ba was pressed
    if (controlMode == 2)    //ratio mode reconfiguration
    ratioChangeRequested = 1;
  }
  if (bb==1){                //bb was pressed - cycle manual and auto conrtrol modes
    if (controlMode == 0) {
      controlMode = 1;
      sprintf (title, "Begin Auto Control");
      printInfo ();
    } 
    else if (controlMode == 1) {
      controlMode = 2;
      sprintf (title, "Begin Ratio Mode");
      printInfo ();
    }
    else if (controlMode == 2) {
      //close valves from ratio mode, reset currState
      sprintf(title, "Closing Valves"); printInfo();
      adjValve (va, CLOSE); adjValve (vb, CLOSE); adjValve (vc, CLOSE);
      currState = 0;
      
      controlMode = 0;
      sprintf (title, "Begin Manual Control");
      printInfo ();
    }
  }

  if (bc==1) {                 //bc was pressed
    if (controlMode == 0 || controlMode == 1) {
      sprintf (title, "   Stepping Up...");
      printInfo ();
      openFunct();
    }
  }

  if (bd==1) {                  //bd was pressed
    if (controlMode == 0 || controlMode == 1) {
      sprintf (title, "  Stepping Down...");
      printInfo ();
      closeFunct();
    }
  } 
}

void valvestate(){ 
  if (currState==0) sprintf (vopen, "NONE");
  if (currState==1) sprintf (vopen, "A   ");
  if (currState==2) sprintf (vopen, "C   ");
  if (currState==3) sprintf (vopen, "AC  ");
  if (currState==4) sprintf (vopen, "B   ");
  if (currState==5) sprintf (vopen, "AB  ");
  if (currState==6) sprintf (vopen, "BC  ");
  if (currState==7) sprintf (vopen, "ABC ");
}

void updateRatioMode()
{
  //check for ratio mode
  if (controlMode == 2) {
    unsigned long timePast = millis() - lastRatioCycleTime;

    if (ratioState == 0 && timePast > ratioClosedTime) {
      ratioState = 1;
      adjValve(va, OPEN);
    }
    if (ratioState == 1 && timePast > (ratioClosedTime + ratioOpenWaitTime)) {
      ratioState = 2;
      adjValve(vc, OPEN);
    }
    if ( (ratioState == 2 && timePast > (ratioClosedTime + ratioOpenTime)) ||
              ratioState == 3) {
      adjValve (va, CLOSE); adjValve (vb, CLOSE); adjValve (vc, CLOSE);
      ratioClosedTime = (ratioClosed * ratioUnit) + millis();
      ratioOpenTime = (ratioOpen * ratioUnit) + ratioClosedTime;
      lastRatioCycleTime = millis();
      ratioState = 0;
    }
  } 
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













