#include "PSTRUtils.h"
#include <avr/pgmspace.h>
#include "WProgram.h"

String& pstrAssign(String& str, const prog_char* pstr) {
  str = "";
  while (pgm_read_byte(pstr) != 0x00)
    str += (char)(pgm_read_byte(pstr++));
  return str;
}

String& pstrAppend(String& str, const prog_char* pstr) {
  while (pgm_read_byte(pstr) != 0x00)
    str += (char)(pgm_read_byte(pstr++));
  return str;
}

String pstrToString(const prog_char* pstr) {
	int charNum = 0;
	char c;
	String str;

	while ( (c = (char)pgm_read_byte(pstr+charNum)) != '\0') {
		str += c;
		charNum++;
	}
	return str;
}
