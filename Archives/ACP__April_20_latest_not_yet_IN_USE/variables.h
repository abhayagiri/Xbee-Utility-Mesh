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


// Structure type for holding recently received data
struct dataStruct {
	char key[ENT_SIZE];
	char val[ENT_SIZE];
};


struct packetStruct{
	char str[BUF_SIZE];
	struct dataStruct data[KEYS_MAX];
};
packetStruct rx = { };
