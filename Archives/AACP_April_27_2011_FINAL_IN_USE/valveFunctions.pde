
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
    cursorSet();
    delay (2000);
  }
  currState--;
  if (currState < 1) {
    currState = 0;
  }
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
  if(currState == 1|| currState == 5){
    adjValve (va, CLOSE);
    adjValve (vc, OPEN);
  }
  if (currState == 7){
    sprintf (title, "All Valves Open");
    cursorSet();
    delay (2000);
  }
  currState++;
  if (currState >6) {
    currState = 7;
  }
}

void adjValve (int valve, int action) {
  int delayTime;
  switch (valve) {
  case va:
    if (action == CLOSE){
      sprintf (title, "Closing valve A");
      setRelay (LOW, LOW, LOW );
    } // these are settings for the master relays 
    else{
      sprintf (title, "Opening valve A");
      setRelay (LOW, LOW, HIGH );
    } // these are settings for the master relays 
    break;
  case vb:
    if (action == CLOSE){
      sprintf (title, "Closing valve B");
      setRelay (LOW, HIGH, LOW);
    } // these are settings for the master relays 
    else{
      sprintf (title, "Opening valve B");
      setRelay (LOW, HIGH, HIGH);
    } // these are settings for the master relays 
    break;
  case vc:
    if (action == CLOSE){
      sprintf (title, "Closing valve C");
      setRelay (HIGH, LOW, LOW); 
    }// these are settings for the master relays 
    else{
      sprintf (title, "Opening valve C");
      setRelay (HIGH, LOW, LOW);
    } // these are settings for the master relays 
    break;
  default:
    break;
  } 
  cursorSet ();
  if (action == OPEN) {
    digitalWrite (valve, HIGH);
  }
  else {
    digitalWrite (valve, LOW);
  }
  if (r == REAL){
    delayTime = (15000);// &&&&& should be 15000 - see also txandtr for more &&&&&
  }
  else {
    delayTime = (2000);
  }
  delay (delayTime);
}

void setRelay (int mR1, int mR2a, int mR2b) {

  digitalWrite (mRelay1, mR1);
  digitalWrite (mRelay2a, mR2a);
  digitalWrite (mRelay2b, mR2b);
}




