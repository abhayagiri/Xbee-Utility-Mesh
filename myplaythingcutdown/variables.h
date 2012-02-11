// Size of array for storing recieved serial data
//#define BUF_SIZE 32
//// Number of entries that can be recieved over serial
//#define KEYS_MAX 8
//// Max size of each entry
//#define ENT_SIZE 8
//// Length of id string that comes from remote source (ie: SNA, TWT, FWT)
//#define ID_LENGTH 4	// Remember actual length is one less due to zero
//// termination of strings
//#define XBEE "TRB"

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

/*    Variables for 2 input pins    */

//
//
//struct dataStruct {
//  char key[ENT_SIZE];
//  char val[ENT_SIZE];
//};
//
//
//struct packetStruct{
//  char str[BUF_SIZE];
//  struct dataStruct data[KEYS_MAX];
//};
//packetStruct rx = { 
////};
//unsigned long lastSensorReadTime = 0;
//unsigned long lastRainOpenTime = 0;
//unsigned long lastSerialTX = 0;
unsigned long delayTimeMillis = 0;
int readCountDown = 0;
/*    Define misc. variables      */
unsigned long TimePasts = 0;
int numPacketsSent = 0; //number packets sent during send period
unsigned long nextPacketTime = 15ul * 1000ul; //next packet send time in millis; initalize to 15 sec. just for fun...
unsigned long delayTime;// hold time variables for "true" or "working"
int currState = 0;
int psi = 0;
char vopen [5]  ;             //     variable that will hold which valves are open 
char title [21] ;            //     variable for misc. sentences


