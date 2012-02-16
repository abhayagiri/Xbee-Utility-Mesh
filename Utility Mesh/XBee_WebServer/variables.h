boolean debugMode = false;

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0,230 };
prog_char myUrl[] PROGMEM = "http://192.168.0.230/";

// Minutes to wait until data is deemed old enough to warrent a warning
#define MINUTES_UNTIL_OLD    10
// Number of display modes for LCD
#define DISPLAY_MODES	2
// Size of array for storing recieved serial data
#define BUF_SIZE  128
//Size of the buffer for the http request
#define HTTP_REQ_SIZE 64
// Number of entries that can be recieved over serial
#define KEYS_MAX 8
// Max size of each entry
#define ENT_SIZE 8
// Number of water tanks
#define	TANK_NUM 3
// Length of id string that comes from remote source (ie: INV, TWT, FWT)
#define ID_LENGTH 4	// Remember actual length is one less due to zero
			// termination of strings

//states for handling web button presses
#define WEB_NORMAL 0
#define WEB_CMD_SENT 1
#define WEB_CMD_ACKNOWLEDGED 2

//Some strings for web commands
prog_char valveOpStr[] PROGMEM = "Valve Operation";
prog_char pumpOpStr[] PROGMEM = "Pump Operation";
prog_char pingOpStr[] PROGMEM = "Ping Operation";
prog_char valveOpenMsg[] PROGMEM = "<p>Sent valve open command, waiting for response...</p>";
prog_char valveCloseMsg[] PROGMEM = "<p>Sent valve close command, waiting for response...</p>";
prog_char pumpStartMsg[] PROGMEM = "<p>Sent pump start command, waiting for response...</p>";
prog_char pumpStopMsg[] PROGMEM = "<p>Sent pump stop command, waiting for response...</p>";
prog_char pingMsg[] PROGMEM = "<p>Sent ping command, waiting for responses...</p>";
prog_char valveOpenPacket[] PROGMEM = "~XB=VST,PT=BTN,DST=TRB,A1=1~";
prog_char valveClosePacket[] PROGMEM = "~XB=VST,PT=BTN,DST=TRB,A2=1~";
prog_char pumpStartPacket[] PROGMEM = "~XB=VST,DST=RDG,PT=POP,OP=ON~";
prog_char pumpStopPacket[] PROGMEM = "~XB=VST,DST=RDG,PT=POP,OP=OFF~";
prog_char pingPacket[] PROGMEM = "~XB=VST,PT=PING~";

// Turbine Error Limit (if watt reading from Upper Water Shed fall too far
// there is probably a problem with the turbine)
#define WATTS_ERROR_LEVEL	40
bool hydroError = false;

int webState = WEB_NORMAL; //set when handling button press on web page

// Tank enumation
#define	TWT	0
#define	FWT	1
#define RDG	2

// Macro to calculate size of array
#define LENGTH(a,t)	((sizeof(a))/(sizeof(t)))

struct timerStruct {
	unsigned int day;
	unsigned int hour;
	unsigned int min;
	unsigned int sec;
	bool justOverflowed;
};
struct timerStruct timer = {0,0,0,0,false};

// Structure type for holding recently received data
struct dataStruct {
	char key[ENT_SIZE];
	char val[ENT_SIZE];
};

// Structure for water tank data
struct tankStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int level;
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
        unsigned int dmin;
} tanks[TANK_NUM];

// Structure for water tank data
struct turbineStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	char valves[5];		// holds valve status
	int psi;		// holds turbine psi
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
        unsigned int dmin;
} turbine;

// Structure for water tank data
struct hydroWattsStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int watts;		// holds watts produced by hydro
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
        unsigned int dmin;
} hydroWatts;


// Structure for battery room data
struct batteryStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int status;
//        char statusStr[32];
	char volts[6];
	char hourVolts[6];
	// Arduino sprintf doesn't print floats
	//float hourVolts;
	//float volts;
	int watts;
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
        unsigned int dmin;
} battery;

struct packetStruct{
	char str[BUF_SIZE];
	struct dataStruct data[KEYS_MAX];
};
packetStruct rx = { };

//this keeps track of timeouts for web commands
struct webCmdTimerStruct {
        struct timerStruct timeStamp;
        int timeout;
        prog_char *opStr;
        prog_char *msgStr;
        prog_char *packetStr;
        char pongList[32];
} webCmdTimer;
        
