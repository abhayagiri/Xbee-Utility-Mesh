void updateLCD() {
  if (LCDState == 0 && (millis() > nextLCDUpdate || ba||bb||bc||bd)) {
    if (controlMode == 0 || controlMode == 1) {  //auto and manual modes - standard display
      nextLCDUpdate = millis() + (1000ul * 1ul); //1 second
      printStandardData();
    } 
    else if (controlMode == 2) { //ratio mode - special display
      nextLCDUpdate = millis() + 500; // 1/2 second, so the second countdown works
      printRatioData();
    }
  }
  else if (LCDState == 1 && millis() > infoDismissTime) { //if displaying a temp. message, dismiss after some designated time
    LCDState = 0;
    if (controlMode == 2) { //in ratio mode
      printRatioData();
    } 
    else {
      printStandardData();
    }
  }
}

void printStandardData() {
  lcd.clear ();
  lcd.setCursor (0,0);
    
  lcd.print("PSI="); //psi data
  (currSecond >= 30 ? lcd.print(psi) : lcd.print(30-currSecond));

  if (controlMode == 1)  //manual mode
    lcd.print(" *manual*");

  lcd.setCursor (0,1); //valve data
  lcd.print("Valves Open:");
  lcd.print(vopen);
}

//handle ratio mode data and manage changes
void printRatioData() {
  const char str_timeLeft[] = "Time: ";
  const char str_seperator[] = " : ";
  const char str_ratioMode[] = "Ratio Mode:";
  
  unsigned long timePast = millis()-lastRatioCycleTime;
  
  if (!ratioChangeRequested) { //normal case
    lcd.clear ();
    lcd.setCursor (0,0);
    if (ratioState == 0) { //waiting to open valves
      lcd.print(str_ratioMode); lcd.print("Closd");
      lcd.setCursor(0,1);
      lcd.print(str_timeLeft);
      printMinSecString(ratioClosedTime-timePast);
    }
    else if (ratioState == 1) { //open valve A for ~5 min to prime inverter
      lcd.print("Priming Inverter");
      lcd.setCursor(0,1);
      lcd.print(str_timeLeft);
      printMinSecString((ratioClosedTime+ratioOpenWaitTime)-timePast);
    }
    else if (ratioState == 2) { //both valves open
      lcd.print(str_ratioMode); lcd.print("Open");
      lcd.setCursor(0,1);
      lcd.print(str_timeLeft);
      printMinSecString((ratioClosedTime+ratioOpenTime)-timePast);
    }
  } 
  else { //handling a ratio change request
    static short tmpRatioClosed; //tmp vars for storing changes until accepted
    static short tmpRatioOpen;

    if (ratioChangeStep == 0) { //init
      tmpRatioClosed = ratioClosed;
      tmpRatioOpen = ratioOpen;
      lcd.clear();
      lcd.setCursor(0,0); 
      lcd.print("Ratio Open:Closd");
      lcd.setCursor(0,1); 
      lcd.print(ratioClosed); 
      lcd.print(str_seperator); 
      lcd.print(ratioOpen);
      lcd.setCursor(11,1); 
      lcd.print("Accpt");
      lcd.setCursor(0,1); 
      lcd.blink();
      ratioChangeStep = 1;
    } 
    else if (ratioChangeStep == 1) { //cursor on 1st number
      if (bc || bd) { //change value buttons
        if (bc && ++tmpRatioClosed > 20) tmpRatioClosed = 1; //increment or decrement ratioClosed, wrapping at 20
        if (bd && --tmpRatioClosed < 1) tmpRatioClosed = 20;
        lcd.noBlink();
        lcd.print(tmpRatioClosed); 
        lcd.print(str_seperator); 
        lcd.print(tmpRatioOpen); 
        lcd.print(' '); 
        lcd.setCursor(0,1); 
        lcd.blink();
      } 
      else if (ba) { //accept button
        lcd.setCursor((tmpRatioClosed < 10 ? 4 : 5), 1);
        ratioChangeStep = 2;
      }
    } 
    else if (ratioChangeStep == 2) { //cursor on 2nd number
      short cursorLoc = (tmpRatioClosed < 10 ? 4 : 5);
      if (bc || bd) { //change value buttons
        if (bc && ++tmpRatioOpen > 20) tmpRatioOpen = 1; //increment or decrement ratioOpen, wrapping at 20
        if (bd && --tmpRatioOpen < 1) tmpRatioOpen = 20;
        lcd.noBlink(); 
        lcd.print(tmpRatioOpen); 
        lcd.print(' ');
        lcd.setCursor(cursorLoc,1); 
        lcd.blink();
      } 
      else if (ba) {
        lcd.setCursor(11,1);
        ratioChangeStep = 3;
      }
    }
    else if (ratioChangeStep == 3) { //cursor on "Accpt"
      if (bc || bd) { //accept changes; reset everyting relevent
        ratioClosed = tmpRatioClosed;
        ratioOpen = tmpRatioOpen;
        ratioChangeStep = 0; 
        ratioChangeRequested = 0;
        ratioState = 3; //this forces a reset on the next loop
        lcd.clear(); lcd.home(); lcd.noBlink();
      } 
      else if (ba) { //go back to 1st number
        lcd.setCursor(0,1);
        ratioChangeStep = 1;
      }
    }
  }
}

void printInfo () { //print a temporary message
  lcd.clear();
  lcd.setCursor(0,1);
  lcd.print (title);
  infoDismissTime = millis() + 2000; //message is dismissed at this time (2 sec later)
  LCDState = 1; //tells updateLCD() we are displaying a temp. message
}

void printMinSecString(unsigned long msecs) {
    //msecs = msecs % 60039000; //mod out values above 999:99
    short i = 0; //index for buffer
    unsigned int m = 0;
    unsigned int s = 0;
    
    while (msecs >= 60000) {
      m++; msecs -= 60000;
    }
    s = msecs / 1000;
    
    lcd.print(m); lcd.print(':');
    if (s<10) lcd.print(0);
    lcd.print(s);
}



