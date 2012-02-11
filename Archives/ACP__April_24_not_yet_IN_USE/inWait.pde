void inWait() {
inWaitTop:
  unsigned long divideBy;
  lcd.clear();
  if ((r == REAL) && (raining == 0)){
    delayTime = (3600000);  // 3600000 =  ie. 1 hour
    divideBy = 60000;
  }
  if ((r == REAL) && (raining == 1)) {
    delayTime = (14400000); //14400000);// ie. 4 hours = 14400000
    divideBy = 60000;
  }
  if ((r == TEST) && (raining == 0)) {
    delayTime = (6000);// 1 minute
    divideBy = 1000;
  }
  if ((r == TEST) && (raining == 1)) {
    delayTime = (10000); //);// ie. 10 seconds
    divideBy = 1000;
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
    /* Send data every five minutes */
    if (millis()-lastSerialTX >= 5000) {
	lastSerialTX = millis();
	char buf[32];
	sprintf(buf,"~XB=%s,PT=TRB,V=%s,P=%d~\n",XBEE,vopen,psi);
	Serial.print(buf);
}
    /*	Check for remote commands	*/
    if (getSerialData(rx.str) == 0) {
      parseData (rx.data,rx.str);
      // Packet Type is Button?
      if (keyExists(rx.data,"PT") == true && strcmp(getDataVal(rx.data,"PT"),"BTN") == 0) {
        // Destination is this location?
        if (keyExists(rx.data,"DST") == true && strcmp(getDataVal(rx.data,"DST"),XBEE) == 0) {
          // Check for the ID of the sending XBee
          if (keyExists(rx.data,"XB") == true) {
            // if A1 is toggled open valve
            if (keyExists(rx.data,"A1") && atoi(getDataVal(rx.data,"A1")) == 1) {
              openFunct();
              sendSerialAwk(XBEE,getDataVal(rx.data,"XB"));
            }
            if (keyExists(rx.data,"A2") && atoi(getDataVal(rx.data,"A2")) == 1) {
              closeFunct();
              sendSerialAwk(XBEE,getDataVal(rx.data,"XB"));
            }
          }
        }
      }
    }
    if (raining == 1 && millis() - lastRainOpenTime >= delayTime)  {
      lastRainOpenTime = millis();
      readPSI ();
      if (psi > 190){
        openFunct();       
      }
      else 
        closeFunct();
    }
    if (raining==1) {
      stillRaining = (digitalRead (rainsensor));
      if (stillRaining == 1) {
        rainCycles = rainCycles + 1;
      }
      if (r==1){
        if (rainCycles > 100) {
          rainSensorShorted () ; // There is a short with the rain sensor //
        }
      }
      else {
        if (rainCycles > 2) {
          rainSensorShorted () ; // There is a short with the rain sensor //
        }
      }
    }
    readSensorProg();// read rain and psi sensor and adj valves if psi is falling
  }
  goto inWaitTop;
}

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




