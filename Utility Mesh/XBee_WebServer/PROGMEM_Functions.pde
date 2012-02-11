void printEther_p (Client client, const char *str) {
  while (pgm_read_byte(str) != 0x00) {
     if (debugMode)
       Serial.print(pgm_read_byte(str)); 
     client.print(pgm_read_byte(str++)); 
  }
}

void printlnEther_p (Client client, const char *str) {
  while (pgm_read_byte(str) != 0x00) {
     if (debugMode)
       Serial.print(pgm_read_byte(str)); 
     client.print(pgm_read_byte(str++)); 
  }
  if (debugMode)
    Serial.println("");
  client.println("");
}

void debugPrint_p(char *msg) {
  if (debugMode)
    while (pgm_read_byte(msg) != 0x00)
      Serial.print(pgm_read_byte(msg++));
}

void debugPrintln_p(char *msg) {
  if (debugMode) {
    while (pgm_read_byte(msg) != 0x00)
      Serial.print(pgm_read_byte(msg++));
  
    Serial.println("");
  }
}
