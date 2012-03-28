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

    //init psi averageing array
    for(int i=0; i<NUM_PSI_SAMPLES; i++)
        psiValues[i] = 210;

    //close all valves
    lcd.clear(); 
    lcd.home(); 
    lcd.blink();
    lcd.print("Reset valves...");
    adjValve (va, OPEN); 
    adjValve (vb, OPEN); 
    adjValve (vc, OPEN);
    lcd.clear(); 
    lcd.noBlink();

    // for invoking the code in the Memory tab - 
    // usefull for troubleshooting string literal problems
    //  printMemoryProfile();
    //  delay(300000);
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
            sprintf (title, "Manual Mode");
            printInfo ();
        } 
        else if (controlMode == 1) {
            resetAutoMode();
        }
    }

    if (bc==1) {                 //bc was pressed
        if (controlMode == 0 || controlMode == 1) {
            sprintf (title, "Step Up...");
            printInfo ();
            openFunct();
        }
    }

    if (bd==1) {                  //bd was pressed
        if (controlMode == 0 || controlMode == 1) {
            sprintf (title, "Step Down...");
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

void resetAutoMode() {
    controlMode = 0;
    valveWaitTimer = 0;
    sprintf (title, "Auto Mode");
    printInfo ();
}

void resetRelayduino() {
  ba = bb = bc = bd = 0; //reset buttons
  unsigned char countDown = 5;
  
  //reset when countdown expires, unless a button is pressed
  lcd.clear(); lcd.print("Reset in "); lcd.print( countDown );
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
















