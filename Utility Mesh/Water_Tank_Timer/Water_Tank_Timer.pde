// Selects which feilduino to program
// one and only one must be uncommented
// compiler will complain about undeclared PIN_TOTAL
// if none are uncommented
//#define TWT
#define FWT
//#define RDG

#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/sleep.h>
//#include "WProgram.h"

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
#define SLEEP_PIN       A0 //put the xbee to sleep on HIGH
#define SLEEP_HEARTBEAT 10000//1800000ul //wake up every 30min.
#define	LOCATION_NAME	"RDG"
#endif //RDG

#define HEARTBEAT      300000ul //send at least every 5 min
#define PACKET_INTERVAL  1000ul //pause 1 sec between each packet
#define PACKETS_PER_SEND 10ul //send 10 packets each time

unsigned long nextHeartbeat = 0;
unsigned long packetsToSend = 0;
unsigned long nextPacketSendTime = 0;

struct {
  int old;
  int crnt;
} 
lvl = {-1,-1};

// Make timer variable available for reset
extern volatile unsigned long timer0_millis; 

struct states {
  char current[PIN_TOTAL];
  char last[PIN_TOTAL];
} 
pinState;

#ifdef RDG
boolean sleepMode = false; //current sleep state
struct pingResponse { //holds responses during sleep cycle periodic wake and ping
  char id[4];         //won't go back to sleep before hearing from all of the stations listed
  bool responded;
} pingResponses[] = { "TWT", false, "FWT", false, "TRB", false,
                      "GTS", false, "VST", false, "SNA", false };
//auto-calculate the length, for 'for' loops, etc.
unsigned short numPingResponses = sizeof(pingResponses) / sizeof(struct pingResponse);
#endif

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
      case 1:
        lvl.crnt = 5;
        break;
      case 5:
        lvl.crnt = 3;
        break; 
      case 3:
          lvl.crnt = 1;
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

  if (millis() > 86400000) { //reset millis every day
    timer0_millis = millis() % 86400000;
    nextHeartbeat = 0;
  }

#ifdef RDG 
  //put radio to sleep between 20:00 and 07:00 to save power
  //wake up and ping every 30 min, for up to 15 min, or until
  //all stations in waitForResponsesFrom[] array have been heard from;
  if ((millis() > 72000000 || millis() < 25200000) &&
      packetsToSend == 0) { //go back to sleep after sending all normal update packets
    unsigned int maxNumPings = 450; //15min if using a 2-sec packet send interval
    unsigned long int delayMillis = millis();
    boolean heardFromAllStations = false;
    
    //set all responses to false
    for (int i=0; i<numPingResponses; i++)
      pingResponses[i].responded = false;

    digitalWrite(SLEEP_PIN, LOW);  //XBee wake up
    while (!heardFromAllStations &&
           maxNumPings-- > 0) { //send pings till all stations respond
      delayMillis += 2000;
      Serial.print("~XB=");
      Serial.print(LOCATION_NAME);
      Serial.print(",PT=PING~");
      
      while(millis() < delayMillis) //check for packets while we wait
        checkForPacket();
      
      heardFromAllStations = true; //see if we have heard from everyone
      for (int i=0; i<numPingResponses; i++)
        if (!pingResponses[i].responded)
          heardFromAllStations = false;
    }
    sendTimeReportPacket();
    digitalWrite(SLEEP_PIN, HIGH); //XBee power down

    delay(SLEEP_HEARTBEAT); 
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
    while ((Serial.available() || millis() < timeout) && i < 127) {
        if (Serial.available()) {
            if (Serial.peek() == '~') {
                timeout = millis();
                Serial.read();
            }
            else
                buf[i++] = Serial.read();
      }
    }

    buf[i] = '\0';

    //check for ping
    if (strstr(buf, "PT=PING") != NULL && 
       (strstr(buf, "DST") == NULL || strstr(buf, LOCATION_NAME) != NULL))
    {
      delay(random(0,2000));
      Serial.print("~XB=");
      Serial.print(LOCATION_NAME);
      Serial.print(",PT=PONG~");

      //respond to pings with data as well, just one packet, pls!
      packetsToSend += 1;

      //a little space between packets
      delay(100);
    }
    
    #ifdef RDG
    //check for pongs
    if (strstr(buf, "PT=PONG") != NULL)
    {
      int numResponses = sizeof(pingResponses) / sizeof(struct pingResponse);
      for (int i=0; i<numResponses; i++)
        if (strstr(buf,pingResponses[i].id) != NULL)
          pingResponses[i].responded = true;
    }
    #endif

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




