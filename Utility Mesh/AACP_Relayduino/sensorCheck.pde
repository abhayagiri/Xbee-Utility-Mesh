void sensorCheck() {
  if (newSecond && !testing) { //once a second, sample the psi sensor
    //subracting 4 to normalize reading from sensor 
    psiValues[currSecond % NUM_PSI_SAMPLES] = map(analogRead(psisensor)-4, 0, 1024, 0, 250);
    //get average psi
    for (int i=0; i<NUM_PSI_SAMPLES; i++)
      psi += psiValues[i];
    psi = psi/NUM_PSI_SAMPLES;
  }


  //check if we are in a waiting period
  if (valveWaitTimer) {
    if (newSecond) valveWaitTimer--;
    if (testing && valveWaitTimer > 10) valveWaitTimer = 10; 
  } 
  
  else if (controlMode == 0) { //handle valve changes in auto mode
   
    //1. back off the 1st few states aggressively
    if (psi < 200 && currState >= 5) {
      closeFunct();
      valveWaitTimer = 300; //back in 5 min.
    }
    //2. until valve B is left, then wait till 160psi
    else if (psi < 160 && currState == 4) {
      setValveState(3);
      valveWaitTimer = 300;
    }
    //3. then close everything when we get below 160
    else if (psi < 160 && currState <= 3 && currState > 0) {
      setValveState(0);
    }  
    //4. wait till we get above 200, then prime inverter
    else if (psi > 200 && currState == 0) {
      openFunct();
      valveWaitTimer = 270; //prime inverter for 4.5 sec.
    }
    //5. if still above 160 after priming, open AC
    else if (psi > 160 && currState == 1) {
      setValveState(3);
    }
    //6. back to step 3. We should now be locked in this AC
    //cycle until we reset auto control mode.
  }
}




