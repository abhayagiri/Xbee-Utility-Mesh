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

  //variable for helping calculate minutes or hours
  unsigned long int timeTmp = 0;

  // send a standard http response header
  printlnEther_p(client, httpResponse200);

  // Page HTML goes here
  printEther_p(client, openDocument);
  printEther_p(client, PSTR("Abhayagiri XBee Utility Mesh</title>"
                            "<meta http-equiv=\"REFRESH\" content=\"30; url="));
  printEther_p(client, myUrl); client.println("\"/>");
  
  printEther_p(client, PSTR("<style type=\"text/css\"> "
                              "body {font-family:Verdana;} td {text-align:center; vertical-align:middle;}"
                              "</style></head>"
                              "<body bgcolor=\"DarkGoldenRod\">"
                              "<div align=center valign=middle>"

                              "<table cellspacing=15>"

                              "<tr><td><input type=\"button\" value=\"Send Ping\" "
                              "onClick=\"window.location.replace(\'"));
  printEther_p(client, myUrl); 
  printEther_p(client, PSTR("?ping=send\')\"/></td></tr>"));
  
  //Alerts////////////////////////////////////////////////////////////////////
  for (int i=0; i<NUM_ALERTS; i++) {
    if (alerts[i]->active && !alerts[i]->dismissed) {
      char timestr[32] = "";

      printEther_p(client, PSTR("<tr><td>"

                                "<table border=1 bgcolor=\"Red\" width=100%>"

                                "<tr>"
                                "<td><b>ALERT</b></td>"
                                "<td><b>"));
                                timeTmp = timePastMinutes(&timer,&(alerts[i]->timeStamp));
                                client.print((timeTmp < 60 ? timeTmp : timeTmp / 60));
                                printEther_p(client, (timeTmp<60 ? strMins : strHours)); 
      printEther_p(client, PSTR(" Ago</b></td>"
                                "</tr>" 

                                "<tr>"
                                "<td colspan=\"2\"><b>"));
                                printEther_p(client, alerts[i]->alertString);
      printEther_p(client, PSTR("</b></td>"
                                "</tr>"

                                "</table></td>"
           
                                "<td><input type=\"button\" value=\"Dismiss\" onClick=\"window.location.replace(\'"));
                                printEther_p(client, myUrl); 
      printEther_p(client, PSTR("?dismiss="));
                                client.print(i+1);
      printEther_p(client, PSTR("\')\"/>"
                                
                                "</td></tr>"));

    } 
  }

  //Battery/////////////////////////////////////////////////////
  printEther_p(client, PSTR("<tr><td>"
                              
                            "<table border=1 width=100%>"
                            
                            "<tr>"
                            "<td><b>Battery</b></td>"));                               
  if (gotBat) {                 
    printEther_p(client, PSTR("<td><b>")); 
                              printTime(client, battery.dmin);
    printEther_p(client, PSTR("<tr>"
                              "<td>Voltage</td>"
                              "<td>"));
                              client.print(battery.volts);
    printEther_p(client, PSTR("V</td>"
                              "</tr>"

                              "<tr>"
                              "<td>Hour Average</td>"
                              "<td>"));
                              client.print(battery.hourVolts);
    printEther_p(client, PSTR("V</td>"
                              "</tr>"

                              "<tr>"
                              "<td>Load</td>"
                              "<td>"));
                              client.print(battery.watts);
    printEther_p(client, PSTR("W</td>"
                              "</tr>"
                              
                              "<tr>"
                              "<td>Status</td>"
                              "<td>"));
                              client.print(battery.status);
    printEther_p(client, PSTR("</td>"
                              "</tr>"));

  } else {
    printEther_p(client, PSTR("<tr><td>No Data Received</td></tr>"));
  }
  
  printEther_p(client, PSTR("</table></td></tr>"
  
  //Turbine info/////////////////////////////////////////////////////////////
                            "<tr><td>"
                            
                            "<table border=1 width=100%>"
                            
                            "<tr>"
                            "<td><b>Turbine</b></td>"));
                            
  if (gotTrb) {
    printEther_p(client, PSTR("<td><b>"));
                              printTime(client, turbine.dmin);
    printEther_p(client, PSTR("<tr>"
                              "<td>Valves Open</td>"
                              
                              "<td><form name=\"valveSetForm\" action=\"/\" method=\"get\" style=\"height: 7px;\">"
                              "<select name=\"valveOp\" onChange=\"document.forms['valveSetForm'].submit()\">"
                              "<option>"));
                              client.print(turbine.valves); 
    printEther_p(client, PSTR("</option>"
                              "<optgroup label=\"Set Valves\">"
                              "<option value=0>None</option>"
                              "<option value=1>A</option>"
                              "<option value=2>C</option>"
                              "<option value=3>AC</option>"
                              "<option value=4>B</option>"
                              "<option value=5>AB</option>"
                              "<option value=6>BC</option>"
                              "<option value=7>ABC</option>"
                              "</optgroup>"
                              "</select>"
                              "</form></td>"
                              "</tr>"
                              
                              "<tr>"
                              "<td>PSI</td>"
                              "<td>"));
                              client.print(turbine.psi);
    printEther_p(client, PSTR("</td>"
                              "</tr>"
                               
                              "<tr>"
                              "<td>Mode</td>"
                              "<td><form name=\"modeSetForm\" action=\"/\" method=\"get\" style=\"height: 7px;\">"
                              "<select name=\"modeOp\" onChange=\"document.forms['modeSetForm'].submit()\">"
                              "<option>"));
                              (turbine.controlMode == 0 ? client.print("Auto") : client.print("Manual"));
    printEther_p(client, PSTR("</option>"
                              "<optgroup label=\"Set Mode\">"
                              "<option value=0>Auto</option>"
                              "<option value=1>Manual</option>"
                              "</optgroup>"
                              "</select></form></td>"
                              "</tr>")); 
  } else {
    printEther_p(client, PSTR("<tr>"
                              "<td colspan=\"2\">"
                              "<form name=\"valveSetForm\" action=\"/\" method=\"get\" style=\"height: 7px;\">"
                              "<select name=\"valveOp\" onChange=\"document.forms['valveSetForm'].submit()\">"
                              "<option>No Data Received</option>"
                              "<optgroup label=\"Set Valves\">"
                              "<option value=0>None</option>"
                              "<option value=1>A</option>"
                              "<option value=2>C</option>"
                              "<option value=3>AC</option>"
                              "<option value=4>B</option>"
                              "<option value=5>AB</option>"
                              "<option value=6>BC</option>"
                              "<option value=7>ABC</option>"
                              "</optgroup>"
                              "</select></form></td>"
                              "</tr>"));
  }
  printlnEther_p(client, PSTR("</table></td></tr>"));
  
  //turbine/////////////////////////////////////////////////////////
  printEther_p(client, PSTR("<tr><td>"
                            
                            "<table border=1 width=100%>"
                            
                            "<tr>"
                            "<td><b>Hydro Inverter</b></td>"));

  if (gotHydro) {
    printEther_p(client, PSTR("<td><b>"));
                              printTime(client, hydroWatts.dmin);
    printEther_p(client, PSTR("<tr>"
                              "<td>Watts Produced</td><td>"));
                              client.print(hydroWatts.watts);
    printEther_p(client, PSTR("</td>"
                              "</tr>"));
  }  
  else {
    printEther_p(client, PSTR("<tr>"
                              "<td colspan=\"2\">No Data Received</td>"
                              "</tr>"));
  }
  printEther_p(client, PSTR("</table></td></tr>"

  //Tanks///////////////////////////////////////////////////////////////
                            "<tr><td>"
                            
                            "<table border=1 width=100%>"
                            
                            "<tr>"
                            "<td><b>Two Water Tanks</b></td>"));

  if (gotTwt) {  
    printEther_p(client, PSTR("<td><b>"));
                              printTime(client, tanks[TWT].dmin);
    printEther_p(client, PSTR("<tr><td>Level</td><td>"));
                              client.print( 
                                max(tanks[TWT].tankCap / numTankLevels * tanks[TWT].level,
                                    0),
                                    0);
    printEther_p(client, PSTR(" gal.</td></tr>"));
  } else {
    printEther_p(client, PSTR("<tr>"
                              "<td colspan=\"2\">No Data Received</td>"
                              "</tr>"));
  }
  printEther_p(client, PSTR("</table></td></tr>"
                            
                            "<tr><td>"
                            "<table border=1 width=100%>"
                            
                            "<tr>"
                            "<td><b>Four Water Tanks</b></td>"));
  if (gotFwt) {
    printEther_p(client, PSTR("<td><b>"));
                              printTime(client, tanks[FWT].dmin);
    printEther_p(client, PSTR("<tr>"
                              "<td>Level</td>"
                              "<td>"));
                              client.print(
                                max(tanks[FWT].tankCap / numTankLevels * tanks[FWT].level,
                                    0),
                                    0);
    printEther_p(client, PSTR(" gal.</td></tr>"));
  } else {
    printEther_p(client, PSTR("<tr>"
                              "<td colspan=\"2\">No Data Received</td>"
                              "</tr>"));
  }
  
  printEther_p(client, PSTR("</table></td></tr>"
                            "<tr><td>"
                            "<table border=1 width=100%>"
                            "<tr>"
                            "<td><b>Ridge Water Tanks</b></td>"));

  if (gotRdg) {
    printEther_p(client, PSTR("<td><b>"));
                              printTime(client, tanks[RDG].dmin); 
    printEther_p(client, PSTR("<tr>"
                              "<td>Level</td>"
                              "<td>"));
                              client.print(
                                max(tanks[RDG].tankCap / numTankLevels * tanks[RDG].level,
                                    0),
                                    0);
    printEther_p(client, PSTR(" gal.</td></tr>"));
  } else {
    printEther_p(client, PSTR("<tr>"
                              "<td colspan=\"2\">No Data Received</td>"
                              "</tr>"));
  }
  printEther_p(client, PSTR("</table></td>"
                              
                            "<td>"
                            "<table>"
                            "<tr><td><input type=\"button\" value=\"Pump On\" onClick=\"window.location.replace(\'"));
                            printEther_p(client, myUrl);
  printEther_p(client, PSTR("?pumpOp=on\')\"/></td></tr>"
                            
                            "<tr><td><input type=\"button\" value=\"Pump Off\" onClick=\"window.location.replace(\'"));
                            printEther_p(client, myUrl); 
  printEther_p(client, PSTR("?pumpOp=off\')\"/>"
                            "</td></tr>"
                            "</table>"
                            "</td>"
                            
                            "</tr>"));

  for (int i=0; i<NUM_ALERTS; i++) {
    if (alerts[i]->active && alerts[i]->dismissed) {
      char timestr[32] = "";
      printEther_p(client, PSTR("<tr><td>"
                                "<table border=1 width=100% bgcolor=\"SandyBrown\">"
                                
                                "<tr>"
                                "<td><b>ALERT</b></td>"
                                "<td><b>"));
                                timeTmp = timePastMinutes(&timer,&(alerts[i]->timeStamp));
                                client.print((timeTmp < 60 ? timeTmp : timeTmp / 60));
                                printEther_p(client, (timeTmp<60 ? strMins : strHours)); 
      printEther_p(client, PSTR(" Ago</b></td>"
                                "</tr>" 

                                "<tr>"
                                "<td colspan=\"2\"><b>"));
                                printEther_p(client, alerts[i]->alertString);
      printEther_p(client, PSTR("</b></td>"
                                "</tr>"

                                "</table></td></tr>"));
    } 
  }

  //close main table
  printlnEther_p(client, PSTR("</table>"
                              
                              "</div></body></html>"));
  // HTML Ends Here
}

void printTimeSetPage(Client client) {
  printlnEther_p(client, httpResponse200);

  printEther_p(client, openDocument);
  printEther_p(client, PSTR("Set Time</title></head>"));
  printEther_p(client, openBody);
  printEther_p(client, openContainer);
  printEther_p(client, PSTR("<div style=\"text-align:center; valign:middle; font-size:24pt;\">"
                            "Set Time <br>"
                            "<form name=\"timeSetForm\" action=\"/\" method=\"get\">"
                            "Hour: "
                            "<select name=\"hour\">"));
                            for (int i=0; i<25; i++) {
                              printEther_p(client, PSTR("<option>"));
                              client.print(i);
                              printEther_p(client, PSTR("</option>"));
                            }
  printEther_p(client, PSTR("</select>"
                            " Minute: "
                            "<select name=\"minute\">"));
                            for (int i=0; i<60; i++) {
                              printEther_p(client, PSTR("<option>"));
                              client.print(i);
                              printEther_p(client, PSTR("</option>"));
                            }
  printEther_p(client, PSTR("</select> "
                            
                            "<br><br><input type=\"button\" value=\"Submit\" onClick=\"window.location.replace('"));
                            printEther_p(client, myUrl); 
  printEther_p(client, PSTR("?setTime=' + "
                            "document.forms['timeSetForm'].elements[0].selectedIndex + "
                            "'-' + document.forms['timeSetForm'].elements[1].selectedIndex)\""
                            "/></form></div"));
  printEther_p(client, closeContainer);
  printEther_p(client, PSTR("</html>"));
}

void printTime(Client client, unsigned long int mins) {
  client.print((mins<60 ? mins : mins/60.0),(mins>60 && mins/60 < 2 ? 1 : 0));
  printEther_p(client, (mins<60 ? strMins : strHours));
  printlnEther_p(client, strAgo);
}

//all strings should be PROGMEM strings
void printRedirect_p(Client client, prog_char *title, prog_char *msg, prog_char *targetUrl, prog_char *timeout, bool wrap) {

  //print header
 printRedirectHeader_p(client, title, targetUrl, timeout);

  //print body
  printlnEther_p(client, openBody);
  printlnEther_p(client, openContainer);
  printEther_p(client, openStyledP);
  
  if (wrap)
    printEther_p(client, PSTR("Sent <i>"));  
  
  printlnEther_p(client, msg);
  
  if (wrap)
    printlnEther_p(client, PSTR(" </i>command, waiting for response..."));  
  
  printEther_p(client, PSTR("</p>"));
  printEther_p(client, closeContainer);
  printlnEther_p(client, PSTR("</BODY>\n</HTML>"));
}

//for dealing with ping packets
void printPingRedirect_p(Client client, prog_char *title, char *pongList, prog_char *targetUrl, prog_char *timeout) {

  //print header
 printRedirectHeader_p(client, title, targetUrl, timeout);

  //print body
  printlnEther_p(client, openBody);
  if (strlen(pongList) == 0) {
      printlnEther_p(client, openContainer);
      printEther_p(client, openStyledP);
    printlnEther_p(client, PSTR("Waiting for responses... </p>"));
  } else {
    printlnEther_p(client, openContainer);
    printEther_p(client, openStyledP);
    printEther_p(client, PSTR("Responses:</p>\n"));     
    printEther_p(client, openStyledP);
    client.print(pongList);
    printlnEther_p(client, PSTR("</p>"));
  }
  printlnEther_p(client, closeContainer);
  printlnEther_p(client, PSTR("</BODY>\n</HTML>"));
}

void printRedirectHeader_p(Client client, prog_char *title, prog_char *targetUrl, prog_char *timeout)
{
  printlnEther_p(client, httpResponse200);
  printEther_p(client, openDocument);
  printEther_p(client, title);
  printEther_p(client, PSTR("</title>\n<meta http-equiv=\"REFRESH\" content=\""));
  printEther_p(client, timeout);
  printEther_p(client, PSTR("; url="));
  printEther_p(client, targetUrl);
  printlnEther_p(client,PSTR("\"></HEAD>"));
}

void printRedirect(Client client) {
  printEther_p(client, PSTR("HTTP/1.1 303 See Other\n"
                              "Location: "));
                              printlnEther_p(client, myUrl);
}




