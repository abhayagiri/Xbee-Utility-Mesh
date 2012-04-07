#include <MemoryTest.h>
#include <LiquidCrystal.h>

#define	LOCATION_NAME	"GTS"
#define NUM_SAMPLES        10 //# of samples to smooth watt reading, for display, etc.

//had to abandon [watts = amps * volts] to get
//numbers close to inverter display. sampling
//showed a linear relationship:
//inverter displayed watts = constant + (coeffecient * sensed amps)
#define INVERTER_COEFFECIENT 250
#define INVERTER_CONSTANT 0

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);
int calibratedNull = 0;
float ampsPerUnitFromNull = 72.0 / 256.0;

unsigned long int samplingTime = 0;
//unsigned long int todInSeconds = 0;
long int wattSecondsToday = 0;
long  int wattSecondsYesterday = 0;
int lcdWattsAvgArray[NUM_SAMPLES]; //the array accumulating the 10 second avg. watts value shown on the LCD
unsigned int packetWatts = 0; //the 5-minute avg. watts value sent over the radio
unsigned char wattsAvgIndex = 0;

extern volatile unsigned long timer0_millis;

void setup() {
  Serial.begin(9600);
  lcd.begin(16,2);
  pinMode(A0, INPUT);
  
  //kill digital input on A0
  DIDR0 = 0x01;  //will cause a compile error if board set to feilduino8
  
  //init watts avg array
  for (int i=0; i<NUM_SAMPLES; i++)
      wattsAvgArray[i] = 0;
  
  //printMemoryProfile(300000);
  
  //check if sensor is plugged in:
  while (analogRead(A0) < 30) {
    lcd.home(); lcd.print("Connect Sensor");
    delay(500);
  }
  
  //calibration; simply finds the mean of a 5-second sample run
  //and uses that as the 0 value; best to restart the unit with no
  //current being registered, but it will probably be fine for AC
  //currents; during testing, the null was usually 522ish, 521-524
  //a perfect output from the sensor would be 512, but it may be off
  //by +/-2% according to datasheet.
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
}

void loop() {
  unsigned long int accumulator = 0;
  unsigned int numSamples = 0;
  float current = 0;
  int watts = 0;
  long int avgWatts = 0;

  samplingTime = millis() + 1000;
  while(millis() < samplingTime) {
    //accumulate the square of the reading for samplingTime;
    int sample = (analogRead(A0) - calibratedNull);
    accumulator += sample*sample;
    numSamples++; //divide by this to get the average
  }
  
  //DC side was not working well - switched to PVP's AC output
  current = sqrt((accumulator/(float)numSamples)) * ampsPerUnitFromNull; //get RMS value of average sensor reading
  //current = (accumulator/(float)numSamples) * ampsPerUnitFromNull; //for DC
  if (current < 0.5) current = 0; //clamp spurious readings
  if (current > 0) watts = (current*INVERTER_COEFFECIENT) + INVERTER_CONSTANT;
  wattSecondsToday += watts;
  
  //do watt smoothing
  lcdWattsAvgArray[wattsAvgIndex] = watts;
  wattsAvgIndex = (wattsAvgIndex + 1) % NUM_SAMPLES;
  for (int i=0; i<NUM_SAMPLES; i++) 
      avgWatts += wattsAvgArray[i];
  avgWatts /= NUM_SAMPLES;
  // do Packet Watt smoothing - 5 minutes worth of 10-second smoothed samples
  if (wattAvgIndex == (NUM_SAMPLES-1)) {
     packetWatts *= 29;
     packetWatts += avgWatts;
     packetWatts /= 30;
  }
  
  //check for packets 
  checkForPacket();
  
  //roll-over timer if needed
  if (millis() > 86400000) {
    timer0_millis = millis() % 86400000;
    wattSecondsYesterday = wattSecondsToday;
    wattSecondsToday = 0;
  }
  
  //send packet every 5 min.
  if ((millis() / 1000) % 300 == 0)
     sendStatusPacket();
  
//  safety - if avgWatts > 3960, send step down command to turbine
//  if (avgWatts > 3850 && (millis() / 1000) % 60 == 0) {//send once a minute @ most
//    Serial.print("~XB=GTS,DST=TRB,PT=SVS,VS=-~");
//  }
  
  //update LCD
  lcd.clear();
  lcd.print("I: "); lcd.print(current);
  //lcd.print(' '); lcd.print(numSamples);
  lcd.setCursor(0,1); 
  lcd.print("P: "); lcd.print(avgWatts);
  //lcd.print(' '); lcd.print(accumulator);
}
