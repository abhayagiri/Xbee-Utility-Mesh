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
//                       END OF SETUP

void readbutt(){

  ba = 0;
  bb = 0;
  bc = 0;
  bd = 0;

  if (Serial.peek() == '*') {
    Serial.read ();
    symbol = Serial.read();

    if (symbol == 'A')
      ba = 1;

    if (symbol == 'B')
      bb = 1;

    if (symbol == 'C')
      bc = 1;

    if (symbol == 'D')
      bd = 1;
  }
}


//void readButton (){
//  while (counter < 150000) {
//    //delay (2000);
//    if (Serial.available()) {
//      symbol = Serial.read ();
//      if (symbol == 1){
//        r = REAL;
//      }
//      else  {
//        r = TEST;
//      }
//    }
//    counter++;
//  }
//  counter= 0;
//}

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
  lcd.clear ();
  lcd.print ("Program Resetting...");
  delay (2000);
  // mode ();// comment this when control box goes into field
  // becuase we dont want it to be stuck asking which mose you want
  // if the program is reset for some reson. Comment it again if it comes back to office 
  intro ();// uncomment this when control box goes into field. Comment it again if it comes back to office 

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
  }
  if  (currState == 4 ) // State 4 means valve B is open. Since its output is 1000 watts, we'd like to wait till the psi drops quite a bit 
  {                     // before valves are closed to the State 3, which only has an output of around 350 watts.
    if (psi < 160) {
      closeFunct ();
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








