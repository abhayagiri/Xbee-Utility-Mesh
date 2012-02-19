void sensorCheck() {
  if (newSecond) { //once a second, sample the psi sensor
    //adding 4 to normalize reading from sensor 
    psiValues[currSecond % NUM_PSI_SAMPLES] = 4 + map(analogRead(psisensor), 0, 1024, 0, 250);
    //get average psi, not counting samples not yet received (1st 30 seconds)
    int samplesReceived = NUM_PSI_SAMPLES;
    for (int i=0; i<NUM_PSI_SAMPLES; i++)
      psiValues[i] >= 0 ? psi += psiValues[i] : --samplesReceived;
    psi = psi/samplesReceived;
  }
  
  //every 30 sec. update 10-min record of total change in PSI
  if (newSecond % NUM_PSI_SAMPLES == 0) {
    
  }

  if (controlMode == 0 && currSecond >= nextPSICheckTime) { //check for auto mode
    switch (autoControlPhase) {
    
    case OPENING:
    if (psi > 200 && currState < 7) {
      openFunct(); 
      nextPSICheckTime = currSecond + 600; //back in 10
    }
    else if (psi < 180)
      autoControlPhase = CLOSING; 
    else
      
    break;
    
    case CLOSING:
    if (currentState > 0 && psi < 180)
      closeFunct();
      autoControlPhase
    break;
   
    case TRICKLE: 
    
    break;
    }
  }

}


