//Main page - displays data from other XBee units
void printMainPage(Client client) {
  //see if we received at least one of the various packet types
  boolean gotBat, gotTrb, gotHydro, gotTwt, gotFwt, gotRdg;
  gotBat = !timeStampIsZero(battery.timeStamp);
  gotTrb = !timeStampIsZero(turbine.timeStamp);
  gotHydro = !timeStampIsZero(hydroWatts.timeStamp);
  gotTwt = !timeStampIsZero(tanks[TWT].timeStamp);
  gotFwt = !timeStampIsZero(tanks[FWT].timeStamp);
  gotRdg = !timeStampIsZero(tanks[RDG].timeStamp);

  // send a standard http response header
  printlnEther_p(client, PSTR("HTTP/1.1 200 OK"));
  printlnEther_p(client, PSTR("Content-Type: text/html"));
  client.println();
  // Page HTML goes here

  printlnEther_p(client, PSTR("<html><head><title>Abhayagiri XBee Utility Mesh</title>\n"));
  printEther_p(client,PSTR("<meta http-equiv=\"REFRESH\" content=\"30; url="));
  printEther_p(client, myUrl);
  client.print("\"/>\n");
  printlnEther_p(client, PSTR("<style type=\"text/css\">body {font-family:Verdana;} td {text-align:center; color:white;}</style>"));
  printlnEther_p(client, PSTR("</head>\n<body bgcolor=\"DarkGoldenRod\"><div align=center valign=middle>"));

  //open main table
  printlnEther_p(client, PSTR("<table cellspacing=15>"));

  //ping button
  printEther_p(client, PSTR("<tr valign=\"middle\"><td align=\"center\" valign=\"middle\"><form name=\"pingForm\""));
  printlnEther_p(client, PSTR(" action=\"/\" method=\"get\">"));
  printlnEther_p(client, PSTR("<input type=\"hidden\" name=\"ping\" value=\"send\" />"));
  printlnEther_p(client, PSTR("<input type=\"submit\" value=\"Send Ping\"/>"));
  printlnEther_p(client, PSTR("</form></td></tr>"));
  
  for (int i=0; i<NUM_ALERTS; i++) {
    if (alerts[i]->active && !alerts[i]->dismissed) {
      char timestr[32] = "";
      printlnEther_p(client, PSTR("<tr><td>"));
      printlnEther_p(client, PSTR("<table border=1 bgcolor=\"Red\" width=100%><tr><td><b>ALERT</b></td><td><b>"));
      client.print(timePastMinutes(&timer,&(alerts[i]->timeStamp)));
      printlnEther_p(client, (PSTR(" Minutes Old</b></td></tr>")));
      printlnEther_p(client, PSTR("<tr><td colspan=\"2\"><b>"));
      printlnEther_p(client, alerts[i]->alertString);
      printlnEther_p(client, PSTR("</b></td></tr>"));
      printlnEther_p(client, PSTR("</table></td>"));
      printEther_p(client, PSTR("<td align=\"center\" valign=\"middle\"><form name=\"dismissForm\""));
      printlnEther_p(client, PSTR(" action=\"/\" method=\"get\">"));
      printEther_p(client, PSTR("<input type=\"hidden\" name=\"dismiss\" value=\""));
      client.print(i+1); 
      printlnEther_p(client, PSTR("\"/>"));
      printlnEther_p(client, PSTR("<input type=\"submit\" value=\"Dismiss\"/>"));
      printlnEther_p(client, PSTR("</form></td></tr>"));
    } 
  }

  // Battery Info
  printlnEther_p(client, PSTR("<tr><td>"));
  printlnEther_p(client, PSTR("<table border=1 width=100%><tr><td><b>Battery</b></td><td><b>"));
  client.print(battery.dmin);
  printlnEther_p(client, (PSTR(" Minutes Old</b></td></tr>")));
  if (gotBat) { 
    printlnEther_p(client, PSTR("<tr><td>Voltage</td><td>"));
    client.print(battery.volts);
    printlnEther_p(client, PSTR("V</td></tr>"));
    printlnEther_p(client, PSTR("<tr><td>Hour Average</td><td>"));
    client.print(battery.hourVolts);
    printlnEther_p(client, PSTR("V</td></tr>"));
    printlnEther_p(client, PSTR("<tr><td>Load</td><td>"));
    client.print(battery.watts);
    printlnEther_p(client, PSTR("W</td></tr>"));
    printlnEther_p(client, PSTR("<tr><td>Status</td><td>"));
    client.print(battery.status);
    printlnEther_p(client, PSTR("</td></tr>"));
  } 
  else {
    printlnEther_p(client, PSTR("<tr><td colspan=\"2\">No Data Recieved</td></tr>"));
  }
  printlnEther_p(client, PSTR("</table></td></tr>"));


  // Turbine Info
  printlnEther_p(client, PSTR("<tr><td><table border=1 width=100%><tr><td><b>Turbine</b></td><td><b>"));
  client.print(turbine.dmin);
  client.println(" Minutes Old</b></td></tr>");
  if (gotTrb) {
    printEther_p(client, PSTR("<tr><td>Valves Open</td>"));
    printlnEther_p(client, PSTR("<td valign=\"middle\"><form name=\"valveSetForm\" action=\"/\" method=\"get\" style=\"height: 7px;\">"));
    printlnEther_p(client, PSTR("<select name=\"valveOp\" onChange=\"document.forms['valveSetForm'].submit()\">\n<option>"));
    client.print(turbine.valves); printlnEther_p(client, PSTR("</option>"));
    printlnEther_p(client, PSTR("<optgroup label=\"Set Valves\"><option value=0>None</option><option value=1>A</option>"));
    printlnEther_p(client, PSTR("<option value=2>C</option>\n<option value=3>AC</option>\n<option value=4>B</option>"));
    printlnEther_p(client, PSTR("<option value=5>AB</option>\n<option value=6>BC</option>\n<option value=7>ABC</option>"));
    printlnEther_p(client, PSTR("</optgroup></select></form>"));
    printlnEther_p(client, PSTR("</td></tr>"));
    printEther_p(client, PSTR("<tr><td>PSI</td><td>"));
    client.print(turbine.psi);
    printlnEther_p(client, PSTR("</td></tr>"));
    printEther_p(client, PSTR("<tr><td>Mode</td><td>"));
    (turbine.controlMode == 0 ? client.print("Auto") : client.print("Manual"));
    printlnEther_p(client, PSTR("</td></tr>"));    
  } 
  else {
    printEther_p(client, PSTR("<tr><td colspan=\"2\">"));
    printlnEther_p(client, PSTR("<form name=\"valveSetForm\" action=\"/\" method=\"get\" style=\"height: 7px;\">"));
    printlnEther_p(client, PSTR("<select name=\"valveOp\" onChange=\"document.forms['valveSetForm'].submit()\">"));
    printlnEther_p(client, PSTR("<option>No Data Received</option>"));
    printlnEther_p(client, PSTR("<optgroup label=\"Set Valves\"><option value=0>None</option><option value=1>A</option>"));
    printlnEther_p(client, PSTR("<option value=2>C</option>\n<option value=3>AC</option>\n<option value=4>B</option>"));
    printlnEther_p(client, PSTR("<option value=5>AB</option>\n<option value=6>BC</option>\n<option value=7>ABC</option>"));
    printlnEther_p(client, PSTR("</optgroup></select></form>"));
    printlnEther_p(client, PSTR("</td></tr>"));
  }
  printlnEther_p(client, PSTR("</table></td>"));
  //form for buttons
//  printlnEther_p(client, PSTR("<td><table><tr valign=\"middle\"><td align=\"center\" valign=\"middle\"><form name=\"valveOpenForm\" action=\"/\" method=\"get\">"));
//  printlnEther_p(client, PSTR("<input type=\"hidden\" name=\"valveOp\" value=\"open\"/>"));
//  printlnEther_p(client, PSTR("<input type=\"submit\" value=\"Step up\"/>"));
//  printlnEther_p(client, PSTR("</form></td></tr>"));
//
//  printlnEther_p(client, PSTR("<tr valign=\"middle\"><td align=\"center\" valign=\"middle\"><form name=\"valveCloseForm\" action=\"/\" method=\"get\">"));
//  printlnEther_p(client, PSTR("<input type=\"hidden\" name=\"valveOp\" value=\"close\"/>"));
//  printlnEther_p(client, PSTR("<input type=\"submit\" value=\"Step Down\"/>"));
//  printlnEther_p(client, PSTR("</form></td></tr>"));
  
//  printlnEther_p(client, PSTR("<td><table><tr valign=\"middle\"><td align=\"center\" valign=\"middle\"><form name=\"valveSetForm\" action=\"/\" method=\"get\">"));
//  printlnEther_p(client, PSTR("<select name=\"state\">\n<option value=0>None</option>\n<option value=1>A</option>"));
//  printlnEther_p(client, PSTR("<option value=2>C</option>\n<option value=3>AC</option>\n<option value=4>B</option>"));
//  printlnEther_p(client, PSTR("<option value=5>AB</option>\n<option value=6>BC</option>\n<option value=7>ABC</option>"));
//  printlnEther_p(client, PSTR("</select>\n<input type=\"submit\" value=\"Set\"/>"));
//  printlnEther_p(client, PSTR("</form></td></tr></table></td></tr>"));

  // Hydro Inverter Info
  printEther_p(client, PSTR("<tr><td><table border=1 width=100%><tr><td><b>Hydro Inverter</b></td><td><b>"));
  client.print(hydroWatts.dmin);
  client.println(" Minutes Old</b></td></tr>");
  if (gotHydro) {
    printEther_p(client, PSTR("<tr><td>Watts Produced</td><td>"));
    client.print(hydroWatts.watts);
    printlnEther_p(client, PSTR("</td></tr>"));
  }  
  else {
    printlnEther_p(client, PSTR("<tr><td colspan=\"2\">No Data Recieved</td></tr>"));
  }
  printlnEther_p(client, PSTR("</table></td></tr>"));

  // Tank Info
  // Two Water Tanks
  printEther_p(client, PSTR("<tr><td><table border=1 width=100%><tr><td><b>Two Water Tanks</b></td><td><b>"));
  client.print(tanks[TWT].dmin);
  printlnEther_p(client, PSTR(" Minutes Old</b></td></tr>"));
  if (gotTwt) {
    printEther_p(client, PSTR("<tr><td>Level</td><td>"));
    client.print(tanks[TWT].tankCap / numTankLevels * tanks[TWT].level, 0);
    printlnEther_p(client, PSTR(" gal.</td></tr>"));
  }  
  else {
    printlnEther_p(client, PSTR("<tr><td colspan=\"2\">No Data Recieved</td></tr>"));
  }
  printlnEther_p(client, PSTR("</table></td></tr>"));
  // Four Water Tanks
  printEther_p(client, PSTR("<tr><td><table border=1 width=100%><tr><td><b>Four Water Tanks</b></td><td><b>"));
  client.print(tanks[FWT].dmin);
  printlnEther_p(client, PSTR(" Minutes Old</b></td></tr>"));
  if (gotFwt) {
    printEther_p(client, PSTR("<tr><td>Level</td><td>"));
    client.print(tanks[FWT].tankCap / numTankLevels * tanks[FWT].level, 0);
    printlnEther_p(client, PSTR(" gal.</td></tr>"));
  }  
  else {
    printlnEther_p(client, PSTR("<tr><td colspan=\"2\">No Data Recieved</td></tr>"));
  }
  printlnEther_p(client, PSTR("</table></td></tr>"));
  // Ridge
  printEther_p(client, PSTR("<tr><td><table border=1 width=100%><tr><td><b>Ridge Water Tanks</b></td><td><b>"));
  client.print(tanks[RDG].dmin);
  printlnEther_p(client, PSTR(" Minutes Old</b></td></tr>"));
  if (gotRdg) {
    printEther_p(client, PSTR("<tr><td>Level</td><td>"));
    client.print(tanks[RDG].tankCap / numTankLevels * tanks[RDG].level, 0);
    printlnEther_p(client, PSTR(" gal.</td></tr>"));
  }  
  else {
    printlnEther_p(client, PSTR("<tr><td colspan=\"2\">No Data Recieved</td></tr>"));
  }
  printlnEther_p(client, PSTR("</table></td>"));
  //form for button
  printlnEther_p(client, PSTR("<td><table><tr valign=\"middle\"><td align=\"center\" valign=\"middle\"><form name=\"pumpOnForm\" action=\"/\" method=\"get\">"));
  printlnEther_p(client, PSTR("<input type=\"hidden\" name=\"pumpOp\" value=\"on\"/>"));
  printlnEther_p(client, PSTR("<input type=\"submit\" value=\"Pump On\"/>"));
  printlnEther_p(client, PSTR("</form></td></tr>"));

  printlnEther_p(client, PSTR("<tr valign=\"middle\"><td align=\"center\" valign=\"middle\"><form name=\"pumpOffForm\" action=\"/\" method=\"get\">"));
  printlnEther_p(client, PSTR("<input type=\"hidden\" name=\"pumpOp\" value=\"off\"/>"));
  printlnEther_p(client, PSTR("<input type=\"submit\" value=\"Pump Off\"/>"));
  printlnEther_p(client, PSTR("</form></td></tr></table></td></tr>"));

  for (int i=0; i<NUM_ALERTS; i++) {
    if (alerts[i]->active && alerts[i]->dismissed) {
      char timestr[32] = "";
      printlnEther_p(client, PSTR("<tr><td>"));
      printlnEther_p(client, PSTR("<table border=1 width=100% bgcolor=\"SandyBrown\"><tr><td><b>ALERT</b></td><td><b>"));
      client.print(timePastMinutes(&timer,&(alerts[i]->timeStamp)));
      printlnEther_p(client, (PSTR(" Minutes Old</b></td></tr>")));
      printlnEther_p(client, PSTR("<tr><td colspan=\"2\"><b>"));
      printlnEther_p(client, alerts[i]->alertString);
      printlnEther_p(client, PSTR("</b></td></tr>"));
      printlnEther_p(client, PSTR("</table></td></tr>"));
    } 
  }

  //close main table
  printlnEther_p(client, PSTR("</table>"));

  printlnEther_p(client, PSTR("</div></body></html>"));
  // HTML Ends Here
}

//all strings should be PROGMEM strings
void printRedirect_p(Client client, prog_char *title, prog_char *msg, prog_char *targetUrl, prog_char *timeout) {

  //print header
  printlnEther_p(client, PSTR("HTTP/1.1 200 OK"));
  printlnEther_p(client, PSTR("Content-Type: text/html"));
  client.println();
  printEther_p(client, PSTR("<html>\n<head>\n<title>"));
  printEther_p(client, title);
  printEther_p(client, PSTR("</title>\n<meta http-equiv=\"REFRESH\" content=\""));
  printEther_p(client, timeout);
  printEther_p(client, PSTR("; url="));
  printEther_p(client, targetUrl);
  printlnEther_p(client,PSTR("\"></HEAD>"));

  //print body
  printlnEther_p(client, PSTR("<BODY bgcolor=\"DarkGoldenRod\">"));
  printlnEther_p(client, msg);
  printlnEther_p(client, PSTR("</BODY>\n</HTML>"));
}

//for dealing with ping packets
void printPingRedirect_p(Client client, prog_char *title, char *pongList, prog_char *targetUrl, prog_char *timeout) {

  //print header
  printlnEther_p(client, PSTR("HTTP/1.1 200 OK"));
  printlnEther_p(client, PSTR("Content-Type: text/html"));
  client.println();
  printEther_p(client, PSTR("<html>\n<head>\n<title>"));
  printEther_p(client, title);
  printEther_p(client, PSTR("</title>\n<meta http-equiv=\"REFRESH\" content=\""));
  printEther_p(client, timeout);
  printEther_p(client, PSTR("; url="));
  printEther_p(client, targetUrl);
  printlnEther_p(client,PSTR("\"></HEAD>"));

  //print body
  printlnEther_p(client, PSTR("<BODY bgcolor=\"DarkGoldenRod\">"));
  if (strlen(pongList) == 0)
    printlnEther_p(client, PSTR("<p>Waiting for responses... </p>"));
  else {
    printEther_p(client, PSTR("<p>Responses:</p>\n<p>"));     
    client.print(pongList);
    printlnEther_p(client, PSTR("</p>"));
  }
  printlnEther_p(client, PSTR("</BODY>\n</HTML>"));
}

void printRedirect(Client client) {
  printlnEther_p(client, PSTR("HTTP/1.1 303 See Other"));
  printEther_p(client, PSTR("Location: "));
  printlnEther_p(client, myUrl);
}




