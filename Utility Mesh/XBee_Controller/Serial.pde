// Reads data from serial input TX in the XBee API format
int getSerialData(char s[BUF_SIZE]) {
	int charsAvail = 0;// Read serial data if there is any
	if ( (charsAvail = Serial.available()) > 0 ) {
        	//Erase buffer before grabbing new data.
		memset(s,'\0',BUF_SIZE);
              	char c = '\0';
                unsigned long int startTime = millis();
		int i = 0;

		// waits for delimiter '~' marking start of transmission
		while(charsAvail > 0 && Serial.peek() != '~') {
                    Serial.read();
                    charsAvail--;
                }
                if (charsAvail > 0)
                    s[0] = Serial.read();
                else
                    return 1;
                    
                    
		// the main loop for reading the serial data
		// into a string buffer
		// one less to have room for terminating '\0'
		while (c != '~' && i < BUF_SIZE-1) {
			while (!Serial.available()) {
				// wait 5 sec then timeout
				if (millis()-startTime > 5000) {
					//Serial.flush();
                                        Serial.print("Serial timed out");
					return 2;
				}
			}
			c = Serial.read();
			if (c != '~') // Transmissions also end with ~
				s[i++] = c;
		}

		//Serial.flush();
		return 0;
	}
	return 1;
}

// Send button states as serial data with XB tag
int sendButtons ( struct configStruct *cfg, const struct buttonStruct *b, const struct buttonStruct *bLast, char *id,char *dest ) {

	if (b->a1 && bLast->a1)
		return 1;
	if (b->a2 && bLast->a2)
		return 1;

        char buf[48];

        //total hack - ask for manual mode when stepping down from AC,
        //and auto mode when up from B; did this as we have run out
        //of convenient was to use the buttons;
        if ( b->a2 || strstr(turbine.valves, "AC ") == turbine.valves)
          sprintf(buf, "~XB=%s,DST=%s,PT=SCM,M=%d~", id, dest, 1);//
        else if ( b->a1 || strstr(turbine.valves, "B ") == turbine.valves)
          sprintf(buf, "~XB=%s,DST=%s,PT=SCM,M=%d~", id, dest, 0);//
          
	// Construct transmission
	sprintf(buf,"~XB=%s,DST=%s,PT=BTN,A1=%d,A2=%d,B1=%d,B2=%d~",
						id,	// XBee ID
                                                dest,    //Destination XBee
						b->a1,	// Button A1
						b->a2,	// Button A2
						b->b1,	// Button B1
						b->b2);	// Button B2
	// Send final string
	Serial.print(buf);

	return 0;
} 

void sendTurbineCommand() {
  if (trbCmd.cmdType == Mode) {
    Serial.print("~XB="); 
    Serial.print(XBEE);
    Serial.print(",PT=SCM,DST=TRB,M=");
    Serial.print(trbCmd.cmdValue);
    Serial.print("~");
  }
  else if (trbCmd.cmdType == ValveState) {
    Serial.print("~XB="); 
    Serial.print(XBEE);
    Serial.print(",PT=SVS,DST=TRB,VS=");
    Serial.print(trbCmd.cmdValue);
    Serial.print("~");
  }
}

