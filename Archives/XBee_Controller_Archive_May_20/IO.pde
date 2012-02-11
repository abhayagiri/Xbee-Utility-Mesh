// Read buttons states into button structure
int readButtons(struct buttonStruct *b) {
	b->a1 = digitalRead(A0);	// Non catching state 1
	b->a2 = digitalRead(A1);	// Non catching state 2
	b->b1 = digitalRead(A2);	// Catching state 1
	b->b2 = digitalRead(A3);	// Catching state 2
	return 0;
}

// this function cycles through the different display modes
int switchDisplayMode(struct configStruct *cfg, struct buttonStruct *b, struct buttonStruct *bLast, int numOfModes) {

	// Cycle through the modes
	if (b->a1 && !bLast->a1)
		(cfg->displayMode)++;
	if (b->a2 && !bLast->a2)
		(cfg->displayMode)--;
	if (cfg->displayMode == numOfModes)
		(cfg->displayMode) = 0;
	if (cfg->displayMode < 0)
		(cfg->displayMode) = numOfModes-1;

	// Indicate to main program that mode has changed
	cfg->dispModeSwitched = true;

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
