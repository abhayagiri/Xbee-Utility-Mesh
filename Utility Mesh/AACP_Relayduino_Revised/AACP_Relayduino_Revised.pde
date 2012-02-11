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
  
  //reset buttons
  ba = bb = bc = bd = 0;
  
  //Update LCD and PSI data every X minutes
  if (millis()-lastDataUpdateTime > 60000ul * 5ul) {
    lastDataUpdateTime = millis();

    valvestate();
    sensorCheck();
  }

  updateRatioMode();
  menuOpt();
  txandtr();
  updateLCD();
}

void menuOpt(){
//  readbutt(); //check for button presses on the serial port

    if (ba==1){                //ba was pressed
    ;
  }
  if (bb==1){                //bb was pressed - cycle manual and auto conrtrol modes
    if (controlMode == 0){
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
      controlMode = 0;
      sprintf (title, "Begin Manual Control");
      printInfo ();
    }
  }

  if(bc==1) {                 //bc was pressed
    sprintf (title, "   Stepping Up...");
    printInfo ();
    openFunct();
  }
  if(bd==1) {                  //bd was pressed
    sprintf (title, "  Stepping Down...");
    printInfo ();
    closeFunct();
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
    else if (ratioState == 1 && timePast > (ratioClosedTime + ratioOpenWaitTime)) {
      ratioState = 2;
      adjValve(vc, OPEN);
    }
    else if ( (ratioState == 2 && timePast > (ratioClosedTime + ratioOpenTime)) ||
              ratioState == 3) {
      lastRatioCycleTime = millis();
      adjValve (va, CLOSE);
      adjValve (vb, CLOSE);
      adjValve (vc, CLOSE);
    }

  } 
}















