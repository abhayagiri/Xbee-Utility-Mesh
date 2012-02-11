// Size of array for storing recieved serial data
#define BUF_SIZE 32
// Number of entries that can be recieved over serial
#define KEYS_MAX 16
// Max size of each entry
#define ENT_SIZE 16
// Length of id string that comes from remote source (ie: INV, TWT, FWT)
#define ID_LENGTH 4	// Remember actual length is one less due to zero
// termination of strings
#define XBEE "LWS"

/*    Variables for 9 relay pins    */
#define mRelay1 14  // Master relay will be a non-latching
#define mRelay2a 15
#define mRelay2b 16
#define va 2
#define vb 3
#define vc 4
#define OPEN 1
#define CLOSE 0
#define REAL 1
#define TEST 0


/*    Variables for 2 input pins    */

#define psisensor  17 
#define rainsensor 19


/*    Define variables for 4 buttons        */
#define buttonA  5
#define buttonB  6
#define buttonC  7   // Step up function
#define buttonD  A4  // Step dpwn function


// Structure type for holding recently received data
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

unsigned long lastRainOpenTime = 0;
unsigned long lastSerialTX = 0;
/*    Define misc. variables      */
unsigned long TimePasts = 0;
int rainSensorWorking = 1;
int stillRaining;
int rainCycles;
int raining = 0; // 0 means no rain. 1 means raining
unsigned long counter; // for holder a counting variable in mode function
int x;//  for holding cursor settings
int y;//  for holding cursor settings
int r = 9;// user will choose between 1 and 0 while operating - 1 for actual running the program, one for test purposes 
unsigned long delayTime;// hold time variables for "true" or "working"
int currState = 0;
int rain  = 0;
int psi = 0;
int ba; // for reading button a
int bb; // for reading button b
int bc; // for reading button c
int bd; // for reading button d
char vopen [5]  ;             //     variable that will hold which valves are open 
char title [21] ;            //     variable for misc. sentences


