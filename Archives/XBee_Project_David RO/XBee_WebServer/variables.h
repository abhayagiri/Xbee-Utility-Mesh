// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0, 200 };

// Minutes to wait until data is deemed old enough to warrent a warning
#define MINUTES_UNTIL_OLD    10
// Number of display modes for LCD
#define DISPLAY_MODES	2
// Size of array for storing recieved serial data
#define BUF_SIZE  128
// Number of entries that can be recieved over serial
#define KEYS_MAX 16
// Max size of each entry
#define ENT_SIZE 16
// Number of water tanks
#define	TANK_NUM 3
// Length of id string that comes from remote source (ie: INV, TWT, FWT)
#define ID_LENGTH 4	// Remember actual length is one less due to zero
			// termination of strings


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
