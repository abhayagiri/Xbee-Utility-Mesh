void closeFunct (){      //    CLOSE FUNCTION
    if(currState == 1 ||currState ==  3 || currState ==  5){
        adjValve (va, CLOSE);
    }
    if(currState == 2){
        adjValve (vc, CLOSE);
        adjValve (va, OPEN);
    }
    if(currState == 4){
        adjValve (vb, CLOSE);
        adjValve (va, OPEN);
        adjValve (vc, OPEN);
    }
    if(currState == 6){
        adjValve (vc, CLOSE);
        adjValve (va, OPEN);
    }
    if(currState == 7){
        adjValve (va, CLOSE);
    }
    if (currState == 0){
        sprintf (title, "All Valves Closed");
        printInfo();
        sendSerialValveOp(XBEE,"VLV=0,OP=ALLC");// 
        delay (2000);
    }
    currState--;
    if (currState < 1) {
        currState = 0;
    }
    //update valve state string and send status update
    valvestate();
    sendSerialStatus();
}

void openFunct (){      //    OPEN FUNCTION

    if(currState == 0 || currState ==  2 || currState == 4   || currState == 6    ){
        adjValve (va, OPEN);
    }
    if(currState == 3){
        adjValve (vc, CLOSE);
        adjValve (va, CLOSE);
        adjValve (vb, OPEN);
    }
    if(currState == 1 || currState == 5){
        adjValve (va, CLOSE);
        adjValve (vc, OPEN);
    }
    if (currState == 7){
        sprintf (title, "All Valves Open");
        printInfo();  
        sendSerialValveOp(XBEE,"VLV=0,OP=ALLO");//
        delay (2000);
    }
    currState++;
    if (currState > 6) {
        currState = 7;
    }
    //update valve state string and send status update
    valvestate();
    sendSerialStatus();
}

//for jumping to a valve state w/o going through intermediate states
void setValveState(unsigned char state) {
    if (state > 7 || currState == state) //sanity check
        return;

    switch (state) {
    case 0:
        adjValve (va, CLOSE);
        adjValve (vb, CLOSE);
        adjValve (vc, CLOSE);
        break;
    case 1:
        adjValve (va, OPEN);
        adjValve (vb, CLOSE);
        adjValve (vc, CLOSE);
        break;
    case 2:
        adjValve (va, CLOSE);
        adjValve (vb, CLOSE);
        adjValve (vc, OPEN);
        break;
    case 3:
        adjValve (va, OPEN);
        adjValve (vb, CLOSE);
        adjValve (vc, OPEN);
        break;
    case 4:
        adjValve (va, CLOSE);
        adjValve (vb, OPEN);
        adjValve (vc, CLOSE);
        break;
    case 5:
        adjValve (va, OPEN);
        adjValve (vb, OPEN);
        adjValve (vc, CLOSE);
        break;
    case 6:
        adjValve (va, CLOSE);
        adjValve (vb, OPEN);
        adjValve (vc, OPEN);
        break;
    case 7:
        adjValve (va, OPEN);
        adjValve (vb, OPEN);
        adjValve (vc, OPEN);
        break;
    }

    //update valve state string and send status update
    currState = state;
    valvestate();
    sendSerialStatus();
}

void adjValve (int valve, int action) {
    int delayTime;
    char opPacket[20];

    switch (valve) {
    case va:
        if (!testing) setRelay (LOW, LOW );
        if (action == CLOSE){
            sprintf (title, "Closing valve A");
            sprintf (opPacket, "VLV=A,OP=CLOSE");
            digitalWrite (ledA, LOW);
        } // these are settings for the master relays 
        else{
            sprintf (title, "Opening valve A");
            sprintf (opPacket, "VLV=A,OP=OPEN");
            digitalWrite (ledA, HIGH);
        } // these are settings for the master relays 
        break;
    case vb:
        if (!testing) setRelay (HIGH, LOW);
        if (action == CLOSE){
            sprintf (title, "Closing valve B");
            sprintf (opPacket, "VLV=B,OP=CLOSE");
            digitalWrite (ledB, LOW);
        } // these are settings for the master relays 
        else{
            sprintf (title, "Opening valve B");
            sprintf (opPacket, "VLV=B,OP=OPEN");
            digitalWrite (ledB, HIGH);
        } // these are settings for the master relays 
        break;
    case vc:
        if (!testing) setRelay (HIGH, HIGH); 
        if (action == CLOSE){
            sprintf (title, "Closing valve C");
            sprintf (opPacket, "VLV=C,OP=CLOSE");
            digitalWrite (ledC, LOW);
        }// these are settings for the master relays 
        else{
            sprintf (title, "Opening valve C");
            sprintf (opPacket, "VLV=C,OP=OPEN");
            digitalWrite (ledC, HIGH);
        } // these are settings for the master relays 
        break;
    default:
        break;
    }
    if (!testing) { 
        if (action == OPEN) {
            digitalWrite (valve, HIGH);
        }
        else {
            digitalWrite (valve, LOW);
        }
    }

    sendSerialValveOp(XBEE, opPacket);
    printInfo();

    if (!testing){
        delayTime = (15000);// &&&&& should be 15000 - see also txandtr for more &&&&&
    }
    else {
        delayTime = (2000);
    }
    delay (delayTime);
}

void setRelay (int mR1, int mR2) {

    digitalWrite (mRelay1, mR1);    
    digitalWrite (mRelay2, mR2);
}





