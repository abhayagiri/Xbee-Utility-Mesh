// Selects which feilduino to program
//#define TWT
//#define FWT
//#define RDG

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
#define SLEEP_PIN       A0 //put the xbee to sleep on HIGH
#define SLEEP_HEARTBEAT 1800000ul //wake up every 30min.
#define PIN_OFFSET	2
#define	PIN_TOTAL	7
#define PIN(p)		(PIN_OFFSET+p)
#define	LOCATION_NAME	"RDG"
#endif //RDG

#define HEARTBEAT      300000ul //send at least every 5 min
#define PACKET_INTERVAL  1000ul //pause 1 sec between each packet
#define PACKETS_PER_SEND 10ul //send 60 packets each time

unsigned long nextHeartbeat = 0;
unsigned long packetsToSend = 0;
unsigned long nextPacketSendTime = 0;

//keep track of time of day
//unsigned long int todInMillis = 0;

#ifdef RDG
boolean sleepMode = false;
#endif

struct {
  int old;
  int crnt;
} 
lvl = {
  -1,-1};

// Reset timer
extern volatile unsigned long timer0_millis; 

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

#ifdef RDG
  pinMode (SLEEP_PIN, OUTPUT);
  digitalWrite(SLEEP_PIN, LOW);
  timer0_millis = 43200000; //set time to noon
#endif

  randomSeed(analogRead(A5));
  nextHeartbeat = millis();
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
  // Every heartbeat, or if level changed, send level data
  if (millis() > nextHeartbeat || lvl.old != lvl.crnt) {
    nextHeartbeat += HEARTBEAT;
    packetsToSend = PACKETS_PER_SEND;
    nextPacketSendTime = millis();
    //updateTimers();
  }

  if (packetsToSend > 0)
  { 
    if (millis() > nextPacketSendTime ) {
      sendTankPacket();
      packetsToSend--;
      nextPacketSendTime += PACKET_INTERVAL;
    }

    if (packetsToSend == 0)
      sendTimeReportPacket();
  }

#ifdef RDG //put radio to sleep between 20:00 and 07:00 to save power
  while (millis() > 72000000 || millis() < 25200000) {
    unsigned int numPings = 6;
    unsigned long int delayMillis;

    digitalWrite(SLEEP_PIN, LOW);
    while (numPings-- > 0) {
      delayMillis = millis() + PACKET_INTERVAL;
      Serial.print("~XB="); 
      Serial.print(LOCATION_NAME); 
      Serial.print(",PT=PING~");
      while(millis() < delayMillis)
        checkForPacket();

    }
    sendTimeReportPacket();
    digitalWrite(SLEEP_PIN, HIGH);

    delay(SLEEP_HEARTBEAT);
#endif //this happens even if we don't sleep
    if (millis() > 86400000) { //reset millis every day
      timer0_millis = millis() % 86400000;
      nextHeartbeat = 0;
    }
#ifdef RDG
  }
#endif
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
  unsigned long tod = millis();
  Serial.print("~XB="); 
  Serial.print(LOCATION_NAME);
  Serial.print(",PT=LTR,H="); //LTR = local time report
  Serial.print(tod / 3600000);
  Serial.print(",M=");
  Serial.print((tod % 3600000) / 60000);
  Serial.print('~');
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
      Serial.print(",PT=PONG~");

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
        hourLoc += 2; 
        minLoc += 2;

        while (*hourLoc >= '0' && *hourLoc <= '9') {
          hours = (10*hours + *hourLoc-'0');
          hourLoc++;
        }
        while (*minLoc >= '0' && *minLoc <= '9') {
          mins = (10*mins + *minLoc-'0');
          minLoc++;
        }

        //set the millis() counter to the appropriate millisecond
        timer0_millis = (hours*3600000) + (mins * 60000);
        nextHeartbeat = millis();
      } 
    }
  }
}



