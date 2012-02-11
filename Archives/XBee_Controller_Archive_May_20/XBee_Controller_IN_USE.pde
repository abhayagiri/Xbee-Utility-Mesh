#include <stdio.h>
#include <string.h>
#include <LiquidCrystal.h>
#include "variables.h"

// Roamer (LilyPad) Controller
LiquidCrystal lcd(7,6,5,4,3,2);
// MUB (Duemilanove) Controller
//LiquidCrystal lcd(2,3,4,5,6,7);


void setup() {
	// LED pins
	pinMode(LED_1,OUTPUT);
	pinMode(LED_2,OUTPUT);
	pinMode(LED_3,OUTPUT);


	// Using pin 13 to power backlight of LCD so must be high
	pinMode(13,OUTPUT);
	digitalWrite(13,HIGH);

	// Startup LCD screen for display
	lcd.begin(16, 2);

	/*	Initialize all data to to keep garbage data out of array
		and to set sane defaults.					*/
	// start with serial receive buffer
	for (int i = 0; i < KEYS_MAX; i++) {
		memset(rx.data[i].key,'\0',ENT_SIZE);
		memset(rx.data[i].val,'\0',ENT_SIZE);
	}
	// tank structs next
	for (int i = 0; i < TANK_NUM; i++) {
		memset(tanks[i].id,'\0',ID_LENGTH);
		tanks[i].level = -9;	// -9 default since it is out of range of
					// possible values for water tank levels
	}
	// battery struct next
	memset(battery.id,'\0',ID_LENGTH);
	battery.status = -9;	// -9 because it is out of range of used values for status
	memset(battery.volts,'\0',ID_LENGTH);
	memset(battery.hourVolts,'\0',ID_LENGTH);
	battery.watts = -9;	// -9 is an impossible value so use it as default
	// and make sure hydro wattage starts at an impossible level
	hydroWatts.watts = -1;

	// Make sure lcd doesn't change modes on startup
	config.dispModeSwitched = false;

	// Start serial port at 9600 bps, used for getting data from XBee
	Serial.begin(9600);
}

void loop() {

	// Read buttons and act based on their states, save last button states too
	buttonLast = button;
	readButtons(&button);
        // Turbine setting for buttons
	if	(button.b1 && (button.a1 || button.a2))
		sendButtons(&config, &button, &buttonLast, XBEE, "TRB");
        // Ridge setting for buttons (change RDG to another ID if you want)
	else if	(button.b2 && (button.a1 || button.a2))
		sendButtons(&config, &button, &buttonLast, XBEE, "RDG");
	else if (!button.b1 && !button.b2 && (button.a1 || button.a2))
		switchDisplayMode(&config,&button,&buttonLast,DISPLAY_MODES);

	// run unpdate time function
	updateTimer(&timer);

	// Set hydro program error flag
	if (hydroWatts.watts < WATTS_ERROR_LEVEL && hydroWatts.watts >= 0)
		hydroError = true;
	else {
		hydroError = false;
	}

	//----------STATUS LED------------//
	// Upper Hydro Shed Watt production checking
	// LED will signal error if it drops below 300 watts
	if (hydroError)
		hydroErrorLED(hydroWatts.watts);
	// Otherwise just show the same status as Sauna LEDs
	else
		updateStatusLED(battery.status, &timer);

	//----------LCD SCREEN-----------//
	// reprint LCD every 2 many seconds
	if (hydroError && !config.pauseCounter) {
		if (timer.justOverflowed) {
			lcd.clear();
			lcd.setCursor(0,0);
			if (timer.sec%2)
				lcd.print("   EMERGENCY");
			else
				lcd.print("TURBINE FAILURE");
		}
	}
	else if (((timer.sec%4 == 0 && timer.justOverflowed) || config.dispModeSwitched) && !config.pauseCounter ) {
		// reset display mode changed flag
		if (config.dispModeSwitched)
			config.dispModeSwitched = false;
		int ret;
		switch (config.displayMode) {
			case 0:
				printDefaultData(&turbine,&battery,&hydroWatts,&config);
				break;
			case 1:
				printTankData(tanks,&config);
				break;

			default:
				//config.displayMode++;
				break;
		}
		// Reset current display index if it is greater than the largest "case"
		if (config.displayMode > 3)
			config.displayMode = 0;
	}
	

	//------------Serial Data-----------//
	if (!getSerialData(rx.str)) {
		parseData(rx.data,rx.str);
		// Make sure this transmission includes a packet type and
		// XB identification tag
		if (keyExists(rx.data,"PT") && keyExists(rx.data,"XB")) {
			// Check if it is an "ACK" (Acknowlegment) packet
			if (strcmp(getDataVal(rx.data,"PT"),"AWK") == 0) {
				// If it was and is for Turbine
				if (strcmp(getDataVal(rx.data,"XB"),"TRB") == 0) {
				if (strcmp(getDataVal(rx.data,"DST"),XBEE) == 0) {
					char buf[20];
					lcd.clear();
					lcd.setCursor(0,0);
					sprintf(buf,"Msg from: %s",getDataVal(rx.data,"XB"));
					lcd.print(buf);
					lcd.setCursor(0,1);
					lcd.print("Command Received");
					config.pauseCounter = 15;
				}
				}
			}

			// Check for and save any Tank data
			if (strcmp(getDataVal(rx.data,"PT"),"TNK") == 0) {
				if (strcmp(getDataVal(rx.data,"XB"),"TWT") == 0)
					saveTankData(&tanks[TWT],rx.data);
				if (strcmp(getDataVal(rx.data,"XB"),"FWT") == 0)
					saveTankData(&tanks[FWT],rx.data);
				if (strcmp(getDataVal(rx.data,"XB"),"RDG") == 0)
					saveTankData(&tanks[RDG],rx.data);
			}

			// Check for and save any Turbine data
			if (strcmp(getDataVal(rx.data,"PT"),"TRB") == 0) {
				if (strcmp(getDataVal(rx.data,"XB"),"TRB") == 0) {
					saveTurbineData(&turbine,rx.data);
				}
			}

			// Check for and save any Battery data
			if (strcmp(getDataVal(rx.data,"PT"),"PWR") == 0) {
				if (strcmp(getDataVal(rx.data,"XB"),"SNA") == 0)
					saveBatteryData(&battery,rx.data);
			}

			// Check for and save any Battery data
			if (strcmp(getDataVal(rx.data,"PT"),"WTT") == 0) {
				if (strcmp(getDataVal(rx.data,"XB"),"UWS") == 0)
					saveHydroWattsData(&hydroWatts,rx.data);
			}
		}
	}

	// count down until menu unpauses after command send or awknowledged
	if (config.pauseCounter && timer.justOverflowed) 
		config.pauseCounter--;
}
