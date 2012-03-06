// Save data from temporary packet buffer (rx.data) and store in a special
// struct for hydro inverter data
int saveHydroWattsData(struct hydroWattsStruct *hW, struct dataStruct d[]) {
	strlcpy(hW->id,getDataVal(d,"XB"),4);
	hW->watts = atoi(getDataVal(d,"W"));
        hW->kwhToday = atof(getDataVal(d,"T"));
        hW->kwhYesterday = atof(getDataVal(d,"Y"));
	hW->timeStamp = timer; // save current time to calculate difference later
	return 0;
}


// Save data from temporary packet buffer (rx.data) and store in a special
// struct for water tank data
int saveTankData(int tankID, struct dataStruct d[]) {
	struct tankStruct *t = &tanks[tankID];

        strlcpy(t->id,getDataVal(d,"XB"),4);
	t->level = atoi(getDataVal(d,"LVL"));
	t->timeStamp = timer; // save current time to calculate difference later

        struct alertStruct *tankAlert = alerts[tankID];
        if (t->level <= 2 && !tankAlert->active) { //alert!
          tankAlert->active = true;
          tankAlert->dismissed = false;
          tankAlert->timeStamp = timer;
        } else if (t->level > 2) 
          tankAlert->active = false;
          
	return 0;
}

// Save data from temporary packet buffer (rx.data) and store in a special
// struct for Turbine data
int saveTurbineData(struct turbineStruct *t, struct dataStruct d[]) {
	strlcpy(t->id,getDataVal(d,"XB"),4);
	strlcpy(t->valves,getDataVal(d,"V"),5);
	t->psi = atoi(getDataVal(d,"P"));
        
        //get controlmode and 'testing' flag
        char *modeStr = getDataVal(d,"M");
        if ( (modeStr[0] == '0' || modeStr[0] == '1') &&
             (modeStr[1] == '0' || modeStr[1] == '1')) {
          t->controlMode = modeStr[0] - '0';
          t->testing = modeStr[1] - '0';
        }
        
	t->timeStamp = timer; // save current time to calculate difference later
        
        if (t->psi <= 155 && !psiAlert.active) { //alert!
          psiAlert.active = true;
          psiAlert.dismissed = false;
          psiAlert.timeStamp = timer;
        } else if (t->psi > 155) 
          psiAlert.active = false;
	
        return 0;
}

// Save data from temporary packet buffer (rx.data) and store in a special
// struct for battery room data
int saveBatteryData(struct batteryStruct *batt, struct dataStruct d[]) {
	strlcpy(batt->id,getDataVal(d,"XB"),4);
	batt->status = atoi(getDataVal(d,"S"));
	strlcpy(batt->volts,getDataVal(d,"V"),6);
	strlcpy(batt->hourVolts,getDataVal(d,"H"),6);
	batt->watts = atof(getDataVal(d,"L"));
	batt->timeStamp = timer; // save current time to calculate difference later
        
        if (batt->status < 0 && !battAlert.active) { //alert!
          battAlert.active = true;
          battAlert.dismissed = false;
          battAlert.timeStamp = timer;
        } else if (batt->status >= 0) 
          battAlert.active = false;
  
	return 0;

}

// Takes a string of the format "A=B,X=Y,C=D" and puts it into
// the multidimensional array d.
int parseData(struct dataStruct *d, char *s) {
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
