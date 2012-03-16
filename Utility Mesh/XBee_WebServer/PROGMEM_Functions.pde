void printEther_p (Client client, prog_char *str) {
  while (pgm_read_byte(str) != 0x00) {
     if (debugMode)
       Serial.print(pgm_read_byte(str)); 
     client.print(pgm_read_byte(str++)); 
  }
}

void printlnEther_p (Client client, prog_char *str) {
  printEther_p (client, str);
  if (debugMode)
    Serial.print('\n');
  client.print('\n');
}

void printEther_p(Client client, unsigned int numArgs, ...)
{
  va_list args;
  
  va_start(args, numArgs);
  for (int i=0; i < numArgs; i++)
    printEther_p(client, va_arg(args, prog_char*));
  va_end(args);
}

//void printEther_p(Client client, prog_char *strs[])
//{
//  Serial.println(sizeof(strs));
//  for (int i=0; i < 3; i++)
//    printEther_p(client, strs[i]);
//    
//}

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
