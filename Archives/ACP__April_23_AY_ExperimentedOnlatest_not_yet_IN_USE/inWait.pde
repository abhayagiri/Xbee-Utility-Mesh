void inWait() {
inWaitTop:
  unsigned long divideBy;
  lcd.clear();
  if ((r == REAL) && (raining == 0)){
    delayTime = (3600000);  // 3600000 =  ie. 1 hour
    divideBy = 60000;
  }
  if ((r == REAL) && (raining == 1)) {
    openFunct();
    delayTime = (14400000); //14400000);// ie. 4 hours = 14400000
    divideBy = 60000;
  }
  if ((r == TEST) && (raining == 0)) {
    delayTime = (6000);// 1 minute
    divideBy = 1000;
  }
  if ((r == TEST) && (raining == 1)) {
    openFunct();
    delayTime = (10000); //);// ie. 10 seconds
    divideBy = 60000;
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
    // For David: Change the below if section from sending data on request, to sending data every hour. Do a search for &&&& and it will take you to the place where I think we can insert the send secition.
    // But we want it to check for an incoming signal every few seconds, in case there is signal to open or close valves. 
    // Remember that we should send data from here affirming the open or close function was completed. 
    if (getSerialData(rx.str) == 0) {
      parseData (rx.data,rx.str);
      //      Serial.println(getDataVal(rx.data,"XB"));
      //      Serial.println(getDataVal(rx.data,"QRY"));
      //      Serial.println(getDataVal(rx.data,"Q"));
                          // ******* I also want to add the capacity to read another sensor, analog, and to send that data
                          // if (rpm > tooFast){
                          // sprintf (buf,EMERGENCY)}
                          
      
      if (keyExists(rx.data,"PT") == true && keyExists(rx.data, "XB"))
      {
        if (strcmp(getDataVal(rx.data,"PT"), "QRY") == 0 && keyExists(rx.data,"Q") == true)
        {
          if (strcmp(getDataVal(rx.data,"Q"), "LWS") == 0)
          {
            char buf[32];
            sprintf (buf,"V=%s,P=%d", vopen, psi);
            sendSerialData (XBEE, buf);
            Serial.println ();
            // if (query is actually an open or close command...){
              //closeFunct();
           // sendSerialData ("Stepping down function successful"):  }
              //else {openFunct}
            // sendSerialData ("Stepping up function successful"):  
              
          }
        }
      }
    }
    if (raining == 1) {
      if ((millis() - startHours) == 14040000) {  // check psi after one hour
        readPSI ();
        if (psi > 190){
          goto inWaitTop;       
        }
        closeFunct();
      }
    }
  }
  if (raining==1) {
    stillRaining = (digitalRead (rainsensor));
    if (stillRaining == 1) {
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
  //&&&& This, I think, is where we can insert the send section.
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

