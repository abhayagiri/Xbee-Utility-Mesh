// Size of array for storing recieved serial data
#define BUF_SIZE 32
// Number of entries that can be recieved over serial
#define KEYS_MAX 8
// Max size of each entry
#define ENT_SIZE 8
// Length of id string that comes from remote source (ie: SNA, TWT, FWT)
#define ID_LENGTH 4	// Remember actual length is one less due to zero
// termination of strings
#define XBEE "TRB"

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


/*    Variables for 2 input pins    */

#define psisensor  A0 
#define rainsensor 19 // Not yet in use with Relayduino


/*    Define variables for 4 buttons        */   //                           Axed with Relayduino
//#define buttonA  5
//#define buttonB  6
//#define buttonC  7   // Step up function
//#define buttonD  A4  // Step dpwn function


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
unsigned long lastSensorReadTime = 0;
unsigned long lastRainOpenTime = 0;
unsigned long lastSerialTX = 0;
unsigned long delayTimeMillis = 0;
int readCountDown = 0;
/*    Define misc. variables      */
unsigned long TimePasts = 0;
int rainSensorWorking = 1;
int stillRaining;
int rainCycles;
int raining = 0; // 0 means no rain. 1 means raining
unsigned long counter; // for holder a counting variable in mode function
int numPacketsSent = 0; //number packets sent during send period
unsigned long nextPacketTime = 15ul * 1000ul; //next packet send time in millis; initalize to 15 sec. just for fun...
int x;//  for holding cursor settings
int y;//  for holding cursor settings
int r = 1;// (REAL=1) (0=TEST) user will choose between 1 and 0 while operating - 1 for actual running the program, one for test purposes 
unsigned long delayTime;// hold time variables for "true" or "working"
int currState = 0;
int rain  = 0;
int psi = 0;
int ba; // for reading button a                                                                Axed with relayduino
int bb; // for reading button b
int bc; // for reading button c
int bd; // for reading button d
char vopen [5]  ;             //     variable that will hold which valves are open 
char title [21] ;            //     variable for misc. sentences
int symbol = 0;

