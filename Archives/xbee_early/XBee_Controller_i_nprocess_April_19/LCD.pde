#define OFFSET	4
int printTankData (struct tankStruct *t,int index) {
	// Buffer to construct display string into
	char buf[21];

	// Clear LCD screen to erase old text
	lcd.clear();

	sprintf(buf,"Tank: %s",t[index].id);
	lcd.setCursor(0, 0);
	lcd.print(buf);

	sprintf(buf,"Level Code: %d",t[index].level);
	lcd.setCursor(0, 1);
	lcd.print(buf);

	return 0;
}

int printInverterData (struct inverterStruct *inv) {
	char buf[21];

        // Clear LCD screen to erase old text
        lcd.clear();

        sprintf(buf,"V: %s HV: %s",inv->volts,inv->hourVolts);
        lcd.setCursor(0, 0);
        lcd.print(buf);

        sprintf(buf,"W: %d S: %d",inv->watts,inv->status);
        lcd.setCursor(0, 1);
        lcd.print(buf);

        return 0;
}
