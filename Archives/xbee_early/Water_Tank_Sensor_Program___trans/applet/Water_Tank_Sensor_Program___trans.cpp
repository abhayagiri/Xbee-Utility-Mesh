#include "WProgram.h"
void setup();
void loop ();
int cona = 1;
int conb = 2;
int conc = 3;
int cond = 4;
int vala=0;
int valb=0;
int valc=0;
int vald=0;
int shortcount = 0;
int medcount = 0;
int longcount = 0;
int state = 0;
int currentTime = 0;
int counter = 0;

void setup(){
  Serial.begin (9600);
  pinMode (cona, INPUT);
  pinMode (conb, INPUT);
  pinMode (conc, INPUT);
  pinMode (cond, INPUT);
}

void loop (){
  for (int shortcount=0; shortcount <= 20; shortcount++){
    vala = digitalRead (cona);    //    digital read the 4 sensors
    valb = digitalRead (conb);
    valc = digitalRead (conc);
    vald = digitalRead (cond);

    if (vala = HIGH){            //    if any sensor reads HIGH, set the state accordingly
      state = 1;  
    }
    if (valb = HIGH){
      state = 2;  
    }
    if (valc = HIGH){
      state = 3;  
    }
    if (vald = HIGH){
      state = 4;  
    }
  }
  Serial.print (counter);
  delay (300); // delay 5 minutes
  counter++;
  if (counter==24) {              //    if two hours have passed (24 * 5 minutes)
    for (int i=0; i<=20;i++);
    Serial.println (state);        //     then print data serially
    counter=0;                   //     start the 2 hour counter over.
  }
  loop;
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

