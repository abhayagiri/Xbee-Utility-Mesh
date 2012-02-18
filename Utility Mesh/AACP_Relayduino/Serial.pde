// Reads data from serial input TX in the XBee API format
int getSerialData(char s[BUF_SIZE]) {
    int charsAvail = 0;// Read serial data if there is any
    if ( (charsAvail = Serial.available()) > 1 ) {
        //Erase buffer before grabbing new data.
        memset(s,'\0',BUF_SIZE);
        char c = '\0';
        unsigned long int startTime = millis();
        int i = 0;

        //1st - check for button presses
        if (Serial.peek() == '*') {
            Serial.read(); c = Serial.read();
            if (c == 65)
                ba = 1;
            if (c == 66)
                bb = 1;
            if (c == 67)
                bc = 1;
            if (c == 68)
                bd = 1;
                
            return 1;
        }


        // waits for delimiter '~' marking start of packet
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



int sendSerialStatus ()
{
    char buf[32];
    valvestate();
    sprintf(buf,"~XB=%s,PT=TRB,V=%s,P=%d~\n",XBEE,vopen,psi);
    Serial.print(buf);
    return 0;
}

int sendSerialValveOp (char *xbee, char *str)
{
    char tx[64];
    sprintf (tx, "~XB=%s,PT=VOP,%s~",xbee,str);
    Serial.print (tx);
    return 0;
}

int sendSerialAwk (char *xbee, char *dst)
{
    char tx[32];
    sprintf (tx,"~XB=%s,PT=AWK,DST=%s~",xbee,dst);
    Serial.print (tx);
    return 0;
}

