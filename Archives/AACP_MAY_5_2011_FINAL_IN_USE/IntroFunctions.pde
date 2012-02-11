
void intro(){ 
  if (r == REAL || r == TEST){
    ccs();
  }
  lcd.clear ();
  lcd.setCursor (0,1);
  lcd.print ("Enter Main Program");
  delay (1500);
  lcd.clear();
  inWait ();
}

void ccs(){  
  lcd.clear();
  lcd.setCursor (0,1);
  lcd.print("Initial Setup...");
  delay (1000);
  lcd.clear();
  lcd.setCursor (0,1);
  lcd.print("Opening Valves...");
  adjValve (va, OPEN);// valves a & c are on the same relay
  adjValve (vc, OPEN);
  adjValve (vb, OPEN);
  currState = 7;  // ensure all valves are open   }
}

void mode ()
{
  while (1){
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
}




