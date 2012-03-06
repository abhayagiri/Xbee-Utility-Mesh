#include <LiquidCrystal.h>

#define	LOCATION_NAME	"GTS"

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);
int calibratedNull = 0;
float sqrt2 = 1.4142;

unsigned long averagingTime = 1000;
unsigned long int todInSeconds = 0;
unsigned long wattSecondsToday = 0;
unsigned long  wattSecondsYesterday = 0;

extern volatile unsigned long timer0_millis;

void setup() {
  Serial.begin(9600);
  lcd.begin(16,2);
  pinMode(A0, INPUT);
  
  //kill digital input on A0
  DIDR0 = 0x01;
  
  //check if sensor is plugged in:
  while (analogRead(A0) < 30) {
    lcd.home(); lcd.print("Connect sensor");
    delay(500);
  }
  
  //calibrate
  lcd.clear(); lcd.print("Calibrating"); lcd.blink();
  unsigned long long int tmpAvg = 0;
  unsigned long int numSamps = 0;
  while (millis() < 5000) {
    tmpAvg += analogRead(A0);
    numSamps++;
  }
  calibratedNull = tmpAvg / numSamps;
  lcd.clear(); lcd.noBlink(); lcd.print("Cal. Null: ");
  lcd.print(calibratedNull);
  delay(3000);
  
  timer0_millis = 0;
}

void loop() {
  unsigned long int accumulator = 0;
  unsigned long int numSamples = 0;
  float current = 0;
  unsigned int watts = 0;

  int sample; //sample for 1 sec.
  while(millis() < averagingTime) {
    sample = analogRead(A0) - calibratedNull;
    accumulator += sample * sample;
    numSamples++;
  }
    
  current = sqrt((accumulator/(float)numSamples)) * (72.0 / 256.0);
  if (current < 0.25) current = 0;
  watts = current * 120.0; 
  wattSecondsToday += (watts); //watt-seconds / 3600 seconds per hour
  
  lcd.clear();
  lcd.print("I: "); lcd.print(current); lcd.print(" Amps");
  lcd.setCursor(0,1); 
  lcd.print("P: "); lcd.print(watts); lcd.print(" Watts");
  
  //handle timing
  averagingTime += 1000;
  todInSeconds = (todInSeconds + 1) % (86400ul);
  
  //check for packets 
  checkForPacket();
  
  if (todInSeconds == 0) {
    timer0_millis = 0;
    averagingTime = 1000;
    wattSecondsYesterday = wattSecondsToday;
    wattSecondsToday = 0;
  }
  
  //send packet every 5 min.
  if (todInSeconds % 10 == 0)
  {
    Serial.print("~XB=GTS,PT=WTT,W="); Serial.print(watts);
    Serial.print(",T="); Serial.print(wattSecondsToday / (3600000.0));
    Serial.print(",Y="); Serial.print(wattSecondsYesterday / (3600000.0));
    Serial.print('~');
  }
}
