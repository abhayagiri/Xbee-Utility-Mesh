void inWait() {
  while (1){
    // Read Sensorsf

    readSensorProg();// read rain and psi sensor and adj valves if psi is falling

      // check for rain sensor short
    countRainCycles ();

    unsigned long divideBy;
    lcd.clear();
    if ((r == REAL) && (raining == 0)){
      delayTime = 3600000;  // 1 hour
      divideBy = 60000;  // one minute
    }
    if ((r == REAL) && (raining == 1)) {
      delayTime = 14400000; // 4 hours
      divideBy = 60000;  // one minute
    }
    if ((r == TEST) && (raining == 0)) {
      delayTime = 30000;// 30 seconds
      divideBy = 1000;
    }
    if ((r == TEST) && (raining == 1)) {
      delayTime = 20000;// 20 seconds
      divideBy = 1000;
    }  

    unsigned long startHours = millis();
    unsigned long loopDelay = 3000; //3 sec. delay for most of loop
    unsigned long nextLoopTime = millis(); //start right away
    
    while ((millis()-startHours) < delayTime){  
      
      // tx and tr functions
      //placed outside the main loop to make sure
      //data gets received
      txandtr();
    
      if (millis() >= nextLoopTime) {
        nextLoopTime += loopDelay; //wait loop delay before doing this again.
        readPSI();
        lcd.setCursor (0,0);
        lcd.print("Current PSI = ");
        lcd.print(psi);
        valvestate();
        lcd.setCursor (0,1);
        lcd.print ("Valves Open: ");
        lcd.print (vopen);
        lcd.print ("   ");
        whileRoutine1();
        TimePasts = ((millis ()-startHours));
        readCountDown = (delayTime-TimePasts)/divideBy;
        lcd.print (readCountDown);
        whileRoutine2();
  
        if (raining == 1 && millis() - lastRainOpenTime >= delayTime)  {
          lastRainOpenTime = millis();
          readPSI ();
          if (psi > 190){
            openFunct();       
          }
          else 
            closeFunct();
        }
      }
    
    }
  }
}

void whileRoutine1(){
  if (raining != 1){
    lcd.setCursor (0,2);
    lcd.print ("PSI Reread in "); 
  }
  else{
    lcd.setCursor (0,1);
    lcd.print ("Rain - Wait "); 

  }
}


void whileRoutine2(){
  if (r == 1) {
    lcd.print (" min");
  }
  else {
    lcd.print (" sec");
  }
  readbutt(); 
  menuOpt();
  lcd.setCursor (0,3);
  lcd.print ("B for Auto Override");
//delay (3000);
}














