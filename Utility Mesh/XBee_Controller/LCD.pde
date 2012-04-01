int updateDisplay (struct configStruct *cfg, struct timerStruct *t, struct turbineStruct *trbn, 
                        struct hydroWattsStruct *hydro, struct batteryStruct *batt, struct tankStruct *tanks) {
  lcd.clear();
  switch (cfg->displayMode) {
    case 0:
      printDefaultScreen(cfg, t, trbn, hydro, batt);
      break;
    case 1:
      printTurbineMenu();
      break;
    case 2:
      printTankScreen(cfg, t, tanks);
      break;
  }
}

void printDefaultScreen (struct configStruct *cfg, struct timerStruct *t, struct turbineStruct *trbn, struct hydroWattsStruct *hydro, struct batteryStruct *batt) {
  char line1[17];
  char line2[17];
  char tmpStr[17];
   
  switch (cfg->indexDefault) {
    case 0: //turbine/watts data
      //line 1
      //TODO: use older timestamp after hydro is up and running
      //get older of two timestamps
      //if (timePast(t, &(trbn->timeStamp)) > timePast(t, &(hydro->timeStamp)))
        
      //else
      //  timePastStr(t, &(hydro->timeStamp), tmpStr);
      if (trbn->mode == 0) {
        sprintf(tmpStr, "auto");
      } else if (trbn->mode == 1) {
        sprintf(tmpStr, "man");
      } else sprintf(tmpStr, "?");
      sprintf(line1, "Vs:%s%s", trbn->valves, tmpStr);
      timePastStr(t, &(trbn->timeStamp), tmpStr);
      appendToEnd(line1, tmpStr, 16);
      //line 2
      sprintf(line2, "PSI:%03d", trbn->psi);
      sprintf(tmpStr, "W:%04d", hydro->watts);
      appendToEnd(line2, tmpStr, 16);
      //print them thar' lines
      print2lines(line1, line2);
      break;
    case 1: //battery data
      //line 1
      timePastStr(t, &(batt->timeStamp), tmpStr);
      sprintf(line1, "Load:%04dw", batt->watts);
      appendToEnd(line1, tmpStr, 16);
      //line 2
      sprintf(line2, "V:%s", batt->volts);
      sprintf(tmpStr, "HA:%s", batt->hourVolts);
      appendToEnd(line2, tmpStr, 16);
      //print 'em up
      print2lines(line1, line2);
      break;
    default:
      lcd.setCursor(0,0);
      lcd.print("Er: indexDefault");
      lcd.setCursor(0,1);
      sprintf(line1, "bad value: %d", cfg->indexDefault);
      lcd.print(line1);
      break;
  }
}

void printTurbineMenu() {
  lcd.clear(); lcd.print("Set: ");
  
  switch (trbCmd.cmdType) {
    case Mode:
      lcd.print("mode");
      lcd.setCursor(0,1); lcd.print("To: ");
      switch(trbCmd.cmdValue) {
        case 0: lcd.print("MANUAL"); break;
        case 1: lcd.print("AUTO"); break;
      }
      break;
    case ValveState:
      lcd.print("valves");
      lcd.setCursor(0,1); lcd.print("To: ");
      switch(trbCmd.cmdValue) {
        case 0: lcd.print("NONE"); break;
        case 1: lcd.print("A"); break;
        case 2: lcd.print("C"); break;
        case 3: lcd.print("AC"); break;
        case 4: lcd.print("B"); break;
        case 5: lcd.print("AB"); break;
        case 6: lcd.print("BC"); break;
        case 7: lcd.print("ABC"); break;
      }
      break;
  }
  
  lcd.setCursor(14,1); lcd.print("OK");  
  switch (trbCmd.currField) {
    case 0: lcd.setCursor(5,0); break;
    case 1: lcd.setCursor(4,1); break;
    case 2: lcd.setCursor(14,1); break;
  }
  lcd.blink();
}

void turbineMenuButtonHandler(struct buttonStruct *btns, struct buttonStruct *btnsLast) {
  unsigned char field = trbCmd.currField; //easier to type...
  boolean printMenu = true;
  
  if  (trbCmd.cmdState) { //cancel send on any a-button
    trbCmd.cmdState = NotSending;
    lcd.clear(); lcd.print("Cmd Canceled");
    config.pauseCounter = 2;
    trbCmd.currField = 0;
    printMenu = false;
  }  

  else if (btnsLast->a1) { //otherwise, do menu change on button press
    unsigned char modulus = 0;
    switch (field) {
      case 0:
        if (trbCmd.cmdType == ValveState) {
          trbCmd.cmdType = Mode;
          trbCmd.cmdValue = max(0,turbine.mode); //catch the -9 initial state
        }
        else trbCmd.cmdType = ValveState;
        break;
      case 1:
        if (trbCmd.cmdType == Mode) modulus = 2;
        if (trbCmd.cmdType == ValveState) modulus = 8;
        trbCmd.cmdValue += 1;
        trbCmd.cmdValue %= modulus;
        break;
      case 2:
        trbCmd.cmdState = Sending;
        valveCommandTimer = 120; //try for two min. max
        config.pauseCounter = 2; //hold the display
        //sendValveComand(); //send the packet
        lcd.clear(); lcd.print("Sending");
        lcd.blink();
        printMenu = false;
        break;
    }
  }
  else if (btnsLast->a2) {
    trbCmd.currField += 1; //next field
    trbCmd.currField %= 3;
  }
  
  if (printMenu) printTurbineMenu();
  
}

void printTankScreen(struct configStruct *cfg, struct timerStruct *t, struct tankStruct *tanks) { //takes array of tank structs
  char line1[17];
  char line2[17];
  char tmpStr[17];
  struct tankStruct tank=tanks[cfg->indexTank];
  
  timePastStr(t, &(tank.timeStamp), tmpStr);
  sprintf(line1, "Tank: %s", tank.id);
  appendToEnd(line1, tmpStr, 16);
  //line 2
  sprintf(line2, "Level: %d", tank.level);
  //itoa(pkts, tmpStr, 10);
  //appendToEnd(line2, tmpStr, 16);
  //print them thar' lines
  print2lines(line1, line2);
}


//int printDefaultData (struct turbineStruct *trbn, struct batteryStruct *batt, struct hydroWattsStruct *hydro, struct configStruct *cfg, struct timerStruct *t) {
//        char buf[386];
//        char minPast[64];
//        int err = 0;
//
//        // Clear LCD screen to erase old text
//        lcd.clear();
//
//	// Show battery data first
//	if (cfg->indexDefault == 0 || cfg->indexDefault == 1) {
//                // Get minutes since current data was received
//                timePastStr(t,&(batt->timeStamp), minPast);
//                // If it is so many minutes old or more, display a warning
//                if ( minPast >= MINUTES_UNTIL_OLD ) {
//                    sprintf(buf,"Batt:");
//                    appendToEnd(buf, minPast, 16);
//                }      
//                else
//                    sprintf(buf,"Battery");
//
//	        lcd.setCursor(0, 0);
//	        lcd.print(buf);
//	
//	        if (cfg->indexDefault == 0) {
//	                sprintf(buf,"V: %s HV: %s",batt->volts,batt->hourVolts);
//	                lcd.setCursor(0, 1);
//	                lcd.print(buf);
//	        }
//	        if (cfg->indexDefault == 1) {
//	                sprintf(buf,"Cur. Load: %d",batt->watts);
//	                lcd.setCursor(0, 1);
//	                lcd.print(buf);
//	        }
//	}
//
//	// Next show turbine data
//	if (cfg->indexDefault == 2) {
//                timePastStr(t,&(batt->timeStamp), minPast);
//                // If it is so many minutes old or more, display a warning
//                if ( minPast >= MINUTES_UNTIL_OLD ) {
//                    sprintf(buf,"Trbn:");
//                    appendToEnd(buf, minPast, 16);
//                }
//                else
//	            sprintf(buf,"Turbine");
//	        lcd.setCursor(0, 0);
//	        lcd.print(buf);
//	
//	        sprintf(buf,"VLV:%s PSI:%d",trbn->valves,trbn->psi);
//	        lcd.setCursor(0, 1);
//	        lcd.print(buf);
//	}
//
//	// Next show hydro watts data
//	if (cfg->indexDefault == 3) {
//                   // Get minutes since current data was received
//                timePastStr(t,&(hydro->timeStamp), minPast);
//                // If it is so many minutes old or more, display a warning
//                if ( minPast >= MINUTES_UNTIL_OLD ) {
//                    sprintf(buf,"Hydro:");
//                    appendToEnd(buf, minPast, 16);
//                }
//                else
//        	    sprintf(buf,"Hydro Electric");
//	        lcd.setCursor(0, 0);
//	        lcd.print(buf);
//	
//	       	sprintf(buf,"Watts: %d",hydro->watts);
//	        lcd.setCursor(0, 1);
//	        lcd.print(buf);
//	}
//
//        // increment page index for battery and return the code 2
//        // if we reset the index counter to 0 (letting the program know
//        // we have finished displaying battery room data
//        cfg->indexDefault++;
//        if (cfg->indexDefault == 4 || (cfg->indexDefault == 3 && !USE_HydroWatts)) {
//                cfg->indexDefault = 0;
//                return 2;
//        }
//
//        return 0;
//}
//
//
//int printTankData (struct tankStruct *tnk, struct configStruct *cfg, struct timerStruct *t) {
//	// Buffer to construct display string into
//	char buf[386];
//        char minPast[64];
//
//        // Get minutes since current data was received
//        timePastStr(t,&(tnk->timeStamp), minPast);
//
//	// Clear LCD screen to erase old text
//	lcd.clear();
//
//        // If it is so many minutes old or more, display a warning
//        if ( minPast >= MINUTES_UNTIL_OLD ) {
//            sprintf(buf,"Tank: %s",tnk->id);
//            appendToEnd(buf, minPast, 16);
//        }
//        else
//	    sprintf(buf,"Tank: %s",
//				tnk->id);
//	lcd.setCursor(0, 0);
//	lcd.print(buf);
//
//	sprintf(buf,"Level: %d",
//				tnk->level);
//	lcd.setCursor(0, 1);
//	lcd.print(buf);
//	
//	// increment page index for tanks and return the code 2
//	// if we reset the index counter to 0 (letting the program know
//	// we have finished displaying water tank data
//	cfg->indexTank++;
//	if (cfg->indexTank == TANK_NUM) {
//		cfg->indexTank = 0;
//		return 2;
//	}
//
//	return 0;
//}
//
//int printTurbineData (struct turbineStruct *t, struct configStruct *cfg) {
//        char buf[21];
//
//        // Clear LCD screen to erase old text
//        lcd.clear();
//
//        lcd.setCursor(0, 0);
//        sprintf(buf,"Valves: %s",t->valves);
//        lcd.print(buf);
//
//        sprintf(buf,"PSI: %d",t->psi);
//        lcd.setCursor(0, 1);
//        lcd.print(buf);
//
//        // increment page index for batterter and return the code 2
//        // if we reset the index counter to 0 (letting the program know
//        // we have finished displaying battery room data
//        cfg->indexTurbine++;
//        if (cfg->indexTurbine == 1) {
//                cfg->indexTurbine = 0;
//                return 2;
//        }
//
//        return 0;
//}
//
//
//int printBatteryData (struct batteryStruct *batt, struct configStruct *cfg) {
//	char buf[21];
//
//        // Clear LCD screen to erase old text
//        lcd.clear();
//
//	sprintf(buf,"Battery Data");
//	lcd.setCursor(0, 0);
//	lcd.print(buf);
//
//	if (cfg->indexBattery == 0) {
//	        sprintf(buf,"V: %s HV: %s",batt->volts,batt->hourVolts);
//	        lcd.setCursor(0, 1);
//	        lcd.print(buf);
//	}
//	if (cfg->indexBattery == 1) {
//	        //sprintf(buf,"W: %d S: %d",batt->watts,batt->status);
//		sprintf(buf,"Curr. Load: %d",batt->watts);
//	        lcd.setCursor(0, 1);
//	        lcd.print(buf);
//	}
//
//	// increment page index for battery and return the code 2
//	// if we reset the index counter to 0 (letting the program know
//	// we have finished displaying battery room data
//	cfg->indexBattery++;
//	if (cfg->indexBattery == 2) {
//		cfg->indexBattery = 0;
//		return 2;
//	}
//
//        return 0;
//}
//
//int printHydroWattsData (struct hydroWattsStruct *hW, struct configStruct *cfg) {
//        char buf[21];
//
//        // Clear LCD screen to erase old text
//        lcd.clear();
//
//        lcd.setCursor(0, 0);
//        sprintf(buf,"Hydro Watts");
//        lcd.print(buf);
//
//        sprintf(buf,"%d",hW->watts);
//        lcd.setCursor(0, 1);
//        lcd.print(buf);
//
//        // increment page index for batterter and return the code 2
//        // if we reset the index counter to 0 (letting the program know
//        // we have finished displaying batterter room data
//        cfg->indexHydroWatts++;
//        if (cfg->indexHydroWatts == 1) {
//                cfg->indexHydroWatts = 0;
//                return 2;
//        }
//
//        return 0;
//}

//Append newString to dest, with intervening whitespace
//for total length len
int appendToEnd (char *dest, char *newString, int lenTotal) {
        int spaces = 0;
        int lenDest = strlen(dest);
        int lenNewString = strlen(newString);
        
        if ( lenDest>lenTotal || (lenDest + lenNewString) > lenTotal ) { //error
          printInfo("err: appendToEnd", "input to long", 5);
          return 1;
        }
        else
          spaces = lenTotal - (lenDest + lenNewString);
          for (int i=0; i<spaces; i++)
            strcat(dest, " ");
          strcat(dest, newString);
          
        return 0;
}

int appendToEnd (char *dest, char c, int lenTotal) {
        int spaces = 0;
        int lenDest = strlen(dest);
        int lenNewString = 1;
        
        char newString[2];
        newString[0] = c;
        newString[1] = '\0';
        
        if ( lenDest>lenTotal || (lenDest + lenNewString) > lenTotal ) { //error
          printInfo("err: appendToEnd", "input to long", 5);
          return 1;
        }
        else
          spaces = lenTotal - (lenDest + lenNewString);
          for (int i=0; i<spaces; i++)
            strcat(dest, " ");
          strcat(dest, newString);
          
        return 0;
}

void print2lines(char *line1, char *line2) {
  lcd. clear();
  lcd.setCursor(0,0);
  lcd.print(line1);
  lcd.setCursor(0,1);
  lcd.print(line2);
}

void printInfo (char *line1, char *line2, int pauseSecs) {
        print2lines(line1, line2);
        config.dispChanged = true;
        config.pauseCounter = pauseSecs;
}
