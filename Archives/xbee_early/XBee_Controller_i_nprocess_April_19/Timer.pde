// This is the variable millis() uses.
// Resetting it to 0 starts millis over.
// Useful since we will be tracking hours/minutes/seconds in a struct
// function "resetMillis" in the Timer.pde ("Timer" tab) resets it
extern volatile unsigned long timer0_millis;  

void resetMillis() {
	timer0_millis = 0; 
	return;
}


int updateTimer(struct timerStruct *t) {

	if (millis() > 1000) {
		resetMillis();
		t->sec++;
		t->justOverflowed = true;
	} else {
		t->justOverflowed = false;
	}

	if (t->sec == 60) {
		t->sec = 0;
		t->min++;
	}

	if (t->min == 60) {
		t->min = 0;
		t->hour++;
	}

	if (t->hour == 24) {
		t->hour = 0;
		t->day++;
	}

	return 0;
}
