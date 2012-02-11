#define PIN_OFFSET	2

#define	PIN_TOTAL	7
#define PIN(p)		(PIN_OFFSET+p)

//#define	LOCATION_NAME	"TWT"
//#define	LOCATION_NAME	"FWT"
#define	LOCATION_NAME	"RDG"

struct {
    int old;
    int crnt;
} lvl = {-1,-1};

boolean newLevel = false;

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

void setup() {
    Serial.begin(9600);
    for (int i = PIN_OFFSET; i < PIN_TOTAL; i++) {
        pinMode(i,INPUT);
    }
}

void loop() {

    for (int i = PIN_TOTAL-1; i >=0; i--) {
        pinState.last[i] = pinState.current[i];
        pinState.current[i] = digitalRead(PIN(i));
        if (pinState.current[i]) {
            lvl.old = lvl.crnt;
            lvl.crnt = i;
        }
    }
    // Every five minutes send level data or if level changed
    if (millis() > 300000 || lvl.old != lvl.crnt) {  
        // Buffer for tx
        char buf[128];

        // Data buffer
        char d[16];
        sprintf(d,"LVL=%d",lvl.crnt);

        makePacket(buf,LOCATION_NAME,"TNK",d);
        Serial.println(buf);
        resetMillis();
    }
}
int makePacket(char *buf,char *location,char *type,char *str) {
    sprintf(buf,"~XB=%s,PT=%s,%s~",location,type,str);
    return 0;
}






