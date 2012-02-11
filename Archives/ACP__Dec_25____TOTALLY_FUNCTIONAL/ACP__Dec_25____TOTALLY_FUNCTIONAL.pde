#include <LiquidCrystal.h>
LiquidCrystal lcd(13,8,12,11,10,9); 

/*    Variables for 9 relay pins    */
int mRelay1 = 15; // Master relay will be a non-latching
int mRelay2 = 14;
int vaon = 2;
int vaoff = 3;
int vbon = 6;
int vboff = 7;
int vcon = 4;
int vcoff = 5;

/*    Variables for 2 input pins    */
int psisensor = A7; 
//int rainsensor = A6;


/*    Define variables for 3 buttons        */
int open = 19;
int close = 18;
int buttonA = 16;
int buttonB = 17;

/*    Define misc. variables      */
unsigned long TimePasts = 0;

unsigned long counter; // for holder a counting variable in mode function
int x;//  for holding cursor settings
int y;//  for holding cursor settings
int r = 9;// user will choose between 1 and 0 while operating - 1 for actual running the program, one for test purposes 
unsigned long delayTime;// hold time variables for "true" or "working"
int currState = 0;
int appNeg = 0;
int appPos = 0;
int psi = 0;
int bc; // for reading button c
int bd; // for reading button d
int ba; // for reading button a
int bb; // for reading button b
char* vopen="";             //     variable that will hold which valves are open 
char* title="";            //     variable for misc. sentences

void setup () {
  analogReference (DEFAULT);
  lcd.begin (20,4);
  pinMode (mRelay1,OUTPUT);
  pinMode (mRelay2,OUTPUT);
  pinMode (vaon,OUTPUT);
  pinMode (vaoff,OUTPUT);
  pinMode (vbon,OUTPUT);
  pinMode (vboff,OUTPUT);
  pinMode (vcon,OUTPUT);
  pinMode (vcoff,OUTPUT);
  pinMode (open, INPUT);
  pinMode (close, INPUT);
  pinMode (buttonA, INPUT);
  pinMode (buttonB, INPUT);
  //  lcd.clear ();
  //  lcd.print ("Program Resetting...");
  //  delay (1000);
  mode ();
}
//                       END OF SETUP

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
    ccs();
    lcd.clear ();
    lcd.setCursor (0,1);
    lcd.print ("Enter Main Menu...");
    delay (1500);
    lcd.clear();
    inWait ();
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
  digitalWrite (appNeg,LOW);
  digitalWrite (appPos,HIGH);
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
  bothHigh();
  appNeg = vaon;
  appPos = vaoff;
  adjValve ();
}

void closevalveb (){

  title = ("Closing valve B");
  cursorSet ();
  bothLow();
  appNeg = vbon;
  appPos = vboff;
  adjValve ();
}

void closevalvec (){

  title = ("Closing valve C");
  cursorSet ();
  oneEach();
  appNeg = vcon;
  appPos = vcoff;
  adjValve ();
}

void openvalvea (){

  title = ("Opening valve A");
  cursorSet ();
  bothHigh();
  appNeg = vaoff;
  appPos = vaon;
  adjValve();
}

void openvalveb (){

  title = ("Opening valve B");
  cursorSet ();
  bothLow();
  appNeg = vboff;
  appPos = vbon;
  adjValve();
}

void openvalvec (){
  title = ("Opening valve C");
  cursorSet ();
  oneEach();
  appNeg = vcoff;
  appPos = vcon; 
  adjValve();
}

void bothHigh(){

  digitalWrite (mRelay1, HIGH);// mRelay1 = pin 15 should be valve a
  digitalWrite (mRelay2, HIGH);
}

void bothLow(){
  digitalWrite (mRelay1, LOW);
  digitalWrite (mRelay2, LOW);
}
void oneEach(){
  digitalWrite (mRelay1, HIGH);
  digitalWrite (mRelay2, LOW);
}


void valvestate(){ 
  if (currState==0) vopen = "NONE";
  if (currState==1) vopen = "A";
  if (currState==2) vopen = "C";
  if (currState==3) vopen = "AC";
  if (currState==4) vopen = "B";
  if (currState==5) vopen = "AB";
  if (currState==6) vopen = "BC";
  if (currState==7) vopen = "ABC";


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
  title = ("Button C:  Open Prog");
  cursorSet1();
}

void titleScreen4() {
  title = ("Button D: Close Prog");
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
    title = (" Begin Open Routine");
    lcd.clear();
    lcd.setCursor(0,1);
    lcd.print (title);
    delay (2000);
    openFunct();
    printCurr();
    title = ("");
  }
  if(bd==1) {                  //bd was pressed
    title = ("Begin Close Routine");
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
  bc = digitalRead (open);
  bd = digitalRead (close);
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
  psi = map (analogRead(psisensor), 0, 1023, 0, 200);
  // psi = 210; // THIS SHOULD BE DELETED WHEN TRANSDUCER IS HOOKED UP !!!!!!!!!!!!!!!!!!
}


//               TITLE DISPLAY SECTION




void inWait() {
  unsigned long divideBy;
  lcd.clear();
  if (r == 1){
    delayTime = (3600000);  // 3600000 =  ie. 1 hour
    divideBy = 60000;
  }
  else {
    delayTime = (60000);// 1 minute
    divideBy = 1000;
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
    delay(1500);
    whileRoutine1();
    TimePasts = ((millis ()-startHours));
    lcd.print (((delayTime-TimePasts)/divideBy));
    whileRoutine2();
  }
  PSIProg();
  inWait();
}



//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void whileRoutine1(){
  lcd.setCursor (0,2);
  lcd.print ("PSI Reread in "); 
}

void whileRoutine2(){
  if (r == 1){
    lcd.print (" min");
  }
  else {
    lcd.print (" sec");
  }
  delay (1000);
  readbutt(); 
  menuOpt();
  lcd.setCursor (0,3);
  lcd.print ("B for Main Menu");
  delay (100);
}


void PSIProg(){
  //  lcd.clear();      /////      Three lines for tracing 
  //  lcd.print("psi program");
  //  delay (600);
  lcd.clear();
  readPSI ();
  psi = 200;// THIS IS TO BE DELETED WHEN ACTUALY RUNNING
  if ((psi < 180) && (currState != 4 ) && (currState < 6))
  {
    closeFunct ();
    if (r==1) {
      delay (1800000); // wait 30 minutes and check psi again
    }
    else {
      delay (2000);
    }
    PSIProg();
  }
  if  (currState == 4 ) // State 4 means valve B is open. Since its output is 1000 watts, we'd like to wait till the psi drops quite a bit 
  {                     // before valves are closed to the State 3, which only has an output of around 350 watts.
    if (psi < 140) {
      closeFunct ();
      inWait();
      PSIProg();
    }
  }
  if ((psi < 200) && (currState == 1))
  {
    lcd.clear();
    lcd.setCursor (1,1);
    lcd.print ("Final Valve Open.");
    delay (3000);
    lcd.clear();
    lcd.setCursor (1,3);
    lcd.print ("No More Adj..");
    delay (3000);
    inWait();
    PSIProg();
  }
}























