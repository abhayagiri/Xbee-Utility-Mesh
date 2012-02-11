// Size of array for storing recieved serial data
#define BUF_SIZE 32
// Number of entries that can be recieved over serial
#define KEYS_MAX 8
// Max size of each entry
#define ENT_SIZE 8
// Length of id string that comes from remote source (ie: SNA, TWT, FWT)
#define ID_LENGTH 4	// Remember actual length is one less due to zero
// termination of strings

/*    Variables for 9 relay pins    */
#define mRelay1 2  //     
#define mRelay2 9
//#define mRelay3 3  //                                             This relay is to be axed in the relayduino version
#define va 3
#define vb 5
#define vc 7
#define ledA 8
#define ledB 6
#define ledC 4
#define OPEN 1
#define CLOSE 0

#define REAL 1
#define TEST 0
// termination of strings
#define XBEE "TRB"


// Structure type for holding recently received dat a
struct dataStruct {
  char key[ENT_SIZE];
  char val[ENT_SIZE];
};


struct packetStruct{
  char str[BUF_SIZE];
  struct dataStruct data[KEYS_MAX];
};
packetStruct rx = { 
};


#define psisensor  A0 
#define rainsensor 19 // Not yet in use with Relayduino

unsigned long lastSerialTX = 0;
unsigned long lastDataUpdateTime = 0;
unsigned long lastRatioCycleTime = 0;
unsigned long nextLCDUpdate = 0;
unsigned long infoDismissTime = 0; //time to dismiss temporary info messages

//ratio mode variables
unsigned long ratioUnit = 2700000; //45 min. time unit
unsigned long ratioClosedTime = 2700000; //ratio is 1:1 at first
unsigned long ratioOpenTime = 2700000;
unsigned long ratioOpenWaitTime = 270000; //wait 4.5 min. with just vA open when moving to open ratio time
short ratioClosed = 1;
short ratioOpen = 1;
short ratioState = 3; //0-closed, 1-wait open, 2-full open, 3-reset

/*    Define misc. variables      */
int symbol = 0;
int r = 1;// (REAL=1) (0=TEST) user will choose between 1 and 0 while operating - 1 for actual running the program, one for test purposes 
int numPacketsSent = 0; //number packets sent during send period
unsigned long nextPacketTime = 15ul * 1000ul; //next packet send time in millis; initalize to 15 sec. just for fun...
unsigned long delayTime;// hold time variables for "true" or "working"
short currState = 0;
short controlMode = 0; //0 - Auto, 1 - Manual
short LCDState = 0; //0 - normal display, 1 - ratio mode, 2 - temporary info display
int psi = 0;
short ba; // for reading button a
short baLast;
short bb; // for reading button b
short bbLast;
short bc; // for reading button c
short bcLast;
short bd; // for reading button d
short bdLast;
char vopen [5]  ;       //     variable that will hold which valves are open 
char title [21] ;            //     variable for misc. sentences
