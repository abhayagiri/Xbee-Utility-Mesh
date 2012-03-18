int incrementMode(int mode, int numModes) {
    mode++;
    if (mode >= numModes)
        mode = 0;
    return mode;
}

int decrementMode(int mode, int numModes) {
    mode--;
    if (mode <= -1)
        mode = numModes-1;
    return mode;
}

// Read buttons states into button structure
int readButtons(struct buttonStruct *b) {
    //debounce the non-catching buttons
    if (b->a1 != digitalRead(A0)) { // Non catching state 1
        delay(10); 
        b->a1=digitalRead(A0); 
    }    
    if (b->a2 != digitalRead(A1)) {	// Non catching state 2
        delay(10); 
        b->a2=digitalRead(A1);
    }
    b->b1 = digitalRead(A2);	// Catching state 1
    b->b2 = digitalRead(A3);	// Catching state 2

    return 0;
}

// this function cycles through the different display modes
int setDisplayMode(struct configStruct *cfg, struct buttonStruct *b, struct buttonStruct *bLast, int numOfModes) {

    // Change main display modes when button state changes
    if ((!b->b1 && !b->b2) && !(!bLast->b1 && !bLast->b2)) { //switched to mode 0 - center position
        cfg->displayMode = 0;
        cfg->dispChanged = true;
    }
    else if (b->b1 && !bLast->b1) { //switched to mode 1 - top position
        cfg->displayMode = 1;
        cfg->dispChanged = true;
    }
    else if (b->b2 && !bLast->b2) { //switched to mode 2 - bottom position
        cfg->displayMode = 2;
        cfg->dispChanged = true;
    }

    //deal with the rocker button - 
    //only on button-up to keep long button press
    //functions from triggering screen changes
    if ( ((!b->a1 && bLast->a1) || (!b->a2 && bLast->a2)) &&
          buttonTimer < 5000 &&
          !pingMode) { 
        switch (cfg->displayMode) { //increment subdisplay index
        case 0: //2 subdisplays for default - batt and turbine
            if (b->a1) //increment?
                cfg->indexDefault = incrementMode(cfg->indexDefault,2);
            else //must be decrement
            cfg->indexDefault = decrementMode(cfg->indexDefault,2);
            break;
        case 1: //no subdisplays for vave control mode
            break;
        case 2:
            if (b->a1) //increment?
                cfg->indexTank = incrementMode(cfg->indexTank,3);
            else //must be decrement
            cfg->indexTank = decrementMode(cfg->indexTank,3);
            break;
        } 
        cfg->dispChanged = true;
    } 
    return 0;
}

// Error function for hydro project run if a problem with the hydro
// electric system is detected
int hydroErrorLED(long w) {
    if (millis() < 500)
        ledColor("ALL");
    else
        ledColor("RED");
    return 0;
}

// Update the multicolor LED based on the battery status
int updateStatusLED(int s, struct timerStruct *t) {
    switch (s) {
    case -3:
        if (millis() < 500)
            ledColor("RED");
        else
            ledColor("OFF");
        break;
    case -2:
        if (t->sec % 2)
            ledColor("RED");
        else
            ledColor("OFF");
        break;
    case -1:
        ledColor("RED");
        break;
    case 0:
        ledColor("BLUE");
        break;
    case 1:
        ledColor("GREEN");
        break;
    default:
        ledColor("OFF");
        break;
    }

}


// Change multi color LED's color
int ledColor(char *color) {
    if (strcmp(color,"BLUE") == 0) {
        digitalWrite(LED_1,HIGH);
        digitalWrite(LED_2,HIGH);
        digitalWrite(LED_3,LOW);
    }
    if (strcmp(color,"GREEN") == 0) {
        digitalWrite(LED_1,HIGH);
        digitalWrite(LED_2,LOW);
        digitalWrite(LED_3,HIGH);
    }
    if (strcmp(color,"RED") == 0) {
        digitalWrite(LED_1,LOW);
        digitalWrite(LED_2,HIGH);
        digitalWrite(LED_3,HIGH);
    }
    if (strcmp(color,"ALL") == 0) {
        digitalWrite(LED_1,LOW);
        digitalWrite(LED_2,LOW);
        digitalWrite(LED_3,LOW);
    }
    if (strcmp(color,"OFF") == 0) {
        digitalWrite(LED_1,HIGH);
        digitalWrite(LED_2,HIGH);
        digitalWrite(LED_3,HIGH);
    }
    return 0;
}

