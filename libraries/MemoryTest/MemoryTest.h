#ifndef MemoryTest_h
#define MemoryTest_h


#include <avr/pgmspace.h>
#include "WProgram.h"

//PROGMEM string printing functions

void print_p(char *msg);
void println_p(char *msg);

void printMemoryProfile(unsigned long delayMillis);

#endif