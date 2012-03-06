// Selects which feilduino to program
//#define TWT
//#define FWT
#define RDG

#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/sleep.h>

#ifdef TWT
#define PIN_OFFSET	2
#define	PIN_TOTAL	7
#define PIN(p)		(PIN_OFFSET+p)
#define	LOCATION_NAME	"TWT"
#endif //TWT

#ifdef FWT
#define PIN_OFFSET	9
#define	PIN_TOTAL	7
#define PIN(p)		(PIN_OFFSET+p)
#define	LOCATION_NAME	"FWT"
#endif //FWT

#ifdef RDG
#define PIN_OFFSET	2
#define	PIN_TOTAL	7
#define PIN(p)		(PIN_OFFSET+p)
#define	LOCATION_NAME	"RDG"
#endif //RDG

#define HEARTBEAT      300ul //send at leaset every 5 min
#define PACKET_INTERVAL  1ul //pause 1 sec between each packet
#define PACKETS_PER_SEND 10ul //send 60 packets each time

//keep track of time of day
unsigned long int todInMillis = 0;

struct {
  int old;
  int crnt;
} 
lvl = {
  -1,-1};

// Reset timer
extern volatile unsigned long timer0_millis;  
void resetMillis() {
  //add accumulated time to time-of-day    //86400000 millis in a day
  todInMillis = (todInMillis + millis()) % (86400000); 
  timer0_millis = 0; //now we can reset millis
  return;
}

struct states {
  char current[PIN_TOTAL];
  char last[PIN_TOTAL];
} 
pinState;

short packetsSent = 0;
boolean sending = false;

void setup() {
  Serial.begin(9600);
 
  for (int i = 0; i < PIN_TOTAL; i++) {
    pinMode(PIN(i),INPUT);
  }

  randomSeed(analogRead(A5));

  int i=0;
  while(i++<3) {
    sendTankPacket();
    delay(1000);
  }
}

void loop() {
  checkForPacket();

  for (int i = PIN_TOTAL-1; i >=0; i--) {
    pinState.last[i] = pinState.current[i];
    pinState.current[i] = digitalRead(PIN(i));
    if (pinState.current[i]) {
      lvl.old = lvl.crnt;
      lvl.crnt = i;

#ifdef RDG //ridge pins are funny
      switch(lvl.crnt) {
      case 6:
        lvl.crnt = 3;
        break;
      case 5:
        lvl.crnt = 4;
        break;
      case 4:
        lvl.crnt = 5;
        break;      
      case 3:
        lvl.crnt = 6;
        break;   
      }
#endif            
    }  
  }
  // Every heartbeat send level data or if level changed
  if ( (millis() > HEARTBEAT*1000ul || lvl.old != lvl.crnt) && !sending ) {
    sending = true;
    packetsSent = 0;
    resetMillis();
  }

  if (sending)
  { 
    if (millis() > PACKET_INTERVAL * 1000ul * packetsSent ) {
      sendTankPacket();
      packetsSent++;
    }

    if (packetsSent >= PACKETS_PER_SEND) {
      //Serial.print("finish");
      sending = false;
      packetsSent = 0;
      resetMillis();
      sendTimeReportPacket();
    }
  }
}

void sendTankPacket() {
  Serial.print("~XB="); 
  Serial.print(LOCATION_NAME);
  Serial.print(",PT=TNK,LVL="); 
  Serial.print(lvl.crnt);
  Serial.println('~');
}

//just tell the world what time we think it is
void sendTimeReportPacket() {
  Serial.print("~XB="); 
  Serial.print(LOCATION_NAME);
  Serial.print(",PT=LTR,H="); //LTR = local time report
  Serial.print(todInMillis / 3600000);
  Serial.print(",M=");
  Serial.print((todInMillis % 3600000) / 60000);
  Serial.println('~');
}

void checkForPacket() {
  if (Serial.available()) {
    char buf[128] = "";
    int i = 0;
    unsigned long timeout = 1000;
    timeout += millis();

    Serial.read();
    while ((Serial.available() || millis() < timeout) && i < 63) {
      if (Serial.available())
        buf[i++] = Serial.read();
      else if ( i>1 && buf[i-1] == '~')
        timeout = millis(); //done
    }

    buf[i] = '\0';

    if (strstr(buf, "PT=PING") != NULL)
    {
      delay(random(0,2000));
      Serial.print("~XB=");
      Serial.print(LOCATION_NAME);
      Serial.println(",PT=PONG~");

      //respond to pings with data as well, just one packet, pls!
      if (!sending) {
        sending = true; 
        packetsSent = PACKETS_PER_SEND - 1;
      }

      //a little space between packets
      delay(100);
    }
   
    //got time-of-day packet?
    else if (strstr(buf, "PT=TOD") != NULL) {
      char *hourLoc = strstr(buf, "H=");
      char *minLoc = strstr(buf, "M=");
      
      if ( hourLoc && minLoc ) { //if neither are NULL
        unsigned short hours = 0;
        unsigned short mins = 0;
        hourLoc += 2; minLoc += 2;
        
        while (*hourLoc >= '0' && *hourLoc <= '9') {
          hours = (10*hours + *hourLoc-'0');
          hourLoc++;
        }
        while (*minLoc >= '0' && *minLoc <= '9') {
          mins = (10*mins + *minLoc-'0');
          minLoc++;
        }
        
        resetMillis();
        todInMillis = (hours*3600000) + (mins * 60000);
      } 
    }
  }
}


