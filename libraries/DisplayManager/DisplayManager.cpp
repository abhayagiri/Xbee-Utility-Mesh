///////////////////////////////////////////////////////////
//Display Implementation
///////////////////////////////////////////////////////////
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


/////////////////////
//Utility Functions//
/////////////////////
//Must be called in arduino setup, not before!
void DisplayManager::begin() {
	if (!this->_begun)
	{
		_lcd.begin(_chars, _lines); 
		_begun = true;
	}	
}

LiquidCrystal& DisplayManager::getLCDObject() { return _lcd; }

short DisplayManager::getBacklightPin() { return _blPin; }

void DisplayManager::setBacklightPin(short backlightPin) {
    if (backlightPin > -1) {
		_blPin = backlightPin;
		pinMode(_blPin, OUTPUT);
		digitalWrite(_blPin, LOW);
	}
}

void DisplayManager::backlightOn() {
    if (_blPin > 0)
        digitalWrite(_blPin, HIGH);
}

void DisplayManager::backlightOff() {
	if (_blPin > 0)
		digitalWrite(_blPin, LOW);
}

bool DisplayManager::getBacklightState() { return digitalRead(_blPin); }

void DisplayManager::setBacklightState(bool state) 
{ if (_blPin>0) digitalWrite(_blPin, state); }

int DisplayManager::getRow(int lineNum) { return max(0, min(_lines-1, lineNum-1)); } 

int DisplayManager::getCol(int charNum) { return max(0, min(_chars-1, charNum-1)); } 

String& DisplayManager::getBuffer(int lineNum) 
{ return _workingBuffers[getRow(lineNum)]; }

void DisplayManager::commit(short lineNum, bool pad=false) {
	String &currStr = _liveBuffers[getRow(lineNum)];
	const String &newStr = getBuffer(lineNum);
	short row = getRow(lineNum);
	short len = newStr.length();
	
	for (int i=0; i<len && i<_chars; i++)
		if (currStr[i] != newStr[i]) {
			_lcd.setCursor(i, row);
			_lcd.print(newStr[i]);
		}
	if (pad) {
		_lcd.setCursor(len,row);
		for (int i=len; i<_chars; i++) 
			_lcd.print(' ');
	}
	
	currStr = newStr;
}

String DisplayManager::pstrToString(const prog_char* pstr) {
	int charNum = 0;
	char c;
	String str;

	while ( (c = (char)pgm_read_byte(pstr+charNum)) != '\0' && charNum < _chars) {
		str += c;
		charNum++;
	}
	return str;
}

int DisplayManager::countTrailingSpaces(const String &str) {
	int spaces = 0;
	int loc = str.length()-1;
	while (str[loc] == ' ' && loc >= 0) { spaces++; loc--;}
	return spaces;
}

////////////////////
//Window Functions//
////////////////////
DisplayWindow& DisplayManager::newWindow(bool show=false;) {
	_windows[_numWindows++] = new DisplayWindow(*this); 
	if ()
		_cur
	return *_windows[_curWindow+1];
}




///////////////////
//Print Functions//
///////////////////

void DisplayManager::print(const String& str, short lineNum=1) {
	String &buf = getBuffer(lineNum);
	buf = str.substring(0,_chars);
	
	commit(lineNum, true);
}

void DisplayManager::print(const char* str, short lineNum=1) 
{ print(String(str), lineNum); }

void DisplayManager::printPstr(const prog_char* pstr, short lineNum=1) 
{ print(pstrToString(pstr), lineNum); }

void DisplayManager::print(const String& line1, const String& line2) { 
	this->print(line1, 1);
	this->print(line2, 2);
}

void DisplayManager::print(const char* line1, const char* line2) {
	this->print(line1, 1);
	this->print(line2, 2);
}

void DisplayManager::append(const String &str, short lineNum) {
	String& buf = getBuffer(lineNum);
	int origLength = buf.length();
	int charsLeft = _chars - origLength;
	if (charsLeft > 0) {
		buf+=str.substring(0,charsLeft);
		commit(lineNum);
	}
}

void DisplayManager::append(const char* str, short lineNum) 
{ append(String(str), lineNum); }
	

void DisplayManager::appendPstr(const prog_char* pstr, short lineNum) 
{ append(pstrToString(pstr), lineNum); }

void DisplayManager::printAt(const String &str, short lineNum, short charNum) {
	short row = getRow(lineNum);
	short printCol = getCol(charNum);

	if (row < _lines && printCol < _chars) {
		String &buf = getBuffer(lineNum);
		int len = str.length();
		while (buf.length() < min(_chars, printCol+str.length()))
			buf+=' ';
		for (int i=0; i<min(_chars-printCol,str.length()); i++)
			buf[i+printCol]=str[i];
		commit(lineNum);
	}
}

void DisplayManager::printAt(const char* str, short lineNum, short charNum)
{ printAt(String(str), lineNum, charNum); }

void DisplayManager::printPstrAt(const prog_char* pstr, short lineNum, short charNum)
{ printAt(pstrToString(pstr), lineNum, charNum); }

void DisplayManager::printAtEnd(const String& str, short lineNum) 
{ printAt(str, lineNum, _chars-str.length()+1); }

void DisplayManager::printAtEnd(const char* str, short lineNum) 
{ printAtEnd(String(str), lineNum); }

void DisplayManager::printPstrAtEnd(const prog_char* pstr, short lineNum) 
{ printAtEnd(pstrToString(pstr), lineNum); }

void DisplayManager::appendAtEnd(const String& str, short lineNum) {
	short charsLeft = _chars - getBuffer(lineNum).length();
	charsLeft += countTrailingSpaces(getBuffer(lineNum));
	if (charsLeft) {
		if (charsLeft < str.length())//any room?
			printAtEnd(str.substring(str.length()-charsLeft), lineNum);
		else
			printAtEnd(str, lineNum);
	}
}

void DisplayManager::appendAtEnd(const char* str, short lineNum) 
{ appendAtEnd(String(str), lineNum); }

void DisplayManager::appendPstrAtEnd(const prog_char* pstr, short lineNum) 
{ appendAtEnd(pstrToString(pstr), lineNum); }
