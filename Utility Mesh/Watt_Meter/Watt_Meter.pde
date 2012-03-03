#include <LiquidCrystal.h>

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);
int calibratedNull = 0;
float sqrt2 = 1.4142;

void setup() {
  Serial.begin(9600);
  lcd.begin(16,2);
  pinMode(A0, INPUT);
  
  DIDR0 = 0x01;
  
  //check if sensor is plugged in:
  while (analogRead(A0) < 30) {
    lcd.home(); lcd.print("Connect sensor");
    delay(500);
  }
  
  //calibrate
  lcd.clear(); lcd.print("Calibrating"); lcd.blink();
  unsigned long int tmpAvg = 0;
  for (int i=0; i<15000; i++)
    tmpAvg += analogRead(A0);
  calibratedNull = tmpAvg / 15000;
  lcd.clear(); lcd.noBlink(); lcd.print("Cal. Null: ");
  lcd.print(calibratedNull);
  lcd.setCursor(0,1); lcd.print("OK?");
  delay(2000);
}

void loop() {
  static float wattHours = 0.0;
  unsigned long int accumulator = 0;
  unsigned long int numSamples = 0;
  unsigned long averegingTime = millis()+1000;
  float averagePeak = 0;
  float current = 0;

  int sample;
  while(millis() < averegingTime) {
    sample = analogRead(A0) - calibratedNull;
    accumulator += sample * sample;
    numSamples++;
  }
  
  current = sqrt((accumulator/(float)numSamples)) * (72.0 / 256.0);
  if (current < 0.1) current = 0;
  lcd.clear();
  lcd.print("I: "); lcd.print(current); lcd.print(" Amps");
  lcd.setCursor(0,1); 
  lcd.print("P: "); lcd.print(wattHours += (current * 120)/3600); lcd.print(" WHrs");
}
