void updateLCD() {
  if (LCDState == 0 && (millis() > nextLCDUpdate || ba||bb||bc||bd)) {
    nextLCDUpdate = millis() + (1000ul * 1ul); //1 second
    printStandardData();
  }
  else if (LCDState == 1 && millis() > infoDismissTime) { //if displaying a temp. message, dismiss after some designated time
    LCDState = 0;
    printStandardData();
  }
}

void printStandardData() {
  lcd.clear ();
  lcd.setCursor (0,0);

  lcd.print("PSI="); //psi data
  lcd.print(psi);

  if (controlMode == 1)  //manual mode
    lcd.print(" *manual*");

  lcd.setCursor (0,1); //valve data
  lcd.print("Valves Open:");
  lcd.print(vopen);
}

void printInfo () { //print a temporary message
  lcd.clear();
  lcd.setCursor(0,1);
  lcd.print (title);
  infoDismissTime = millis() + 2000; //message is dismissed at this time (2 sec later)
  LCDState = 1; //tells updateLCD() we are displaying a temp. message
}





