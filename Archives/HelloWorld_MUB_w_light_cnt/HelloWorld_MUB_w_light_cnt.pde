

// include the library code:
#include <LiquidCrystal.h>
int a;
int b;
int c;
int d;

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(2,3,4,5,6,7);

void setup() {
  // set up the LCD's number of columns and rows: \
  pinMode (13,OUTPUT);
  digitalWrite (13, HIGH);
  pinMode (12,OUTPUT);
  pinMode (11,OUTPUT);
  pinMode (10,OUTPUT);
  digitalWrite (10, HIGH);
  digitalWrite (11, HIGH);
  digitalWrite (12, HIGH);
  lcd.begin(16, 2);
  // Print a message to the LCD.
  lcd.print("hello, world!");
}

void loop() {
  a = digitalRead (A0);//non catching
  b = digitalRead (A1);//non catching
  c = digitalRead (A3);//catching swithch 
  d = digitalRead (A2);//catching swithch 
  if (a == HIGH) {

  digitalWrite (10, LOW);
  digitalWrite (11, HIGH);
  digitalWrite (12, HIGH);
  }
  
  if (b == HIGH) {

  digitalWrite (10, HIGH);
  digitalWrite (11, LOW);
  digitalWrite (12, HIGH);
  }
  if (c == HIGH) {

  digitalWrite (10, HIGH);
  digitalWrite (11, HIGH);
  digitalWrite (12, LOW);
  }
  if (d == HIGH) {

  digitalWrite (10, HIGH);
  digitalWrite (11, HIGH);
  digitalWrite (12, HIGH);
  }
  

  // set the cursor to column 0, line 1
  // (note: line 1 is the second row, since counting begins with 0):
  lcd.setCursor(0, 1);
  // print the number of seconds since reset:
  lcd.print(millis()/1000);
}


