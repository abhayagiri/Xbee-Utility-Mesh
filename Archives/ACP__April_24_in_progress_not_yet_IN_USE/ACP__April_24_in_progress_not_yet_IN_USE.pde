#include <LiquidCrystal.h>
#include "variables.h"

LiquidCrystal lcd(13,8,12,11,10,9); 

void setup () {
  Serial.begin (9600);
  //analogReference (DEFAULT);
  lcd.begin (20,4);
  pinMode (mRelay1,OUTPUT);
  pinMode (mRelay2a,OUTPUT);
  pinMode (mRelay2b,OUTPUT);
  pinMode (va, OUTPUT);
  pinMode (vb, OUTPUT);
  pinMode (vc, OUTPUT);
  pinMode (buttonA, INPUT);
  pinMode (buttonB, INPUT);
  pinMode (buttonC, INPUT);
  pinMode (buttonD, INPUT);
}
//                       END OF SETUP

void readbutt(){
  ba = digitalRead (buttonA);
  bb = digitalRead (buttonB);
  bc = digitalRead (buttonC);
  bd = digitalRead (buttonD);
}


void readButton (){
  while (counter < 150000) {
    //delay (2000);
    if (digitalRead (buttonA) == HIGH) {
      r = REAL;
    }
    if (digitalRead (buttonB) == HIGH) {
      r = TEST;
    }
    counter++;
  }
  counter= 0;
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

void printCurr(){
  valvestate();
  lcd.clear ();
  lcd.setCursor (0,1);
  lcd.print("Valves open: ");
  lcd.print (vopen);
  delay (2000);
  lcd.clear();
}

//                         CURSOR SETTING SECTION

void cursorSet (){
  lcd.clear ();
  lcd.setCursor (2,1);
  lcd.print (title);
  delay (2000);
}

void cursorSet1(){
  menudelay();
  lcd.clear();
  lcd.setCursor(0,1);
  lcd.print (title);
  delay (2000);
}

void loop ()  {  //  lcd.clear ();
  lcd.print ("Program Resetting...");
 mode ();// comment this if you want real mode option
  //intro (); // uncomment this if you want real mode option
}

//---------------------------------------------------------------------------------


//                                 PSI SECTION
void readPSI () {
  psi = map (analogRead(psisensor), 0, 1023, 0, 250);
  if (r == TEST) {
    psi = 210; 
  }
}

void readRain (){
    if (rainSensorWorking == 1) { // if this is not 1 it signafies there is a short in the rain sensor (see the end of this function)
  //and we would like to disable the
      rain = digitalRead (rainsensor);
      lcd.print (rain);
      delay (1000);
      if (rain == 1){   
        lcd.clear ();
        lcd.setCursor (5,1);
        lcd.print ("RAINING");
        delay (2000);
        raining = 1;
 
      }
      else {    
       raining = 0;// It isnt raining
        rainCycles = 0;
      }
    }
}


void readSensorProg(){
  //  lcd.clear();      /////      Three lines for tracing 
  //  lcd.print("psi program");
  //  delay (600);
  //  lcd.clear();
  readPSI ();
  if ((psi < 180) && (currState != 4 ) && (currState > 0)) // State 1 means valve ABC is open
  {
    closeFunct ();
    if (r==REAL) {
      delay (1800000); // wait 30 minutes and check psi again
      lcd.clear();
      lcd.print ("Currently in wait");
      lcd.print ("mode to allow stream");
      lcd.print ("to adjust...");
    }
    else {
      delay (2000);
    }
    readSensorProg();
  }
  if  (currState == 4 ) // State 4 means valve B is open. Since its output is 1000 watts, we'd like to wait till the psi drops quite a bit 
  {                     // before valves are closed to the State 3, which only has an output of around 350 watts.
    if (psi < 160) {
      closeFunct ();
      if (r==1) {
        delay (5400000); // wait 90 minutes and check psi again
        lcd.clear();
        lcd.print ("Currently in wait");
        lcd.print ("mode to allow stream");
        lcd.print ("to adjust...");
      }
      else {
        delay (2000);
      }
      readSensorProg();
    }
  }
  if ((psi < 200) && (currState == 1))
  {
    lcd.clear();
    lcd.setCursor (1,0);
    lcd.print ("PSI Still Falling");
    lcd.setCursor (5,1);
    lcd.print ("but");
    lcd.setCursor (0,2);
    lcd.print ("Final Valve is Open.");
    delay (3000);
    lcd.clear();
    lcd.setCursor (1,3);
    lcd.print ("No More Adj..");
    delay (3000);
    inWait();
  }
  readRain ();
}


void rainSensorShorted (){
  for (int i=0; i <= 255; i++){
    rainSensorWorking = 0;
    lcd.clear ();
    lcd.print ("Rain Sensor Shorted");
    lcd.setCursor (0,2);
    lcd.print ("Notify your local XB");
    delay (2500);
    lcd.clear();
    delay (2500);
    lcd.clear();
  }
}

