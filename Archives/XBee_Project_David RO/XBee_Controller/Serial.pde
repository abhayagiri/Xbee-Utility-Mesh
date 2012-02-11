// Reads data from serial input TX in the XBee API format
int getSerialData(char s[BUF_SIZE]) {
	//Erase buffer before grabbing new data.
	memset(s,'\0',BUF_SIZE);

	char c = '\0';;
	
	// Read serial data if there is any
	if (Serial.available()) {
		int startTime = millis();
		int i = 0;

		// waits for delimiter '~' marking start of transmission
		while (!Serial.available()) { }
		s[i++] = Serial.read();

		// return if the first character of the transmission
		// isn't the right character (transmissions must start
		// with a ~)
		if (s[i-1] != '~') { 
			return 1; 
		}

		i = 0;
		// the main loop for reading the serial data
		// into a string buffer
		// one less to have room for terminating '\0'
		while (c != '~' && i < BUF_SIZE-1) {
			while (!Serial.available()) {
				// wait 5 sec then timeout
				if (millis()-startTime > 5000) {
					Serial.flush();
					return 2;
				}
			}
			c = Serial.read();
			if (c != '~') // Transmissions also end with ~
				s[i++] = c;
		}

		Serial.flush();
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
	
	// if sent successfully print message to lcd
	lcd.clear();
	lcd.setCursor(0,0);
	lcd.print("Sent Command:");
	lcd.setCursor(0,1);
        // if sending to Turbine print a message about what command is sent
	if (strcmp(dest,"TRB") == 0) {
		if (b->a1)
			lcd.print("Open Valve");
		if (b->a2)
			lcd.print("Close Valve");
	}
	cfg->pauseCounter = 3;

	return 0;
} 

