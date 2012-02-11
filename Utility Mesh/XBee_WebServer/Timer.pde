// This is the variable millis() uses.
// Resetting it to 0 starts millis over.
// Useful since we will be tracking hours/minutes/seconds in a struct
// function "resetMillis" in the Timer.pde ("Timer" tab) resets it
extern volatile unsigned long timer0_millis;  

void resetMillis() {
	timer0_millis = 0; 
	return;
}

// Convert time difference in seconds to string for LCD display
// in Days, Hours, Minutes, Seconds
char *timePastStr(char *str, struct timerStruct *t, struct timerStruct *stmp) {
    unsigned long tmp =     ((t->day*86400ul)
                                     +(t->hour*3600)
                                     +(t->min*60)
                                     +(t->sec)
                            )
                           -((stmp->day*86400)
                                     +(stmp->hour*3600)
                                     +(stmp->min*60)
                                     +(stmp->sec)
                            );
    int s = tmp%60;
    tmp = tmp/60;
    int m = tmp%60;
    tmp = tmp/60;
    int h = tmp%24;
    long d = tmp/24;
    
    sprintf(str,"%02ldd%02dh%02dm%02ds",d,h,m,s);
    return str;
}

// Convert time difference to minutes
unsigned long timePastMinutes(struct timerStruct *t, struct timerStruct *stmp) {
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
    unsigned long m = tmp/60;
    return m;
}

unsigned long timePastSeconds(struct timerStruct *t, struct timerStruct *stmp) {
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
