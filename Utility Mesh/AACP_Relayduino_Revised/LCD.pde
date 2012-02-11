void updateLCD() {
  if (LCDState == 0 && millis() > nextLCDUpdate) { //normal case - update LCD every 5 min.
    nextLCDUpdate = millis() + (60000ul *5ul);
    printStandardData();
  }
  else if (LCDState == 1) { //ratio mode display
    nextLCDUpdate = millis() + 500;
    printRatioData();
  }
  else if (LCDState == 2 && millis() > infoDismissTime) { //if displaying a temp. message, dismiss after some designated time
    if (controlMode == 2) { //in ratio mode
      LCDState = 2;
      printRatioData();
    } 
    else {
      LCDState = 0;
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

void printRatioData() {
  unsigned long timePast = millis()-lastRatioCycleTime;

  lcd.clear ();
  lcd.setCursor (0,0);

  if (ratioState == 0) { //waiting to open valves
    lcd.print("Closed");
    lcd.setCursor(0,1);
    lcd.print("Time Left: ");
    lcd.print((ratioClosedTime-timePast)/60000ul);
    lcd.print("m");
  }
  else if (ratioState == 1) { //waiting to open valves
    lcd.print("Priming Inverter");
    lcd.setCursor(0,1);
    lcd.print("Time Left: ");
    lcd.print(((ratioClosedTime+ratioOpenWaitTime)-timePast)/60000ul);
    lcd.print("m");
  }
  else if (ratioState == 2) { //waiting to open valves
    lcd.print("Open");
    lcd.setCursor(0,1);
    lcd.print("Time Left: ");
    lcd.print(((ratioClosedTime+ratioOpenTime)-timePast)/60000ul);
    lcd.print("m");
  }
  
}

void printInfo () { //print a temporary message
  lcd.clear();
  lcd.setCursor(0,1);
  lcd.print (title);
  infoDismissTime = millis() + 2000; //message is dismissed at this time (2 sec later)
  LCDState = 2; //tells updateLCD() we are displaying a temp. message
}




