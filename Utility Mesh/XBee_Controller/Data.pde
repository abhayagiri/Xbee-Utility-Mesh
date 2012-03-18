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
int saveTankData(struct tankStruct *t, struct dataStruct d[]) {
	strlcpy(t->id,getDataVal(d,"XB"),4);
	t->level = atoi(getDataVal(d,"LVL"));
	t->timeStamp = timer; // save current time to calculate difference later
	return 0;
}

// Save data from temporary packet buffer (rx.data) and store in a special
// struct for Turbine data
int saveTurbineData(struct turbineStruct *t, struct dataStruct d[]) {
	strlcpy(t->id,getDataVal(d,"XB"),4);
	strlcpy(t->valves,getDataVal(d,"V"),5);
	t->psi = atoi(getDataVal(d,"P"));
        
        char *modeTmp = getDataVal(d,"M"); //sends 2 bits, one for auto/manual and one for testing state
        if (modeTmp[0] == '0' || modeTmp[0] == '1') //we just need the 1st bit for now
          t->mode = modeTmp[0] - '0';
	
        t->timeStamp = timer; // save current time to calculate difference later
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
	return 0;

}

//saves valve operation packet data and manages valveCommandState variable used for printing info on pending valve commands.
void handleValveOpPacket (struct dataStruct d[]) {
  if (strcmp(getDataVal(rx.data,"PT"),"VOP") == 0) {
    if (valveCommandState > 0) {
      valveCommandState = 5;
      strlcpy(valveOp.valve, getDataVal(d,"VLV"),2);
      strlcpy(valveOp.op, getDataVal(d,"OP"),6);
    }
    else 
      valveCommandState = 7; //placeholder state for non-manual valve op packets
  }
  else if (strcmp(getDataVal(rx.data,"PT"),"AWK") == 0) {
    if (valveCommandState > 0)
      valveCommandState = 9;
    else
      printInfo("Unexpected AWK", "from turbine.", 10);
  }
}

void handlePongPacket ( struct dataStruct d[]) {
    if (pingMode && keyExists(d, "XB")){ //don't bother if not in ping mode
        unsigned long int staleTime = (loopMillis + PONG_STALE_TIME);
        int i = 0;
        char *id = getDataVal(d,"XB");
        
        //find the id we received, reset the stale time so its not stale
        for (i=0; i<numPongTimers && pongTimers[i].id != NULL; i++) {
            if (strcmp(id, pongTimers[i].id) == 0) {
                pongTimers[i].staleTime = staleTime;
                pongTimers[i].heardFrom = true;
            }
        }
        
        if (i<numPongTimers) {
          strlcpy(pongTimers[i].id, id, ID_LENGTH);
          pongTimers[i].staleTime = staleTime;
          pongTimers[i].heardFrom = true;
        }
  }
}

//void handlePongPacket( struct dataStruct d[]) {
//  if (keyExists(d, "XB")){
//    boolean foundMatch = false;
//    char *name = getDataVal(d,"XB");
//    int endOfList = 0;
//    int i = 0;
//    
//    for (i=0; i<MAX_PONGS; i++) {
//      if (strcmp(pongList[i],name) == 0)
//        foundMatch = true;
//      if (pongList[i][0] != '\0')
//        endOfList += 1;
//    }
//    if (!foundMatch && endOfList < MAX_PONGS)
//      strlcpy(pongList[endOfList],name,4);
//  }
//}

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
