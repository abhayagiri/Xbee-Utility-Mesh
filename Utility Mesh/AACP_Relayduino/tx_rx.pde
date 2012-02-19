void txandtr(){
  //  /* Send valve state and psi data every 30 sec */
  if (millis()-lastSerialTX >= 60000ul*5ul) {// &&&&& when this number is above 1000*30, it never enters this if loop!!! ideally this number should be set to 10 minutes 
    lastSerialTX = millis();
    sendSerialStatus();
  }

  /*	Check for remote commands	*/
  if (getSerialData(rx.str) == 0) { 
    parseData (rx.data,rx.str);

    //is well formed, has packet type, is for US?
    if ((keyExists(rx.data,"XB") && 
      keyExists(rx.data,"PT") &&
      keyExists(rx.data,"DST") == true && 
      strcmp(getDataVal(rx.data,"DST"),XBEE) == 0)) {

      //BTN packet type     
      if (strcmp(getDataVal(rx.data,"PT"),"BTN") == 0) {
        // if A1 is toggled open valve
        if (keyExists(rx.data,"A1") && atoi(getDataVal(rx.data,"A1")) == 1)
          openFunct();
        if (keyExists(rx.data,"A2") && atoi(getDataVal(rx.data,"A2")) == 1)
          closeFunct();

        sendSerialAwk(XBEE,getDataVal(rx.data,"XB"));
      }//BTN

      //Explicit valve state change request
      else if(strcmp(getDataVal(rx.data,"PT"),"VSR") == 0 &&
        keyExists(rx.data,"VS")) {

        //check for up/down symbols '+' and '-'
        if (strcmp(getDataVal(rx.data,"VS"), "-") == 0) closeFunct();
        else if (strcmp(getDataVal(rx.data,"VS"), "+") == 0) openFunct();

        else { //else, use atoi, remember returns 0 for junk data
          if (strcmp(getDataVal(rx.data,"VS"), "0") == 0) setValveState(0);
          else {
            int i = atoi(getDataVal(rx.data,"VS"));
            if (i>0) setValveState(i);
          }
        }
      }//VSR
      
      //PING packet
      else if(strcmp(getDataVal(rx.data,"PT"),"PING") == 0) {
        Serial.print("~XB=TRB,PT=PONG~"); //respond to pings
        sendSerialStatus();
      }//PING
      
    }//well formed
  }//got data
}//txandtr()




