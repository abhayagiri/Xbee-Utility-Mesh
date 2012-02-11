
#include <LiquidCrystal.h>
LiquidCrystal lcd(13,8,12,11,10,9); 



int wattsMax = 3850;
int wattsNow;
int buttonPressed;

int buttonPin = 3;
int ledPin = 2;
int readWatts = A0;

void setup() {
  pinMode (buttonPin, INPUT);
  pinMode (ledPin, OUTPUT);
  pinMode (readWatts, INPUT);
lcd.begin (16,2);


}

void loop() {
  wattsNow = map (analogRead (readWatts), 0, 1020, 0, 3850);
  while (wattsNow > (.9 * wattsMax)){
    lcd.print (wattsNow);
    buttonPressed = digitalRead (buttonPin);
    if (buttonPressed == LOW) {
      digitalWrite (ledPin, HIGH);
      delay (500);
      digitalWrite (ledPin, LOW);
      delay (500);
      if ((map (analogRead (readWatts), 0, 1020, 0, 3850)) > (wattsNow * 1.1)){
        wattsMax = map (analogRead (readWatts), 0, 1020, 0, 3850);
      }
    }
    lcd.clear ();
    lcd.print ("Reduced Watts");
    for (int i=0; i <= 255; i++){
      lcd.setCursor (2,2);
      lcd.print ("Acknowledged");
      delay (1000);
      lcd.setCursor (2,2);
      lcd.print ("            ");
      delay (1000);
    }
    wattsMax = wattsNow;
  }
}



