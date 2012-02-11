#include <LiquidCrystal.h>
#include "variables.h"


LiquidCrystal lcd(15,12,16,17,18,10); 

void setup () {
    Serial.begin (9600);
    lcd.begin (20,4);
    pinMode (mRelay1,OUTPUT);
    pinMode (mRelay2,OUTPUT);
    pinMode (va, OUTPUT);
    pinMode (vb, OUTPUT);
    pinMode (vc, OUTPUT);
    pinMode (ledA, OUTPUT);
    pinMode (ledB, OUTPUT);
    pinMode (ledC, OUTPUT);
}


void loop ()  { 
    unsigned long startHoursLowWater2 = millis();
    adjValve (va, CLOSE);
    adjValve (vb, CLOSE);
    adjValve (vc, CLOSE);
    lcd.clear();

    while ((millis()-startHoursLowWater2) < 5600000){ 
        lcd.clear();
        lcd.setCursor (0,0);
        lcd.print("Time left = ");
        lcd.print((5600000-millis())/60);
        delay (1500);
    }
    adjValve (va, OPEN);
    delay (270000);
    adjValve (vc, OPEN); 
    unsigned long startHoursLowWater = millis();
    lcd.clear();
    while ((millis()-startHoursLowWater) < 2600000){ 
        lcd.setCursor (0,1);
        lcd.print("Time left = ");
        lcd.print((2600000-millis())/60);
        delay (1500);
    }
}


