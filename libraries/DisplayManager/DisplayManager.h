#ifndef DisplayManager_h
#define DisplayManager_h

#include "WProgram.h"
#include <LiquidCrystal.h>
#include <avr/pgmspace.h>
#include "CppNewDelete.h"

#define TIMER_START 	unsigned long t = micros();
#define TIMER_STOP 		t = micros()-t;  Serial.print("Took: "); \
										 Serial.print(t, DEC); \
										 Serial.println(" micros.");


class DisplayWindow;
										 
class DisplayManager {
  
	friend class DisplayWindow;
	
	public:
	//ctors/dtors
    DisplayManager(short lines, short chars, short pins[6], short backlightPin=-1) :
	_lcd(pins[0], pins[1], pins[2], pins[3], pins[4], pins[5]),
	_blPin(backlightPin), _begun(false), _lines(lines), _chars(chars),
	_numWindows(0), _curWindow(-1)
	{ 
		_workingBuffers = new String[_lines];
		_liveBuffers = new String[_lines];
		setBacklightPin(_blPin); 
	};
	
	virtual ~DisplayManager() { delete[] _liveBuffers; delete[] _workingBuffers; };
    
	//Utility Methods
	void begin();
    LiquidCrystal& getLCDObject();
	short getBacklightPin();
	void setBacklightPin(short backlightPin);
	void backlightOn();
	void backlightOff();
	void setBacklightState(bool state);
	bool getBacklightState();
	
	//Printing methods
	void print(const String& str, short lineNum);
	void print(const char* str, short lineNum);
	void printPstr(const prog_char* pstr, short lineNum);
    void print(const String& line1, const String& line2);
    void print(const char* line1, const char* line2);
	void printAt(const char* str, short lineNum, short colNum);
	void printAt(const String& str, short lineNum, short colNum);
	void printPstrAt(const prog_char* pstr, short lineNum, short charNum);
	void append(const char* str, short lineNum);
	void append(const String& str, short lineNum);
	void appendPstr(const prog_char* pstr, short lineNum);
	void printAtEnd(const char* str, short lineNum);
	void printAtEnd(const String& str, short lineNum);
	void printPstrAtEnd(const prog_char* pstr, short lineNum);
	void appendAtEnd(const char* str, short lineNum);
	void appendAtEnd(const String& str, short lineNum);
	void appendPstrAtEnd(const prog_char* pstr, short lineNum);
	DisplayWindow& newWindow();
	DisplayWindow& getCurrentWindow() { return *_windows[_curWindow]; };
	void showWindow(DisplayWindow& window);
	
	protected:
    LiquidCrystal _lcd;
	DisplayWindow* _windows[10];
	String* _workingBuffers;
	String* _liveBuffers;
	short _blPin;
	short _lines, _chars;
    bool _begun;
	short _numWindows, _curWindow;
	
	int getRow(int lineNum);
	int getCol(int charNum);
	String& getBuffer(int lineNum);
	void commit(short lineNum, bool pad);
	String pstrToString(const prog_char* pstr);
	int countTrailingSpaces(const String &str);
};

#endif
