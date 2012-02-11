
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
  if (currState <1) {
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
  switch (valve) {
  case va:
    setRelay (HIGH, LOW, HIGH); // these are settings for the master relays 
    if (action == CLOSE)
      sprintf (title, "Closing valve A");
    else
      sprintf (title, "Opening valve A");
    break;
  case vb:
    setRelay (HIGH, HIGH, LOW); // these are settings for the master relays 
    if (action == CLOSE)
      sprintf (title, "Closing valve B");
    else
      sprintf (title, "Opening valve B");
    break;
  case vc:
    setRelay (LOW, LOW, HIGH); // these are settings for the master relays 
    if (action == CLOSE)
      sprintf (title, "Closing valve C");
    else
      sprintf (title, "Opening valve C");
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
    delayTime = (15000);
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
