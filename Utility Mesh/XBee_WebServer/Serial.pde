//// Reads data from serial input TX in the XBee API format
//int getSerialData(char s[BUF_SIZE]) {
//	//Erase buffer before grabbing new data.
//	memset(s,'\0',BUF_SIZE);
//
//	char c = '\0';
//	
//	// Read serial data if there is any
//	if (Serial.available()) {
//		unsigned long int startTime = millis();
//		int i = 0;
//
//		// waits for delimiter '~' marking start of transmission
//		while (!Serial.available()) { }
//		s[i++] = Serial.read();
//
//		// return if the first character of the transmission
//		// isn't the right character (transmissions must start
//		// with a ~)
//		if (s[i-1] != '~') { 
//			return 1; 
//		}
//
//		i = 0;
//		// the main loop for reading the serial data
//		// into a string buffer
//		// one less to have room for terminating '\0'
//		while (c != '~' && i < BUF_SIZE-1) {
//			while (!Serial.available()) {
//				// wait 5 sec then timeout
//				if (millis()-startTime > 5000) {
//					Serial.flush();
//					return 2;
//				}
//			}
//			c = Serial.read();
//			if (c != '~') // Transmissions also end with ~
//				s[i++] = c;
//		}
//		//Serial.flush();
//		return 0;
//	}
//	return 1;
//}

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
                                        Serial.print("VST: Serial timed out");
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


void debugPrint(char *msg) {
  if (debugMode)
    Serial.print(msg);
}

void debugPrint(char c) {
  if (debugMode)
    Serial.print(c);
}

void debugPrintln(char *msg) {
  if (debugMode) {
    Serial.println(msg);
  }
}

void debugPrintln(char c) {
  if (debugMode) {
    Serial.println(c);
  }
}
