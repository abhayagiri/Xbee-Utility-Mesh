void txandtr(){
  /* Send valve state and psi data every minute */
  if (millis()-lastSerialTX >= 1000*60) {
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
}


