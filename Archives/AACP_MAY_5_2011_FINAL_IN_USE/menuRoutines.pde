
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

