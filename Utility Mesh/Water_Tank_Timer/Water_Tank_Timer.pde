// Selects which feilduino to program
#define TWT
//#define FWT
//#define RDG

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

struct {
    int old;
    int crnt;
} lvl = {-1,-1};

// Reset timer
extern volatile unsigned long timer0_millis;  
void resetMillis() {
    timer0_millis = 0; 
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
    for (int i = PIN_OFFSET; i < PIN_OFFSET + PIN_TOTAL; i++) {
        pinMode(i,INPUT);
    }
    
    randomSeed(analogRead(5));
    //Serial.print("done");
    
    //send initial status packets
    char buf[64];
    // Data buffer
    char d[16];
    
    int i=0;
    while(i++<3) {
      sprintf(d,"LVL=%d",lvl.crnt);
      makePacket(buf,LOCATION_NAME,"TNK",d);
      Serial.println(buf);
      delay(1000);
    }
}

void loop() {
  checkForPing();
    
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
      //Serial.println("cought sending condition");
    }
    
    if (sending)
    {
        
      // Buffer for tx
      char buf[64];
      // Data buffer
      char d[16];
      
      if (millis() > PACKET_INTERVAL * 1000ul * packetsSent ) {
        sprintf(d,"LVL=%d",lvl.crnt);
        makePacket(buf,LOCATION_NAME,"TNK",d);
        Serial.println(buf);
        packetsSent++;
      }
      
      if (packetsSent >= PACKETS_PER_SEND) {
        //Serial.print("finish");
        sending = false;
        packetsSent = 0;
        resetMillis();
      }
    }
}

int makePacket(char *buf,char *location,char *type,char *str) {
    sprintf(buf,"~XB=%s,PT=%s,%s~",location,type,str);
    return 0;
}

boolean checkForPing() {
  if (Serial.available()) {
    char buf[64] = "";
    int i = 0;
    unsigned long timeout = 1000;
    timeout += millis();
  
    while ((Serial.available() || millis() < timeout) && i < 63) {
      if (Serial.available())
        buf[i++] = Serial.read();
      else if ( i>1 && buf[i-1] == '~')
        timeout = millis(); //done
    }
    
    buf[i] = '\0';
    
    if (strstr(buf, "PT=PING") != NULL)
    {
      //if (sending)
        //delay(100);
      delay(random(0,2000));
      Serial.print("~XB=");
      Serial.print(LOCATION_NAME);
      Serial.print(",PT=PONG~");
      if (sending)
        delay(200);
      return true;
    } 
  }

}
