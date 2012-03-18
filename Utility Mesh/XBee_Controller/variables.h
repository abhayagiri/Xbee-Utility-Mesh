// Minutes to wait until data is deemed old enough to warrent a warning
#define MINUTES_UNTIL_OLD    0
// Number of display modes for LCD
#define DISPLAY_MODES	3
//Backlight timer - seconds on
#define BACKLIGHT_TIME 60
// Size of array for storing recieved serial data
#define BUF_SIZE 128
// Number of entries that can be recieved over serial
#define KEYS_MAX 8
// Max size of each entry
#define ENT_SIZE 8
// Number of water tanks
#define	TANK_NUM 3
// Length of id string that comes from remote source (ie: INV, TWT, FWT)
#define ID_LENGTH 4	// Remember actual length is one less due to zero
			// termination of strings
#define NUM_PING_RESPONDERS 7 //number of units that respond to ping packets

#define PONG_STALE_TIME 4000ul //millis till a pong falls off the list

// Turbine Error Limit (if watt reading from Upper Water Shed fall too far
// there is probably a problem with the turbine)
#define WATTS_ERROR_LEVEL	40
bool hydroError = false;

// Tank enumation
#define	TWT	0
#define	FWT	1
#define RDG	2

// Macro to calculate size of array
#define LENGTH(a,t)	((sizeof(a))/(sizeof(t)))

// struct used to keep track of which type of data to display;
struct configStruct {
	int displayMode; // current type of data to display
			// 0 = default - batt & turbine data
			// 1 = Valve control mode
                        // 2 = Tank data mode
                        // 3 = ping mode
	int pauseCounter;
	bool	dispChanged;
        bool    diagMode;
	int indexDefault;       //0=battery display; 1=turbine display
	int indexTank; 		// tank to display data for
	int indexBattery;	// section of battery data to display
	int indexTurbine;	// section of the hydro program data to display
	int indexHydroWatts;
} config = {0,0,false,false,0,0,0,0,0};

unsigned long int nextSecond = 1000; //used to implement local timekeeping
unsigned long int loopMillis = 0; //used to keep number of calls to millis() per loop down
struct timerStruct {
	unsigned long day;
	int hour;
	int min;
	int sec;
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
} tanks[TANK_NUM];

// Structure for water tank data
struct turbineStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	char valves[5];		// holds valve status
	int psi;		// holds turbine psi
        char mode;
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
} turbine;

//Structure for valve operation data
struct valveOpStruct {
  char id[ID_LENGTH];
  
  char valve[2];
  char op[6];
} valveOp;

// Structure for water tank data
struct hydroWattsStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int watts;		// holds watts produced by hydro
        float kwhToday;
        float kwhYesterday;
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
} hydroWatts;


// Structure for battery room data
struct batteryStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int status;
	char volts[6];
	char hourVolts[6];
	// Arduino sprintf doesn't print floats
	//float hourVolts;
	//float volts;
	int watts;
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
} battery;

struct packetStruct{
	char str[BUF_SIZE];
	struct dataStruct data[KEYS_MAX];
};
packetStruct rx = { };

struct buttonStruct {
	int a1;
	int a2;
	int b1;
	int b2;
} button = {0,0,0,0}, buttonLast = {0,0,0,0};

short backlightTimer = BACKLIGHT_TIME;

bool pingMode = false;
bool blightPersistMode = false;
unsigned int buttonTimer = 0;
unsigned int pingButtonTimer = 0;
unsigned int blightButtonTimer = 0;

struct pongTimer {
    char id[ID_LENGTH];
    bool heardFrom;
    unsigned long int staleTime;
} pongTimers[] = {"TRB",false,0, "TWT",false,0, "FWT",false,0, "RDG",false,0,
                  "SNA",false,0, "VST",false,0, "GTS",false,0};
char pongLine1[17]="", pongLine2[17] = "";
short numPongTimers = sizeof(pongTimers)/sizeof(struct pongTimer);

char elipsis[4] = "   ";   // moving elipsis for valve control wait screens
char progStr[5] = ".  ";
char progressor = progStr[0];
unsigned long int progressTimer = 500; //next time to change the prog timer
short progStrLength = strlen(progStr);
short progressIndex = 0;

int valveCommandState = 0; // controls valve command display sequence:
                           // 0 - nothing happening
                           // 1/2 - send open command, awaiting response(s)
                           // 3/4 - send close command, awaiting response(s)
                           // 5/6 - received individual valve op info, waiting on more or final AWK
                           // 7/8 - final AWK received
                           // 9/10 - automatic valve operation received
                           // odd states - not printed to display yet
                           // even sates - info printed, waiting on state change
                           
//unsigned long int pkts = 0; //total # packets processed
