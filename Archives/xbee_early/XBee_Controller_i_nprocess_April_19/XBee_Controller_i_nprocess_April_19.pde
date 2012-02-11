#include <stdio.h>
#include <string.h>
#include <LiquidCrystal.h>
#include "variables.h"

LiquidCrystal lcd(7, 8, 9, 10, 11, 12);

void setup() {
	// Startup LCD screen for display
	lcd.begin(16, 2);

	//	Initialize all data to 0 to keep garbage data out of array
	for (int i = 0; i < KEYS_MAX; i++) {
		memset(rx.data[i].key,'\0',ENT_SIZE);
		memset(rx.data[i].val,'\0',ENT_SIZE);
	}

	// remember to zero tank and inverter structs too here:

	// Start serial port at 9600 bps, used for getting data from XBee
	Serial.begin(9600);

	// LED Output Pins
	pinMode(11, OUTPUT);
	pinMode(12, OUTPUT);
	pinMode(13, OUTPUT);
}

void loop() {

	// run unpdate time function
	updateTimer(&timer);
	// reprint LCD every 2 many seconds
	if (timer.sec%2 == 0 && timer.justOverflowed) {
		switch (displayCounter) {
			case 0:
			case 1:
				printTankData(tanks,displayCounter);
				break;
			case 2:
				printInverterData(&inverter);
				break;
			default:
				break;
		}
		displayCounter++;
		if (displayCounter == LENGTH(tanks,struct tankStruct) + LENGTH(inverter,struct inverterStruct))
			displayCounter = 0;
	}

	if (!getSerialData(rx.str)) {
		parseData(rx.data,rx.str);
		// Make sure this transmission includes a packet type and
		// XB identification tag
		if (keyExists(rx.data,"PT") && keyExists(rx.data,"XB")) {

			if (strcmp(getDataVal(rx.data,"PT"),"TNK") == 0) {
				if (strcmp(getDataVal(rx.data,"XB"),"TWT") == 0)
					saveTankData(&tanks[TWT],rx.data);
				if (strcmp(getDataVal(rx.data,"XB"),"FWT") == 0)
					saveTankData(&tanks[FWT],rx.data);
			}

			if (strcmp(getDataVal(rx.data,"PT"),"PWR") == 0) {
				if (strcmp(getDataVal(rx.data,"XB"),"INV") == 0)
					saveInverterData(&inverter,rx.data);
			}
		}
	}
}
