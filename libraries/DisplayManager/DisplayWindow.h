#ifndef DisplayWindow_h
#define DisplayWindow_h

#include "WProgram.h"
#include <LiquidCrystal.h>
#include <avr/pgmspace.h>
#include "CppNewDelete.h"

#define TIMER_START 	unsigned long t = micros();
#define TIMER_STOP 		t = micros()-t;  Serial.print("Took: "); \
										 Serial.print(t, DEC); \
										 Serial.println(" micros.");

class DisplayManager;

class DisplayWindow {

	public:
	DisplayWindow(DisplayManager& manager) : 
	_id(nextID++), _manager(manager), _lines(manager._lines),
	_chars(manager._chars)
	{ _buffers = new String[_lines]; };
	virtual ~DisplayWindow();
	
	unsigned short getWindowID() { return _id; };
	
	protected:
	static unsigned short nextID;
	
	unsigned short _id;
	DisplayManager& _manager;
	String* _buffers;
	short _lines, _chars;
	
};

#endif