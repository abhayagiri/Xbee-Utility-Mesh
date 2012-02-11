
#include <LiquidCrystal.h>
LiquidCrystal lcd(13,8,12,11,10,9); 



int wattsMax = 70;//3850
int wattsNow;
int buttonPressed;

int buttonPin = 2;
int ledPin = 3;
int readWatts = A0;

void setup() {
  pinMode (buttonPin, INPUT);
  pinMode (ledPin, OUTPUT);
  pinMode (readWatts, INPUT);
  lcd.begin (16,2);


}

void loop() {
  // wattsNow = map (analogRead (readWatts), 0, 1020, 0, 3850);
  wattsNow = (analogRead (readWatts));
  lcd.clear();
  lcd.print (wattsNow);
  delay (500);
  while (wattsNow < (.9 * wattsMax)){
    lcd.setCursor (1,0);
    lcd.clear ();
    lcd.print ("watts falling");
    delay (1000);
    lcd.print (wattsNow);
    buttonPressed = digitalRead (buttonPin);
    while (buttonPressed == LOW) {
      buttonPressed = digitalRead (buttonPin);
      digitalWrite (ledPin, HIGH);
      delay (500);
      buttonPressed = digitalRead (buttonPin);
      digitalWrite (ledPin, LOW);
      delay (500);
      if (analogRead (readWatts) > (wattsNow * 1.1)){
        wattsMax = (analogRead (readWatts));
        //if ((map (analogRead (readWatts), 0, 1020, 0, 3850)) > (wattsNow * 1.1))

        // wattsMax = map (analogRead (readWatts), 0, 1020, 0, 3850);
      }
    }
    lcd.clear ();
    lcd.setCursor (1,0);
    lcd.print ("Reduced Watts");
    for (int i=0; i <= 2; i++){
      lcd.setCursor (2,1);
      lcd.print ("Acknowledged");
      delay (500);
      lcd.setCursor (2,1);
      lcd.print ("            ");
      delay (500);
    }
    wattsNow = (analogRead (readWatts));
    wattsMax = (analogRead (readWatts));
  }
}













