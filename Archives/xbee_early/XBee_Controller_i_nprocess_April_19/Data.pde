// Save data from temporary packet buffer (rx.data) and store in a special
// struct for water tank data
int saveTankData(struct tankStruct *t, struct dataStruct d[]) {
	strlcpy(t->id,getDataVal(d,"XB"),4);
	t->level = atoi(getDataVal(d,"LVL"));
	return 0;
}

// Save data from temporary packet buffer (rx.data) and store in a special
// struct for inverter room data
int saveInverterData(struct inverterStruct *inv, struct dataStruct d[]) {
	strlcpy(inv->id,getDataVal(d,"XB"),4);
	inv->status = atoi(getDataVal(d,"S"));
	// Arduino sprintf doesn't print floats
	//inv->volts = atof(getDataVal(d,"V"));
	//inv->hourVolts = atof(getDataVal(d,"H"));
	strlcpy(inv->volts,getDataVal(d,"V"),6);
	strlcpy(inv->hourVolts,getDataVal(d,"H"),6);
	inv->watts = atof(getDataVal(d,"L"));
	return 0;

}

// Takes a string of the format "A=B,X=Y,C=D" and puts it into
// the multidimensional array d.
int parseData(struct dataStruct d[KEYS_MAX], char s[BUF_SIZE]) {
	char *p,*t;
	int i,j;
	// Initialize d to 0
	for (i=0;i<KEYS_MAX;i++) {
		memset(d[i].key,'\0',ENT_SIZE);
		memset(d[i].val,'\0',ENT_SIZE);
	}

	// Seperate sets of key=val from each other
	i = 0;
	t = strtok(s,",");
	while (t) {
		if (t)
			strlcpy(d[i].key, t, ENT_SIZE);
		t = strtok(NULL,",");
		i++;
	}
	// We will return the number of keys
	int ret = i;

	for (i=0;i<KEYS_MAX;i++) {
		j = 0;
		t = strtok(d[i].key,"=");
		while (t) {
			if (j == 0)
				strlcpy(d[i].key, t, ENT_SIZE);
			else if (j==1)
				strlcpy(d[i].val, t, ENT_SIZE);
			t = strtok(NULL,"=");
			j++;
		}
	}
	return ret;
}

// Function for looking up a value by it's key name ie:
//		getDataVal(data,"S")
// will return a pointer to the string associated with the key "S"
// so if data sent from xbee contains "S=-1" it will contain the
// string "-1".	Be warned it doesn't return a number so if the
// value you want is an integer remember to use getDataVal like so:
//		atoi(getDataVal(data,"V"))
// and if it is a floating point (decimal) number like so:
//		atof(getDataVal(data,"V"))
char* getDataVal (struct dataStruct d[KEYS_MAX], char *key) {
	for (int i = 0; i < KEYS_MAX; i++) {
		if (!strcmp(d[i].key,key))
			return d[i].val;
	}
	return "NULL";
}


// similar to getDataVal except it just returns true
// if the key exists or false if it doesn't
bool keyExists (struct dataStruct d[KEYS_MAX], char *key) {
	for (int i = 0; i < KEYS_MAX; i++) {
		if (!strcmp(d[i].key,key))
			return true;
	}
	return false;
}
