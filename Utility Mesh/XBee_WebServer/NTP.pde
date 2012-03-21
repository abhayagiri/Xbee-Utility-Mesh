int setTimeViaNTP() {
  
  //flush anything still in the buffer
  while(Udp.available()) {
    Udp.readPacket(packetBuffer,NTP_PACKET_SIZE);
  }

  sendNTPpacket(timeServer);
  
  unsigned long waitTime = 500 + millis(); //wait 500 millis for response
  while(!Udp.available() && millis() < waitTime)
    ;
  
  if(Udp.available()) { //set time if we got a response
    Udp.readPacket(packetBuffer,NTP_PACKET_SIZE);  // read the packet into the buffer
    //the timestamp starts at byte 40 of the received packet and is four bytes,
    // or two words, long. First, esxtract the two words:
    unsigned long highWord = word(packetBuffer[40], packetBuffer[41]);
    unsigned long lowWord = word(packetBuffer[42], packetBuffer[43]);  
    // combine the four bytes (two words) into a long integer
    // this is NTP time (seconds since Jan 1 1900 in UTC):
    unsigned long secsSince1900 = highWord << 16 | lowWord;

    timer.hour = ((secsSince1900  % 86400L) / 3600) - 8;
    timer.min = (secsSince1900  % 3600) / 60;
    timer.sec = (secsSince1900 %60);
    
    timeSet = true;
    return 0; //got it!
  }
  return -1; //didn't get it!
}

//taken from Udp NTP Client
unsigned long sendNTPpacket(byte *address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE); 
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49; 
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;

  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp: 		   
  Udp.sendPacket( packetBuffer,NTP_PACKET_SIZE,  address, 123); //NTP requests are to port 123
}

