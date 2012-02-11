#include <NewSoftSerial.h>

NewSoftSerial sSerial(8,9);

int buttonA = 4;
int buttonB = 6;
int buttonC = 7;
int buttonD = 3;

int stateA;
int stateB;
int stateC;
int stateD;


void setup() {
  sSerial.begin(9600);
  Serial.begin(9600);
  
  pinMode(buttonA, INPUT);
  pinMode(buttonB, INPUT);
  pinMode(buttonC, INPUT);
  pinMode(buttonD, INPUT);

  pinMode(8, INPUT);
  pinMode(9, OUTPUT);
}

void loop() {

  int lastA, lastB, lastC, lastD;

  lastA = stateA;  
  lastB = stateB;  
  lastC = stateC;  
  lastD = stateD;  
  
  if (digitalRead(buttonA) == HIGH) {
    delay(50);
    stateA = digitalRead(buttonA);
  }
  if (digitalRead(buttonB) == HIGH) {
    delay(50);
    stateB = digitalRead(buttonB);
  }
  if (digitalRead(buttonC) == HIGH) {
    delay(50);
    stateC = digitalRead(buttonC);
  }
  if (digitalRead(buttonD) == HIGH) {
    delay(50);
    stateD = digitalRead(buttonD);
  }
  
  if ((stateA != lastA) && (stateA == HIGH)) {
    Serial.print ("*A");
  }
  if ((stateB != lastB) && (stateB == HIGH)) {
    Serial.print ("*B");
  }
  if ((stateC != lastC) && (stateC == HIGH)) {
    Serial.print ("*C");
  }
  if ((stateD != lastD) && (stateD == HIGH)) {
    Serial.print ("*D");
  }
  
  while (sSerial.available())
   Serial.print((char)sSerial.read());
    
   while (Serial.available())
    sSerial.print((char)Serial.read());
}






