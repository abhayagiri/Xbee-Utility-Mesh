

int buttona = 4;
int ledPin = 13;
int vala;
int valb;

void setup(){

  Serial.begin (9600);
  pinMode (buttona,INPUT);
  pinMode (ledPin,OUTPUT);
}

void loop (){
  vala = digitalRead (buttona);
  Serial.print (vala);

  if (vala == 1) {
    digitalWrite (ledPin, HIGH);
  }
  else
    vala = 0;
    digitalWrite (ledPin, LOW);

}
