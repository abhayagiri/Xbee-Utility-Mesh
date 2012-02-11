#include <LiquidCrystal.h>
#include "variables.h"

LiquidCrystal lcd(13,8,12,11,10,9); 

/*    Variables for 9 relay pins    */
#define mRelay1 14  // Master relay will be a non-latching
#define mRelay2a 15
#define mRelay2b 16
#define va 2
#define vb 3
#define vc 4
#define OPEN 1
#define CLOSE 0
#define REAL 1
#define TEST 0


/*    Variables for 2 input pins    */

#define psisensor  17 
#define rainsensor 19


/*    Define variables for 4 buttons        */
#define buttonA  5
#define buttonB  6
#define buttonC  7   // Step up function
#define buttonD  A4  // Step dpwn function


/*    Define misc. variables      */
unsigned long TimePasts = 0;
int rainSensorWorking = 1;
int stillRaining;
int rainCycles;
int raining = 0; // 0 means no rain. 1 means raining
unsigned long counter; // for holder a counting variable in mode function
int x;//  for holding cursor settings
int y;//  for holding cursor settings
int r = 9;// user will choose between 1 and 0 while operating - 1 for actual running the program, one for test purposes 
unsigned long delayTime;// hold time variables for "true" or "working"
int currState = 0;
int rain  = 0;
int psi = 0;
int ba; // for reading button a
int bb; // for reading button b
int bc; // for reading button c
int bd; // for reading button d
char vopen [5]  ;             //     variable that will hold which valves are open 
char title [21] ;            //     variable for misc. sentences

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

void intro(){ 
  if (r == REAL || r == TEST){
    //ccs();
  }
  lcd.clear ();
  lcd.setCursor (0,1);
  lcd.print ("Enter Main Menu...");
  delay (1500);
  lcd.clear();
  inWait ();
}

void mode ()
{
  lcd.clear ();
  lcd.setCursor (0,1);
  lcd.print ("Button A: Run Mode");
  readButton();
  lcd.clear ();
  lcd.setCursor (0,1);
  lcd.print ("Button B: Test Mode");
  readButton();
  if ((r == REAL) || (r == TEST)){
    intro();
  }
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

//------------------------------------------------------------------------------------------------------




void closeFunct (){      //    CLOSE FUNCTION
  if(currState == 1 ||currState ==  3 || currState ==  5){
    adjValve (va, CLOSE);
  }
  if(currState == 2){
    adjValve (vc, CLOSE);
    adjValve (va, OPEN);
  }
  if(currState == 4){
    adjValve (vb, CLOSE);
    adjValve (va, OPEN);
    adjValve (vc, OPEN);
  }
  if(currState == 6){
    adjValve (vc, CLOSE);
    adjValve (va, OPEN);
  }
  if(currState == 7){
    adjValve (va, CLOSE);
  }
  if (currState == 0){
    sprintf (title, "All Valves Closed");
    cursorSet();
    delay (2000);
  }
  currState--;
  if (currState <1) {
    currState = 0;
  }
}

void openFunct (){      //    OPEN FUNCTION

  if(currState == 0 || currState ==  2 || currState == 4   || currState == 6    ){
    adjValve (va, OPEN);
  }
  if(currState == 3){
    adjValve (vc, CLOSE);
    adjValve (va, CLOSE);
    adjValve (vb, OPEN);
  }
  if(currState == 1|| currState == 5){
    adjValve (va, CLOSE);
    adjValve (vc, OPEN);
  }
  if (currState == 7){
    sprintf (title, "All Valves Open");
    cursorSet();
    delay (2000);
  }
  currState++;
  if (currState >6) {
    currState = 7;
  }
}

void adjValve (int valve, int action) {
  switch (valve) {
  case va:
    setRelay (HIGH, LOW, HIGH); // these are settings for the master relays 
    if (action == CLOSE)
      sprintf (title, "Closing valve A");
    else
      sprintf (title, "Opening valve A");
    break;
  case vb:
    setRelay (HIGH, HIGH, LOW); // these are settings for the master relays 
    if (action == CLOSE)
      sprintf (title, "Closing valve B");
    else
      sprintf (title, "Opening valve B");
    break;
  case vc:
    setRelay (LOW, LOW, HIGH); // these are settings for the master relays 
    if (action == CLOSE)
      sprintf (title, "Closing valve C");
    else
      sprintf (title, "Opening valve C");
    break;
  default:
    break;
  } 
  cursorSet ();
  if (action == OPEN) {
    digitalWrite (valve, HIGH);
  }
  else {
    digitalWrite (valve, LOW);
  }
  if (r == REAL){
    delayTime = (15000);
  }
  else {
    delayTime = (2000);
  }
  delay (delayTime);
}

void setRelay (int mR1, int mR2a, int mR2b) {
  digitalWrite (mRelay1, mR1);
  digitalWrite (mRelay2a, mR2a);
  digitalWrite (mRelay2b, mR2b);
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

//                         END VALVE CONTROL SECTION

//-----------------------------------------------------------------------------------------------------------------------------------


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



//            END CURSOR SETTING SECTION



void printCurr(){
  valvestate();
  lcd.clear ();
  lcd.setCursor (0,1);
  lcd.print("Valves open: ");
  lcd.print (vopen);
  delay (2000);
  lcd.clear();
}


//-----------------------------------------------------------------------------------------------------------------------------------


//                    MENU ROUTINES

void menu (){
  titleScreen1();
  titleScreen3();  
  titleScreen4();  
  menudelay();
  menu ();
}

void titleScreen1() {
  sprintf (title, "Button A:  Auto Prog");
  cursorSet1();
}

//void titleScreen2() {
//  title = ("Button B: Night Prog");
//  cursorSet1();
//}

void titleScreen3() {  
  sprintf (title, "Button C:  Step Up");
  cursorSet1();
}

void titleScreen4() {
  sprintf (title, "Button D: Step Down");
  cursorSet1();
}


void menudelay(){ 
  readbutt();
  menuOpt();
}

void menuOpt(){
  if (ba==1){                //ba was pressed
    sprintf (title, "Begin Auto Control");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    inWait();
  }
  if (bb==1){                //bb was pressed
    sprintf (title, "Begin Manual Control");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    menu();
  }

  if(bc==1) {                 //bc was pressed
    sprintf (title, "   Stepping Up...");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    openFunct();
    printCurr();
  }
  if(bd==1) {                  //bd was pressed
    sprintf (title, "  Stepping Down...");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    closeFunct();
    printCurr(); 
  } 
}

void loop ()  {  //  lcd.clear ();
  lcd.print ("Program Resetting...");
  mode ();// comment this if you want real mode option
  //intro (); // uncomment this if you want real mode option
}

void readbutt(){
  ba = digitalRead (buttonA);
  bb = digitalRead (buttonB);
  bc = digitalRead (buttonC);
  bd = digitalRead (buttonD);
}


//---------------------------------------------------------------------------------

void ccs(){  
  lcd.clear();
  lcd.setCursor (0,1);
  lcd.print("Initial Setup...");
  if (r==REAL){
    delay (3500);
  }
  else {
    delay (1000);
  }
  lcd.clear();
  lcd.setCursor (0,1);
  lcd.print("Opening Valves...");
  adjValve (va, OPEN);// valves a & c are on the same relay
  adjValve (vc, OPEN);
  adjValve (vb, OPEN);
  currState = 7;  // ensure all valves are open   }
}


//                                 PSI SECTION
void readPSI () {
  psi = map (analogRead(psisensor), 0, 1023, 0, 250);
  if (r == CLOSE) {
    psi = 210; 
  }
}

void readRain (){

  //
  //  if (rainSensorWorking == 1) { // if this is not 1 it signafies there is a short in the rain sensor (see the end of this function)
  //and we would like to disable the
  //    rain = digitalRead (rainsensor);
  //    lcd.print (rain);
  //    delay (1000);
  //    if (rain == 1){   
  //      lcd.clear ();
  //      lcd.setCursor (5,1);
  //      lcd.print ("RAINING");
  //      delay (2000);
  //      raining = 1;
  //    }
  //    else {    
  //      raining = 0;// It isnt raining
  //      rainCycles = 0;
  //    }
  //  }
}
//               TITLE DISPLAY SECTION




void inWait() {
inWaitTop:
  unsigned long divideBy;
  lcd.clear();
  if ((r == REAL) && (raining == 0)){
    delayTime = (3600000);  // 3600000 =  ie. 1 hour
    divideBy = 60000;
  }
  if ((r == TEST) && (raining == 0)) {
    delayTime = (6000);// 1 minute
    divideBy = 1000;
  }
  if ((r == TEST) && (raining == 1)) {
    openFunct();
    delayTime = (10000); //);// ie. 10 seconds
    divideBy = 60000;
  }
  if ((r == REAL) && (raining == 1)) {
    openFunct();
    delayTime = (14400000); //14400000);// ie. 4 hours = 14400000
    divideBy = 60000;
  }
  //  }
  unsigned long startHours = millis();
  while ((millis()-startHours) < delayTime){  
    readPSI();
    lcd.setCursor (0,0);
    lcd.print("Current PSI = ");
    lcd.print(psi);
    valvestate();
    lcd.setCursor (0,1);
    lcd.print ("Valves Open: ");
    lcd.print (vopen);
    lcd.print ("   ");
    delay(1500);
    whileRoutine1();
    TimePasts = ((millis ()-startHours));
    lcd.print (((delayTime-TimePasts)/divideBy));
    whileRoutine2();
    if (getSerialData(rx.str) == 0) {
      parseData (rx.data,rx.str);
//      Serial.println(getDataVal(rx.data,"XB"));
//      Serial.println(getDataVal(rx.data,"QRY"));
//      Serial.println(getDataVal(rx.data,"Q"));
      if (keyExists(rx.data,"PT") == true && keyExists(rx.data, "XB"))
      {
        if (strcmp(getDataVal(rx.data,"PT"), "QRY") == 0 && keyExists(rx.data,"Q") == true)
        {
          if (strcmp(getDataVal(rx.data,"Q"), "LWS") == 0)
          {
            char buf[32];
            sprintf (buf,"V=%s,P=%d", vopen, psi);
            sendSerialData (XBEE, buf);
            Serial.println ();
          }
        }
      }
    }
    if (raining == 1) {
      if ((millis() - startHours) == 14040000) {  // check psi after one hour
        readPSI ();
        if (psi > 190){
          goto inWaitTop;       
        }
        closeFunct();
      }
    }
  }
  if (raining==1) {
    stillRaining = (digitalRead (rainsensor));
    if (stillRaining == 1) {
      rainCycles = rainCycles + 1;
    }
    if (r==1){
      if (rainCycles > 60) {
        rainSensorShorted () ; // There is a short with the rain sensor //
      }
    }
    else {
      if (rainCycles > 2) {
        rainSensorShorted () ; // There is a short with the rain sensor //
      }
    }
  }
  readSensorProg();// read rain and psi sensor and adj valves is psi is falling
  goto inWaitTop;       
}



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void whileRoutine1(){
  if (raining != 1){
    lcd.setCursor (0,2);
    lcd.print ("PSI Reread in "); 
  }
  else{
    lcd.setCursor (0,1);
    lcd.print ("Rain - Wait  "); 

  }
}
void whileRoutine2(){
  if (r == 1) {
    lcd.print (" min");
  }
  else {
    lcd.print (" sec");
  }
  delay (1500);
  readbutt(); 
  menuOpt();
  lcd.setCursor (0,3);
  lcd.print ("B for Auto Override");
  delay (1500);
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
    if (r==1) {
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
    if (psi < 150) {
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















































