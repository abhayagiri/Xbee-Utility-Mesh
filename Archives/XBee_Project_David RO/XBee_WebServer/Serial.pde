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
