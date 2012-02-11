#include <LiquidCrystal.h>
LiquidCrystal lcd(13,8,12,11,10,9); 

/*    Variables for 9 relay pins    */
int mRelay1 = 14; // Master relay will be a non-latching
int mRelay2a = 15;
int mRelay2b = 16;
int va = 2;
int vb = 3;
int vc = 4;


/*    Variables for 2 input pins    */

int psisensor = A5; 
int rainsensor = A3;


/*    Define variables for 4 buttons        */
int buttonA = 5;
int buttonB = 6;
int buttonC = 7; // Step up function
int buttonD = A4; // Step dpwn function


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
int valve = 0;
int action = 9;
int rain  = 0;
int psi = 0;
int ba; // for reading button a
int bb; // for reading button b
int bc; // for reading button c
int bd; // for reading button d
char* vopen="";             //     variable that will hold which valves are open 
char* title="";            //     variable for misc. sentences

void setup () {
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
  //  lcd.clear ();
  //  lcd.print ("Program Resetting...");
  //  delay (1000);
  mode ();// comment this if you want real mode option
  //intro (); // uncomment this if you want real mode option
}
//                       END OF SETUP

void intro(){ 
  ccs();
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
  if ((r == 1) || (r == 0)){
    intro();
  }
  mode ();
}

void readButton (){
  while (counter < 150000) {
    //delay (2000);
    if (digitalRead (buttonA) == HIGH) {
      r = 1;
    }
    if (digitalRead (buttonB) == HIGH) {
      r = 0;
    }
    counter++;
  }
  counter= 0;
}

//------------------------------------------------------------------------------------------------------




void closeFunct (){      //    CLOSE FUNCTION
  if(currState == 1 ||currState ==  3 || currState ==  5){
    closevalvea ();
  }
  if(currState == 2){
    closevalvec ();
    openvalvea ();
  }
  if(currState == 4){
    closevalveb ();
    openvalvea ();
    openvalvec ();
  }
  if(currState == 6){
    closevalvec ();
    openvalvea ();
  }
  if(currState == 7){
    closevalvea ();
  }
  if (currState == 0){
    title = ("All Valves Closed");
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
    openvalvea ();
  }
  if(currState == 3){
    closevalvec ();
    closevalvea ();
    openvalveb ();
  }
  if(currState == 1|| currState == 5){
    closevalvea ();
    openvalvec ();
  }
  if (currState == 7){
    title = ("All Valves Open");
    cursorSet();
    delay (2000);
  }
  currState++;
  if (currState >6) {
    currState = 7;
  }
}

void adjValve () {
  if (action == 1) {
    digitalWrite (valve, HIGH);
  }
  else {
    digitalWrite (valve, LOW);
  }
  if (r == 1){
    delayTime = (15000);
  }
  else {
    delayTime = (2000);
  }
  delay (delayTime);
}


void closevalvea (){

  title = ("Closing valve A");
  cursorSet ();
  oneEach();
  action = 0;
  valve = va;
  adjValve ();
}

void closevalveb (){

  title = ("Closing valve B");
  cursorSet ();
  bothHigh ();
  action = 0;
  valve = vb;
  adjValve ();
}

void closevalvec (){

  title = ("Closing valve C");
  cursorSet ();
  bothLow();
  action = 0;
  valve = vc;
  adjValve ();
}

void openvalvea (){

  title = ("Opening valve A");
  cursorSet ();
  oneEach();
  action = 1;
  valve = va;
  adjValve();
}

void openvalveb (){

  title = ("Opening valve B");
  cursorSet ();
  bothHigh();
  action = 1;
  valve = vb;
  adjValve();
}

void openvalvec (){
  title = ("Opening valve C");
  cursorSet ();
  bothLow();
  action = 1;
  valve = vc;
  adjValve();
}

void bothHigh(){
  digitalWrite (mRelay1, HIGH);
  digitalWrite (mRelay2a, HIGH);
  digitalWrite (mRelay2b, LOW);
}

void bothLow(){
  digitalWrite (mRelay1, LOW);
  digitalWrite (mRelay2a, LOW);
  digitalWrite (mRelay2b, HIGH);
}
void oneEach(){
  digitalWrite (mRelay1, HIGH);
  digitalWrite (mRelay2a, LOW);
  digitalWrite (mRelay2b, HIGH);
}


void valvestate(){ 
  if (currState==0) vopen = "NONE";
  if (currState==1) vopen = "A   ";
  if (currState==2) vopen = "C   ";
  if (currState==3) vopen = "AC  ";
  if (currState==4) vopen = "B   ";
  if (currState==5) vopen = "AB  ";
  if (currState==6) vopen = "BC  ";
  if (currState==7) vopen = "ABC ";


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
  title = ("Button A:  Auto Prog");
  cursorSet1();
}

//void titleScreen2() {
//  title = ("Button B:  Man. Prog");
//  cursorSet1();
//}

void titleScreen3() {  
  title = ("Button C:  Step Up");
  cursorSet1();
}

void titleScreen4() {
  title = ("Button D: Step Down");
  cursorSet1();
}


void menudelay(){ 
  readbutt();
  menuOpt();
}

void menuOpt(){
  if (ba==1){                //ba was pressed
    title = ("Begin Auto Control");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    inWait();
  }
  if (bb==1){                //bb was pressed
    title = ("Begin Manual Control");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    menu();
  }

  if(bc==1) {                 //bc was pressed
    title = ("   Stepping Up...");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    openFunct();
    printCurr();
    title = ("");
  }
  if(bd==1) {                  //bd was pressed
    title = ("  Stepping Down...");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    closeFunct();
    printCurr(); 
    title = ("");
  } 
}

void loop ()  {
  //  menu(); I dont think loop is ever actually used
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
  if (r==1){
    delay (3500);
  }
  else {
    delay (2000);
  }
  lcd.clear();
  lcd.setCursor (0,1);
  lcd.print("Opening Valves...");
  openvalvea ();// valves a & c are on the same relay
  openvalvec ();
  openvalveb ();
  currState = 7;  // ensure all valves are open   }
}


//                                 PSI SECTION
void readPSI () {
  psi = map (analogRead(psisensor), 0, 1023, 0, 250);
  if (r == 0) {
    psi = 210; 
  }
}

void readRain (){
  if (rainSensorWorking == 1) { // if this is not 1 it signafies there is a short in the rain sensor (see the end of this function) and we would like to disable the
    rain = analogRead (rainsensor);
    if (rain > 333){   
      lcd.clear ();
      lcd.setCursor (0,1);
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
//               TITLE DISPLAY SECTION




void inWait() {
  unsigned long divideBy;
  lcd.clear();
  if ((r == 1) && (raining == 0)){
    delayTime = (3600000);  // 3600000 =  ie. 1 hour
    divideBy = 60000;
  }
  if ((r == 0) && (raining == 0)) {
    delayTime = (60000);// 1 minute
    divideBy = 1000;
  }
  if ((r == 0) && (raining == 1)) {
    openFunct();
    delayTime = (10000); //);// ie. 10 seconds
    divideBy = 60000;
  }
  if ((r == 1) && (raining == 1)) {
    openFunct();
    delayTime = (14400000); //14400000);// ie. 4 hours = 14400000
    divideBy = 60000;
  }
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
    if (raining == 1) {
      if ((millis() - startHours) == 14040000) {  // check psi after one hour
        readPSI ();
        if (psi > 190){
          inWait ();       
        }
        closeFunct();
      }
    }
  }
  if (raining==1) {
    stillRaining = (analogRead (rainsensor));
    if (stillRaining > 333) {
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
  inWait();
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
  lcd.clear();
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
    if (psi < 140) {
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





















