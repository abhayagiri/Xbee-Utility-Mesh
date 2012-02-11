#include "WProgram.h"
#include "DisplayManager.h"
#include "DisplayWindow.h"
#include <LiquidCrystal.h>
#include <avr/pgmspace.h>
#include "CppNewDelete.h"

#define TIMER_START 	unsigned long t = micros();
#define TIMER_STOP 		t = micros()-t;  Serial.print("Took: "); \
										 Serial.print(t, DEC); \
										 Serial.println(" micros.");

