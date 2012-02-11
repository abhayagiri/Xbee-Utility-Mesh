int printDefaultData (struct turbineStruct *trbn, struct batteryStruct *batt, struct hydroWattsStruct *hydro, struct configStruct *cfg) {
        char buf[21];

        // Clear LCD screen to erase old text
        lcd.clear();

	// Show battery data first
	if (cfg->indexDefault == 0 || cfg->indexDefault == 1) {
	        sprintf(buf,"Battery");
	        lcd.setCursor(0, 0);
	        lcd.print(buf);
	
	        if (cfg->indexDefault == 0) {
	                sprintf(buf,"V: %s HV: %s",batt->volts,batt->hourVolts);
	                lcd.setCursor(0, 1);
	                lcd.print(buf);
	        }
	        if (cfg->indexDefault == 1) {
	                sprintf(buf,"Curr. Load: %d",batt->watts);
	                lcd.setCursor(0, 1);
	                lcd.print(buf);
	        }
	}

	// Next show turbine data
	if (cfg->indexDefault == 2) {
	        sprintf(buf,"Turbine");
	        lcd.setCursor(0, 0);
	        lcd.print(buf);
	
	        sprintf(buf,"VLV:%s PSI:%d",trbn->valves,trbn->psi);
	        lcd.setCursor(0, 1);
	        lcd.print(buf);
	}

	// Next show hydro watts data
	if (cfg->indexDefault == 3) {
	        sprintf(buf,"Hydro Electric");
	        lcd.setCursor(0, 0);
	        lcd.print(buf);
	
	       	sprintf(buf,"Watts: %d",hydro->watts);
	        lcd.setCursor(0, 1);
	        lcd.print(buf);
	}

        // increment page index for battery and return the code 2
        // if we reset the index counter to 0 (letting the program know
        // we have finished displaying battery room data
        cfg->indexDefault++;
        if (cfg->indexDefault == 4 || (cfg->indexDefault == 3 && !USE_HydroWatts)) {
                cfg->indexDefault = 0;
                return 2;
        }

        return 0;
}


int printTankData (struct tankStruct *t, struct configStruct *cfg) {
	// Buffer to construct display string into
	char buf[21];

	// Clear LCD screen to erase old text
	lcd.clear();

	sprintf(buf,"Tank: %s",
				t[cfg->indexTank].id);
	lcd.setCursor(0, 0);
	lcd.print(buf);

	sprintf(buf,"Level: %d",
				t[cfg->indexTank].level);
	lcd.setCursor(0, 1);
	lcd.print(buf);
	
	// increment page index for tanks and return the code 2
	// if we reset the index counter to 0 (letting the program know
	// we have finished displaying water tank data
	cfg->indexTank++;
	if (cfg->indexTank == TANK_NUM) {
		cfg->indexTank = 0;
		return 2;
	}

	return 0;
}

int printTurbineData (struct turbineStruct *t, struct configStruct *cfg) {
        char buf[21];

        // Clear LCD screen to erase old text
        lcd.clear();

        lcd.setCursor(0, 0);
        sprintf(buf,"Valves: %s",t->valves);
        lcd.print(buf);

        sprintf(buf,"PSI: %d",t->psi);
        lcd.setCursor(0, 1);
        lcd.print(buf);

        // increment page index for batterter and return the code 2
        // if we reset the index counter to 0 (letting the program know
        // we have finished displaying batterter room data
        cfg->indexTurbine++;
        if (cfg->indexTurbine == 1) {
                cfg->indexTurbine = 0;
                return 2;
        }

        return 0;
}


int printBatteryData (struct batteryStruct *batt, struct configStruct *cfg) {
	char buf[21];

        // Clear LCD screen to erase old text
        lcd.clear();

	sprintf(buf,"Battery Data");
	lcd.setCursor(0, 0);
	lcd.print(buf);

	if (cfg->indexBattery == 0) {
	        sprintf(buf,"V: %s HV: %s",batt->volts,batt->hourVolts);
	        lcd.setCursor(0, 1);
	        lcd.print(buf);
	}
	if (cfg->indexBattery == 1) {
	        //sprintf(buf,"W: %d S: %d",batt->watts,batt->status);
		sprintf(buf,"Curr. Load: %d",batt->watts);
	        lcd.setCursor(0, 1);
	        lcd.print(buf);
	}

	// increment page index for battery and return the code 2
	// if we reset the index counter to 0 (letting the program know
	// we have finished displaying battery room data
	cfg->indexBattery++;
	if (cfg->indexBattery == 2) {
		cfg->indexBattery = 0;
		return 2;
	}

        return 0;
}

int printHydroWattsData (struct hydroWattsStruct *hW, struct configStruct *cfg) {
        char buf[21];

        // Clear LCD screen to erase old text
        lcd.clear();

        lcd.setCursor(0, 0);
        sprintf(buf,"Hydro Watts");
        lcd.print(buf);

        sprintf(buf,"%d",hW->watts);
        lcd.setCursor(0, 1);
        lcd.print(buf);

        // increment page index for batterter and return the code 2
        // if we reset the index counter to 0 (letting the program know
        // we have finished displaying batterter room data
        cfg->indexHydroWatts++;
        if (cfg->indexHydroWatts == 1) {
                cfg->indexHydroWatts = 0;
                return 2;
        }

        return 0;
}

