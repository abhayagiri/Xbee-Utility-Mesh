
//void closeFunct (){      //    CLOSE FUNCTION
//  if(currState == 1 ||currState ==  3 || currState ==  5){
//    adjValve (va, CLOSE);
//  }
//  if(currState == 2){
//    adjValve (vc, CLOSE);
//    adjValve (va, OPEN);
//  }
//  if(currState == 4){
//    adjValve (vb, CLOSE);
//    adjValve (va, OPEN);
//    adjValve (vc, OPEN);
//  }
//  if(currState == 6){
//    adjValve (vc, CLOSE);
//    adjValve (va, OPEN);
//  }
//  if(currState == 7){
//    adjValve (va, CLOSE);
//  }
//  if (currState == 0){
//    sprintf (title, "All Valves Closed");
//    sendSerialValveOp(XBEE,"VLV=0,OP=ALLC");
//
//    delay (2000);
//  }
//  currState--;
//  if (currState < 1) {
//    currState = 0;
//  }
//}
//
//void openFunct (){      //    OPEN FUNCTION
//
//  if(currState == 0 || currState ==  2 || currState == 4   || currState == 6    ){
//    adjValve (va, OPEN);
//  }
//  if(currState == 3){
//    adjValve (vc, CLOSE);
//    adjValve (va, CLOSE);
//    adjValve (vb, OPEN);
//  }
//  if(currState == 1|| currState == 5){
//    adjValve (va, CLOSE);
//    adjValve (vc, OPEN);
//  }
//  if (currState == 7){
//    sprintf (title, "All Valves Open");   
//    sendSerialValveOp(XBEE,"VLV=0,OP=ALLO");
//
//    delay (2000);
//  }
//  currState++;
//  if (currState >6) {
//    currState = 7;
//  }
//}

void adjValve (int valve, int action) {
    int delayTime;
    char opPacket[20];

    switch (valve) {
    case va:
        setRelay (LOW, LOW );
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
        setRelay (HIGH, LOW);
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
        setRelay (HIGH, HIGH); 
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

    if (action == OPEN) {
        digitalWrite (valve, HIGH);
    }
    else {
        digitalWrite (valve, LOW);
        delay (15000);
    }
}

void setRelay (int mR1, int mR2) {

    digitalWrite (mRelay1, mR1);    
    digitalWrite (mRelay2, mR2);
}








