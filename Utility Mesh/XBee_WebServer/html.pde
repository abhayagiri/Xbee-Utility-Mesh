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
  
  printEther_p(client, 4, openDocument,
                          PSTR("Abhayagiri XBee Utility Mesh</title>"
                               "<meta http-equiv=\"REFRESH\" content=\"30; url="),
                          myUrl, 
                          PSTR("\"/>"
                               "<style type=\"text/css\"> "
                               "body {font-family:Verdana; height:100%;} td {text-align:center; vertical-align:middle;}"
                               "</style></head>"
                               "<body bgcolor=\"DarkGoldenRod\">"
                               "<div align=center valign=middle>"

                               "<table cellspacing=15>"

                               "<tr><td>"
                               "<form name=\"pingSetForm\" action=\"/\" methode=\"get\">"
                               "<select name=\"ping\" onChange=\"document.forms['pingSetForm'].submit()\">"
                               "<option>Select ping target</option>"
                               "<optgroup label=\"Targets\">"
                               "<option value=\"send\">All</option>"
                               "<option>TWT</option>"
                               "<option>TRB</option>"
                               "<option>FWT</option>"
                               "<option>RDG</option>"
                               "<option>SNA</option>"
                               "<option>GTS</option>"
                               "</optgroup>"
                               "</select>"
                               "</form>"
                               ));
  
  //Alerts////////////////////////////////////////////////////////////////////
  for (int i=0; i<NUM_ALERTS; i++) {
    if (alerts[i]->active && !alerts[i]->dismissed) {
      char timestr[32] = "";

      printEther_p(client, PSTR("<tr><td>"

                                "<table border=1 bgcolor=\"Red\" width=100%>"

                                "<tr>"
                                "<td><b>ALERT</b></td>"
                                "<td><b>"));
                                printTime(client, timePastMinutes(&timer,&(alerts[i]->timeStamp)));
      printEther_p(client, 5, PSTR("<tr>"
                                "<td colspan=\"2\"><b>"),
                                alerts[i]->alertString,
                           PSTR("</b></td>"
                                "</tr>"

                                "</table></td>"
           
                                "<td><input type=\"button\" value=\"Dismiss\" onClick=\"window.location.replace(\'"),
                                myUrl,
                           PSTR("?dismiss="));
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
                              "<td bgcolor=\""));
                              switch (battery.status) {
                                case 1:
                                  client.print("Green\">Very Good");
                                  break;
                                case 0: 
                                  client.print("RoyalBlue\">Good");
                                  break;
                                case -1: 
                                  client.print("Pink\">Weak");
                                  break;
                                case -2: 
                                  client.print("DarkRed\">Very Weak");
                                  break;
                                case -3: 
                                  client.print("Red\">Yikes!!!");
                                  break;
                                default:
                                  client.print("\">");
                              }
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
    printEther_p(client, 3, PSTR("</option>"),
                                 turbineOptionGroup,
                            PSTR("</select>"
                                 "</form></td>"
                                 "</tr>"
                              
                                 "<tr>"
                                 "<td>PSI</td>"
                                 "<td>"));
                                 client.print(turbine.psi);
    printEther_p(client, 3, PSTR("</td>"
                                 "</tr>"
                               
                                 "<tr>"
                                 "<td>Mode</td>"
                                 "<td><form name=\"modeSetForm\" action=\"/\" method=\"get\" style=\"height: 7px;\">"
                                 "<select name=\"modeOp\" onChange=\"document.forms['modeSetForm'].submit()\">"
                                 "<option>"),
                                 (turbine.controlMode == 0 ? PSTR("Auto") : PSTR("Manual")),
                             PSTR("</option>"
                                 "<optgroup label=\"Set Mode\">"
                                 "<option value=0>Auto</option>"
                                 "<option value=1>Manual</option>"
                                 "</optgroup>"
                                 "</select></form></td>"
                                 "</tr>")); 
  } else {
    printEther_p(client, 3, PSTR("<tr>"
                                 "<td colspan=\"2\">"
                                 "<form name=\"valveSetForm\" action=\"/\" method=\"get\" style=\"height: 7px;\">"
                                 "<select name=\"valveOp\" onChange=\"document.forms['valveSetForm'].submit()\">"
                                 "<option>No Data Received</option>"),
                                 turbineOptionGroup,
                             PSTR("</select></form></td>"
                                  "</tr>"));
  }
  printlnEther_p(client, PSTR("</table></td></tr>"));
  
  //Grid tie inverter/////////////////////////////////////////////////////////
  printEther_p(client, PSTR("<tr><td>"
                            
                            "<table border=1 width=100%>"
                            
                            "<tr>"
                            "<td><b>Hydro Inverter</b></td>"));

  if (gotHydro) {
    printEther_p(client, PSTR("<td><b>"));
                              printTime(client, hydroWatts.dmin);
    printEther_p(client, PSTR("<tr>"
                              "<td>Curr. Output</td><td>"));
                              client.print(hydroWatts.watts);
    printEther_p(client, PSTR(" Watts</td>"
                              "</tr>"
                              
                              "<tr>"
                              "<td>Produced Today</td><td>"));
                              client.print(hydroWatts.kwhToday, 2);
    printEther_p(client, PSTR(" kWh</td>"
                              "</tr>"
                              
                              "<tr>"
                              "<td>Produced Yesterday</td><td>"));
                              client.print(hydroWatts.kwhYesterday, 2);
    printEther_p(client, PSTR(" kWh</td>"
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
  printEther_p(client, PSTR("<tr>"
                            "<td colspan=\"2\"><input type=\"button\" value=\"Pump On\" onClick=\"window.location.replace(\'"));
                            printEther_p(client, myUrl);
  printEther_p(client, PSTR("?pumpOp=on\')\"/>"
                            
                            "<nbsp><input type=\"button\" value=\"Pump Off\" onClick=\"window.location.replace(\'"));
                            printEther_p(client, myUrl); 
  printEther_p(client, PSTR("?pumpOp=off\')\"/>"
                            "</td></tr>"
                            "</table>"
                            "</td>"
                            
                            "</tr>"));

  //Dismissed but active alerts live at the bottom of the page////////////////////////////////////////////
  for (int i=0; i<NUM_ALERTS; i++) {
    if (alerts[i]->active && alerts[i]->dismissed) {
      char timestr[32] = "";
      printEther_p(client, PSTR("<tr><td>"
                                "<table border=1 width=100% bgcolor=\"SandyBrown\">"
                                
                                "<tr>"
                                "<td><b>ALERT</b></td>"
                                "<td><b>"));
                           printTime(client, timePastMinutes(&timer,&(alerts[i]->timeStamp)));
      printEther_p(client, 3,
                           PSTR("<tr>"
                                "<td colspan=\"2\"><b>"),
                                alerts[i]->alertString,
                           PSTR("</b></td>"
                                "</tr>"

                                "</table></td></tr>"));
    } 
  }

  //close main table
  printEther_p(client, PSTR("</table>"
                            "</div>"
                            
                            "<div align=\"center\"  style=\"visibility: hidden;\">"
                            "<p>"));
                            client.print((timer.hour > 12 ? timer.hour-12 : timer.hour));
                            client.print(':');
                            if (timer.min < 10) client.print('0');
                            client.print(timer.min);
                            client.print((timer.hour > 11 ? " PM" : " AM"));
  printEther_p(client, PSTR("</p>"
                            "</div>"
                            
                            "</body></html>"));
  // HTML Ends Here
}

void printTimeSetPage(Client client) {
  printlnEther_p(client, httpResponse200);

  printEther_p(client, 5, openDocument,
                  PSTR("Set Time</title></head>"),
                       openBody,
                       openContainer,
                  PSTR("<div style=\"text-align:center; valign:middle; font-size:24pt;\">"
                       "Set Time <br>"
                       "<form name=\"timeSetForm\" action=\"/\" method=\"get\">"
                       "Hour: "
                       "<select name=\"hour\">"));
                       for (int i=0; i<24; i++) {
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
  printEther_p(client, 5, PSTR("</select> "
                            
                               "<br><br><input type=\"button\" value=\"Submit\" onClick=\"window.location.replace('"),
                          myUrl,
                          PSTR("?setTime=' + "
                               "document.forms['timeSetForm'].elements[0].selectedIndex + "
                               "'-' + document.forms['timeSetForm'].elements[1].selectedIndex)\""
                               "/></form></div"),
                          closeContainer,
                          PSTR("</html>"));
}

void printTime(Client client, unsigned long int mins) {
  client.print((mins<60 ? mins : mins/60.0),(mins>60 && mins/60 < 2 ? 1 : 0));
  printEther_p(client, 2, 
               (mins<60 ? strMins : strHours),
               strAgo);
}

//all strings should be PROGMEM strings
void printRedirect_p(Client client, prog_char *title, prog_char *msg, prog_char *targetUrl, prog_char *timeout, bool wrap) {

  //print header
 printRedirectHeader_p(client, title, targetUrl, timeout);

  //print body
  printEther_p(client, 3, openBody,
                          openContainer,
                          PSTR("<p>"));
  
  if (wrap)
    printEther_p(client, PSTR("Sending <i>"));  
  
  printEther_p(client, msg);
  
  if (wrap)
    printEther_p(client, PSTR(" </i>command, waiting for response..."));  
  
  printEther_p(client, 3, PSTR("</p><p><a style=\"font-size:12pt;\" href=\"http://xbee-mesh/?\">Cancel</a></p>"),
                          closeContainer,
                          PSTR("</body>\n</html>"));
}

//for dealing with ping packets
void printPingRedirect_p(Client client, prog_char *title, char *pongList, prog_char *targetUrl, prog_char *timeout) {

  //print header
 printRedirectHeader_p(client, title, targetUrl, timeout);

  //print body
  printEther_p(client, 2, openBody,
                          openContainer);
  if (strlen(pongList) == 0) {
      printEther_p(client, PSTR("<p>Waiting for responses... </p>"));
  } else {
    printEther_p(client, PSTR("Responses:</p><p>\n"));     
    client.print(pongList);
    printEther_p(client, PSTR("</p>"));
  }
  printEther_p(client, 3, PSTR("<p><a style=\"font-size:12pt;\" href=\"http://xbee-mesh/?\">Finished</a></p>"),
                          closeContainer,
                          PSTR("</body>\n</html>"));
}

void printRedirectHeader_p(Client client, prog_char *title, prog_char *targetUrl, prog_char *timeout)
{
  printlnEther_p(client, httpResponse200);
  printEther_p(client, 7, openDocument,
                       title,
                       PSTR("</title>\n<meta http-equiv=\"REFRESH\" content=\""),
                       timeout,
                       PSTR("; url="),
                       targetUrl,
                       PSTR("\"></head>"));
}

void printRedirect(Client client) {
  printEther_p(client, 3, PSTR("HTTP/1.1 303 See Other\n"
                               "Location: "),
                               myUrl,
                               PSTR("\n"));
}




