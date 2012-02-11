// This is the variable millis() uses.
// Resetting it to 0 starts millis over.
// Useful since we will be tracking hours/minutes/seconds in a struct
// function "resetMillis" in the Timer.pde ("Timer" tab) resets it
extern volatile unsigned long timer0_millis;  

void resetMillis() {
	timer0_millis = 0; 
	return;
}

unsigned long timePast(struct timerStruct *t, struct timerStruct *stmp) {
    unsigned long tmp =     ((t->day*86400)
                                     +(t->hour*3600)
                                     +(t->min*60)
                                     +(t->sec)
                            )
                           -((stmp->day*86400)
                                     +(stmp->hour*3600)
                                     +(stmp->min*60)
                                     +(stmp->sec)
                            );
    return tmp;
}

// Convert time difference to minutes
void timePastStr(struct timerStruct *t, struct timerStruct *stmp, char *buf) {
    unsigned long tmp =     ((t->day*86400)
                                     +(t->hour*3600)
                                     +(t->min*60)
                                     +(t->sec)
                            )
                           -((stmp->day*86400)
                                     +(stmp->hour*3600)
                                     +(stmp->min*60)
                                     +(stmp->sec)
                            );
    unsigned int m = tmp/60;
    sprintf(buf, "%dm", m);
}

int updateTimer(struct timerStruct *t) {

	if ((loopMillis = millis()) > nextSecond) {
		//resetMillis();
		nextSecond += 1000;
                t->sec++;
		t->justOverflowed = true;
	} else {
		t->justOverflowed = false;
                return 0;
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
