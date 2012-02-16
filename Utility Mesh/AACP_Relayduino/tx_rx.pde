void txandtr(){
//  /* Send valve state and psi data every 30 sec */
  if (millis()-lastSerialTX >= 60000ul*5ul) {// &&&&& when this number is above 1000*30, it never enters this if loop!!! ideally this number should be set to 10 minutes 
    lastSerialTX = millis();
    sendSerialStatus();
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
          sendSerialStatus();
        }
      }
     else if(keyExists(rx.data,"PT") == true && strcmp(getDataVal(rx.data,"PT"),"PING") == 0) {
       Serial.print("~XB=TRB,PT=PONG~"); //respond to pings
       sendSerialStatus();
     }
    }
  }
}
