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

//number of 1-second samples to average psi reading over
#define NUM_PSI_SAMPLES 30

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
unsigned long nextLCDUpdate = 0;
unsigned long infoDismissTime = 0; //time to dismiss temporary info messages

/*    Define misc. variables      */
int symbol = 0;
int r = 1;// (REAL=1) (0=TEST) user will choose between 1 and 0 while operating - 1 for actual running the program, one for test purposes 
int numPacketsSent = 0; //number packets sent during send period
unsigned long nextPacketTime = 15ul * 1000ul; //next packet send time in millis; initalize to 15 sec. just for fun...
unsigned long delayTime;// hold time variables for "true" or "working"
short currState = 0;
short controlMode = 0; //0 - Auto, 1 - Manual
short LCDState = 0; //0 - normal display, 1 - temporary info display
unsigned short psi = 0;

//some timing variables
unsigned long nextSecond = 1000;
bool newSecond = false;
unsigned long currSecond = 0;
unsigned int valveWaitTimer = 0;

//variables for doing running averages of psi value
int psiValues[NUM_PSI_SAMPLES];

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
