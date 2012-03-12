/****************************************************************
We ran out of pins on the relayduino board, and decided to use
a spare lillypad for handling buttons and the xBee. Standard 
Serial sends button press messages to the relayduino, and listens 
for messages meant to go out to the xBee; a NewSoftSerial instance
talks to the xBee.
****************************************************************/

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
  
  
  //these delays debounce the button presses
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
  
  //current method does not allow simultanious
  //button presses to be sent, eg. *AC, also
  //does not send button-up notification. May
  //be usefull for other apps in the future.
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
  
  //replicate anything coming from one serial
  //interface to the other.
  while (sSerial.available()) //listening for incoming xBee packets
   Serial.print((char)sSerial.read()); //send to relayduino
    
   while (Serial.available()) //anything from relayduino?
    sSerial.print((char)Serial.read()); //send out on xBee
}






