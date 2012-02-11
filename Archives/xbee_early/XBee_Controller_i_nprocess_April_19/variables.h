// Size of array for storing recieved serial data
#define BUF_SIZE 128
// Number of entries that can be recieved over serial
#define KEYS_MAX 16
// Max size of each entry
#define ENT_SIZE 16
// Number of water tanks
#define	TANK_NUM 2

// Tank enumation
#define	TWT	0
#define	FWT	1

// Macro to calculate size of array
#define LENGTH(a,t)	((sizeof(a))/(sizeof(t)))

// Used to keep track of which type of data to display;
int displayCounter = 0;

struct timerStruct {
	unsigned long day;
	int hour;
	int min;
	int sec;
	bool justOverflowed;
};
struct timerStruct timer = {0,0,0,0};

// Structure type for holding recently received data
struct dataStruct {
	char key[ENT_SIZE];
	char val[ENT_SIZE];
};

// Structure for water tank data
struct tankStruct {
	char id[4];	// Three bytes for XBee ID, 4th byte is null termination
	int level;
} tanks[TANK_NUM];

// Structure for inverter room data
struct inverterStruct {
	char id[4];	// Three bytes for XBee ID, 4th byte is null termination
	int status;
	char volts[6];
	char hourVolts[6];
	// Arduino sprintf doesn't print floats
	//float hourVolts;
	//float volts;
	int watts;
} inverter;

struct packetStruct{
    char str[BUF_SIZE];
    struct dataStruct data[KEYS_MAX];
};
packetStruct rx = { };
