boolean debugMode = false;

boolean timeSet = false;

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0,230 };
prog_char myUrl[] PROGMEM = "http://xbee-mesh/";
unsigned int ntpPort = 8888;      // local port to listen for NTP packets
byte timeServer[] = {192,168,0,10}; //IP of windows 2008 server
const int NTP_PACKET_SIZE= 48; // NTP time stamp is in the first 48 bytes of the message
byte packetBuffer[ NTP_PACKET_SIZE]; //buffer to hold incoming and outgoing NTP packets 

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
prog_char httpResponse200[] PROGMEM = "HTTP/1.1 200 OK\nContent-Type: text/html\n";
prog_char openDocument[] PROGMEM = "<html><head><title>";
prog_char openBody[] PROGMEM = "<body bgcolor=\"DarkGoldenRod\">";
prog_char openContainer[] PROGMEM = "<table height=100% width=100% border=0 style=\"text-align:center; font-size:24pt;\">"
                                    "<tr><td align=center, valign=middle>";
prog_char closeContainer[] PROGMEM = "</td></tr></table>";
prog_char openData[] PROGMEM = "<td align=\"center\" valign=\"middle\">";
prog_char strMins[] PROGMEM = " Minutes";
prog_char strHours[] PROGMEM = " Hours";
prog_char strAgo[] PROGMEM = " Ago</b></td></tr>";
prog_char valveOpStr[] PROGMEM = "Valve Operation";
prog_char modeOpStr[] PROGMEM = "Change Mode";
prog_char pumpOpStr[] PROGMEM = "Pump Operation";
prog_char pingOpStr[] PROGMEM = "Ping Operation";
prog_char valveOpenMsg[] PROGMEM = "valve open";
prog_char valveCloseMsg[] PROGMEM = "valve close";
prog_char valveSetMsg[] PROGMEM = "valve set";
prog_char modeSetMsg[] PROGMEM = "change mode";
prog_char pumpStartMsg[] PROGMEM = "pump start";
prog_char pumpStopMsg[] PROGMEM = "pump stop";
prog_char pingMsg[] PROGMEM = "<p style=\"text-align:center; font-size:24pt;\">Sent ping command, waiting for responses...<p>";
prog_char valveOpenPacket[] PROGMEM = "~XB=VST,PT=BTN,DST=TRB,A1=1~";
prog_char valveClosePacket[] PROGMEM = "~XB=VST,PT=BTN,DST=TRB,A2=1~";
//total hack; % and $ replaced w/requested state when parsed out to turbine
prog_char valveSetPacket[] PROGMEM = "~XB=VST,PT=SVS,DST=TRB,VS=%~";
prog_char modeSetPacket[] PROGMEM = "~XB=VST,DST=TRB,PT=SCM,M=%~";
prog_char pumpStartPacket[] PROGMEM = "~XB=VST,DST=RDG,PT=POP,OP=ON~";
prog_char pumpStopPacket[] PROGMEM = "~XB=VST,DST=RDG,PT=POP,OP=OFF~";
prog_char pingPacket[] PROGMEM = "~XB=VST,PT=PING~";
prog_char twtAlertStr[] PROGMEM = "TWT - Water Level Low";
prog_char fwtAlertStr[] PROGMEM = "FWT - Water Level Low";
prog_char rdgAlertStr[] PROGMEM = "RDG - Water Level Low";
prog_char battAlertStr[] PROGMEM = "Battery Bank Voltage Low";
prog_char psiAlertStr[] PROGMEM = "Turbine PSI Low";

// Turbine Error Limit (if watt reading from Upper Water Shed fall too far
// there is probably a problem with the turbine)
#define WATTS_ERROR_LEVEL	40
bool hydroError = false;

int webState = WEB_NORMAL; //set when handling button press on web page

// Tank enumation
#define	TWT	0
#define	FWT	1
#define RDG	2
const float numTankLevels = 6.0; //number of levels the tank sensors can report

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
        unsigned int tankCap;   // Tank capacity in gallons
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
        unsigned char controlMode; //0-auto, 1-manual; see AACP-Relayduino
        unsigned char testing;     //0-normal, 1-testing mode; see AACP-Relayduino     
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
        unsigned int dmin;
} turbine;

// Structure for water tank data
struct hydroWattsStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int watts;		// holds watts produced by hydro
        float kwhToday;
        float kwhYesterday;
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

struct alertStruct {
  boolean active;
  boolean dismissed;
  prog_char *alertString;
  struct timerStruct timeStamp;
};

#define NUM_ALERTS TANK_NUM + 2 //one for each tank, plus however many more
#define ALERT_LED 3
//tanks at the top, in same order as corresponding structs in tanks[]
struct alertStruct *alerts[NUM_ALERTS];
struct alertStruct twtAlert = {false, false, twtAlertStr};
struct alertStruct fwtAlert = {false, false, fwtAlertStr};
struct alertStruct rdgAlert = {false, false, rdgAlertStr};
struct alertStruct battAlert = {false, false, battAlertStr};
struct alertStruct psiAlert = {false, false, psiAlertStr};
boolean ledOn = false;

//this keeps track of timeouts for web commands
struct webCmdTimerStruct {
        struct timerStruct timeStamp;
        unsigned int timeout;
        prog_char *opStr;
        prog_char *msgStr;
        prog_char *packetStr;
        unsigned short stateReq; //temp variable for the requested state to set if we get a valveOp=# or modeOp=#
        char pongList[32];
        bool wrap;
} webCmdTimer;
        
