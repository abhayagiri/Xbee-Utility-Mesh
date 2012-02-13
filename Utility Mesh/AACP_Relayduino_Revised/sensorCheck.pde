void sensorCheck() {
  if (newSecond) //once a second  
    psiValues[currSecond % 30] = map (analogRead(psisensor), 0, 1024, 0, 250);

  if (controlMode == 0) { //check for auto mode
    if ((psi < 180) && (currState != 4 ) && (currState > 0)) // State 1 means valve ABC is open
    {
      closeFunct ();
    }
    if  (currState == 4 ) // State 4 means valve B is open. Since its output is 1000 watts, we'd like to wait till the psi drops quite a bit 
    {                     // before valves are closed to the State 3, which only has an output of around 350 watts.
      if (psi < 160) {
        closeFunct ();
      }
    } 
  }
}



