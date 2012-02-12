void updateLCD() {
  if (LCDState == 0 && millis() > nextLCDUpdate) {
    if (controlMode == 0 || controlMode == 1) {  //auto and manual modes - standard display
      nextLCDUpdate = millis() + (1000ul * 5ul); //5 seconds
      printStandardData();
    } else if (controlMode == 2) { //ratio mode - special display
      nextLCDUpdate = millis() + 500; // 1/2 second, so the second countdown works
      printRatioData();
    }
  }
  else if (LCDState == 1 && millis() > infoDismissTime) { //if displaying a temp. message, dismiss after some designated time
    LCDState = 0;
    if (controlMode == 2) { //in ratio mode
      printRatioData();
    } else {
      printStandardData();
    }
  }
}

void printStandardData() {

  lcd.clear ();
  lcd.setCursor (0,0);

  lcd.print("PSI="); //psi data
  lcd.print(psi);

  if (controlMode == 1){ //manual mode
    lcd.print(' ');
    lcd.print("*manual*");
  }

  lcd.setCursor (0,1); //valve data
  lcd.print("Valves Open:");
  lcd.print(vopen);
}

//handle ratio mode data and manage changes
void printRatioData() {
  unsigned long timePast = millis()-lastRatioCycleTime;

  if (!ratioChangeRequested) { //normal case
    lcd.clear ();
    lcd.setCursor (0,0);
    if (ratioState == 0) { //waiting to open valves
      lcd.print("Closed");
      lcd.setCursor(0,1);
      lcd.print("Time Left: ");
      lcd.print((ratioClosedTime-timePast)/60000ul);
      lcd.print("m");
    }
    else if (ratioState == 1) { //open valve A for 5 min to prime inverter
      lcd.print("Priming Inverter");
      lcd.setCursor(0,1);
      lcd.print("Time Left: ");
      lcd.print(((ratioClosedTime+ratioOpenWaitTime)-timePast)/60000ul);
      lcd.print("m");
    }
    else if (ratioState == 2) { //both valves open
      lcd.setCursor(0,1);
      lcd.print("Time Left: ");
      lcd.print(((ratioClosedTime+ratioOpenTime)-timePast)/60000ul);
      lcd.print("m");
    }
  } else { //handling a ratio change request
    short tmpRatioClosed = ratioClosed; //tmp vars for storing changes until accepted
    short tmpRatioOpen = ratioOpen;
    
    if (ratioChangeStep == 0) { //init
      lcd.clear();
      lcd.setCursor(0,0); lcd.print("Ratio Open:Closd");
      lcd.setCursor(0,1); lcd.print(ratioClosed); lcd.print(':'); lcd.print(ratioOpen);
      lcd.setCursor(11,1); lcd.print("Accpt");
      lcd.setCursor(0,1); lcd.blink();
      ratioChangeStep = 1;
    } 
    if (ratioChangeStep == 1) { //cursor on 1st number
      if (bc || bd) { //change value buttons
        if (bc && ++tmpRatioClosed > 20) tmpRatioClosed = 1; //increment or decrement ratioClosed, wrapping at 20
        if (bd && --tmpRatioClosed < 1) tmpRatioClosed = 20;
        lcd.noBlink();
        lcd.print(tmpRatioClosed); lcd.print(" : "); lcd.print(tmpRatioOpen); 
        lcd.print(' '); lcd.setCursor(0,1); 
        lcd.blink();
      } else if (ba) { //accept button
        lcd.setCursor((tmpRatioClosed < 10 ? 4 : 5), 1);
        ratioChangeStep = 2;
      }
    } 
    if (ratioChangeStep == 2) { //cursor on 2nd number
      short cursorLoc = (tmpRatioClosed < 10 ? 4 : 5);
      if (bc || bd) { //change value buttons
         if (bc && ++tmpRatioOpen > 20) tmpRatioOpen = 1; //increment or decrement ratioOpen, wrapping at 20
        if (bd && --tmpRatioOpen < 1) tmpRatioOpen = 20;
        lcd.noBlink(); 
        lcd.print(tmpRatioOpen); lcd.print(' ');
        lcd.setCursor(cursorLoc,1); 
        lcd.blink();
      } else if (ba) {
        lcd.setCursor(11,1);
        ratioChangeStep = 3;
      }
    }
    if (ratioChangeStep == 3) { //cursor on "Accpt"
       if (bc || bd) { //accept changes; reset everyting relevent
         ratioClosed = tmpRatioClosed;
         ratioOpen = tmpRatioOpen;
         ratioChangeStep = 0; ratioChangeRequested = 0;
         ratioState = 3; //this forces a reset on the next loop
      } else if (ba) { //go back to 1st number
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




