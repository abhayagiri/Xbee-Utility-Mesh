#include <MemoryTest.h>
#include <LiquidCrystal.h>

#define	LOCATION_NAME	"GTS"
#define AVG_SECS        10 //10sec running avg. for display, etc.

//had to abandon [watts = amps * volts] to get
//numbers close to inverter display. sampling
//showed a linear relationship:
//inverter displayed watts = constant + (coeffecient * sensed amps)
#define INVERTER_COEFFECIENT 274
#define INVERTER_CONSTANT -170

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);
int calibratedNull = 0;
float ampsPerUnitFromNull = 72.0 / 256.0;
float sqrt2 = 1.4142;

unsigned long int averagingTime = 1000;
unsigned long int todInSeconds = 0;
long int wattSecondsToday = 0;
long  int wattSecondsYesterday = 0;
int wattsAvgArray[AVG_SECS];

extern volatile unsigned long timer0_millis;

void setup() {
  Serial.begin(9600);
  lcd.begin(16,2);
  pinMode(A0, INPUT);
  
  //kill digital input on A0
  DIDR0 = 0x01;
  
  //init watts avg array
  for (int i=0; i<AVG_SECS; i++)
      wattsAvgArray[i] = 0;
  
  //printMemoryProfile(300000);
  
  //check if sensor is plugged in:
  while (analogRead(A0) < 30) {
    lcd.home(); lcd.print("Connect Sensor");
    delay(500);
  }
  
  //calibrate
  timer0_millis=0;
  
  lcd.clear(); lcd.print("Calibrating"); lcd.blink();
  unsigned long int avg = 0;
  int sample = 0, high = -1, low = 1025;
  unsigned long int numSamps = 0;
  while (millis() < 5000) {
    sample = analogRead(A0);
    if (sample > high) high = sample;
    if (sample < low) low = sample;
    avg += sample;
    numSamps++;
  }
  calibratedNull = avg / numSamps;
  lcd.clear(); lcd.noBlink(); lcd.print("Null ");
  lcd.print(calibratedNull);
  lcd.setCursor(0,1); 
  lcd.print("H "); lcd.print(high);
  lcd.print(" L "); lcd.print(low);
  delay(5000);
  
  timer0_millis = 0;
}

void loop() {
  unsigned long int accumulator = 0;
  unsigned int numSamples = 0;
  float current = 0;
  int watts = 0;
  long int avgWatts = 0;

  int sample; //sample for 1 sec.
  while(millis() < averagingTime) {
    sample = analogRead(A0) - calibratedNull;
    accumulator += sample * sample;//(sample>0 ? sample : 0); //expecting dc, ignoring negative components the rectifier output
    numSamples++;
  }
    
  current = sqrt((accumulator/(float)numSamples)) * (72.0 / 256.0); //for AC
  //current = (accumulator/(float)numSamples) * ampsPerUnitFromNull; //for DC
  if (current < 0.5) current = 0;
  if (current > 0) watts = (current * 287);//INVERTER_COEFFECIENT) + INVERTER_CONSTANT;
  wattSecondsToday += watts;
  
  //handle timing
  averagingTime += 1000;
  todInSeconds = (todInSeconds + 1) % (86400ul);
  wattsAvgArray[todInSeconds%AVG_SECS] = watts;
  for (int i=0; i<AVG_SECS; i++) 
      avgWatts += wattsAvgArray[i];
  avgWatts /= AVG_SECS;
  
  //check for packets 
  checkForPacket();
  
  if (todInSeconds == 0) {
    timer0_millis = 0;
    averagingTime = 1000;
    wattSecondsYesterday = wattSecondsToday;
    wattSecondsToday = 0;
  }
  
  //send packet every 2 min.
  if (todInSeconds % 120 == 0)
     sendPacket();
  
  //update LCD
  lcd.clear();
  lcd.print("I: "); lcd.print(current);
  lcd.print(' '); lcd.print(numSamples);
  lcd.setCursor(0,1); 
  lcd.print("P: "); lcd.print(avgWatts);
  lcd.print(' '); lcd.print(accumulator);
}
