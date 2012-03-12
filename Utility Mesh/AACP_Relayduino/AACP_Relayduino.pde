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

    //init psi averageing array
    for(int i=0; i<NUM_PSI_SAMPLES; i++)
        psiValues[i] = 210;

    //close all valves
    lcd.clear(); 
    lcd.home(); 
    lcd.blink();
    lcd.print("Reset valves...");
    adjValve (va, CLOSE); 
    adjValve (vb, CLOSE); 
    adjValve (vc, CLOSE);
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
    if (ba==1) {               //ba was pressed
        if (testing) {
            testing = false;
            sprintf(title, "Testing: off");
            printInfo();
        } 
        else {
            testing = true;
            sprintf(title, "Testing: on");
            printInfo();
        }

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

void updateTime() {
    if (newSecond)
        newSecond = false;

    if (millis() >= nextSecond) {
        nextSecond += 1000;
        currSecond++;
        newSecond = true;
    }  
}
















