void checkForPacket() {
    if (Serial.available()) {
        char buf[128] = "";
        int i = 0;
        unsigned long timeout = 1000 + millis();

        Serial.read();
        while ((Serial.available() || millis() < timeout) && i < 63) {
            if (Serial.available())
                buf[i++] = Serial.read();
            else if ( i>1 && buf[i-1] == '~')
                timeout = millis(); //done
        }

        buf[i] = '\0';

        //ping? pong.
        if (strstr(buf, "PT=PING") != NULL)
        {
            delay(random(0,100));
            Serial.print("~XB=");
            Serial.print(LOCATION_NAME);
            Serial.print(",PT=PONG~");

            sendStatusPacket();
            sendTimeReportPacket();
        }

        //got time-of-day packet?
        else if (strstr(buf, "PT=TOD") != NULL) {
            char *hourLoc = strstr(buf, "H=");
            char *minLoc = strstr(buf, "M=");

            if ( hourLoc && minLoc ) { //if neither are NULL
                unsigned long hours = 0;
                unsigned long mins = 0;
                hourLoc += 2; 
                minLoc += 2;

                while (*hourLoc >= '0' && *hourLoc <= '9') {
                    hours = (10*hours + *hourLoc-'0');
                    hourLoc++;
                }
                while (*minLoc >= '0' && *minLoc <= '9') {
                    mins = (10*mins + *minLoc-'0');
                    minLoc++;
                }

                timer0_millis = (hours*3600000) + (mins*60000);
            } 
        }
    }
}

void sendStatusPacket() {
    long int avgWatts = 0;
    
    for (int i=0; i<NUM_SAMPLES; i++) avgWatts += wattsAvgArray[i];
    avgWatts /= NUM_SAMPLES;
    Serial.print("~XB=GTS,PT=WTT,W="); 
    Serial.print(avgWatts);
    Serial.print(",T="); 
    Serial.print(wattSecondsToday / (3600000.0));
    Serial.print(",Y="); 
    Serial.print(wattSecondsYesterday / (3600000.0));
    Serial.print('~');
}

void sendTimeReportPacket() {
  Serial.print("~XB="); 
  Serial.print(LOCATION_NAME);
  Serial.print(",PT=LTR,H="); //LTR = local time report
  Serial.print((millis() / 1000) / 3600);
  Serial.print(",M=");
  Serial.print((millis() / 1000) / 60);
  Serial.print('~');
}
