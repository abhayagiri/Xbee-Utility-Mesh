void countRainCycles(){
  if (raining==1) {
    stillRaining = (digitalRead (rainsensor));
    if (stillRaining == 1) {
      rainCycles = rainCycles + 1;
    }
    if (r==1){
      if (rainCycles > 100) {
        rainSensorShorted () ; // There is a short with the rain sensor //
      }
    }
    else {
      if (rainCycles > 2) {
        rainSensorShorted () ; // There is a short with the rain sensor //
      }
    }
  }
}

