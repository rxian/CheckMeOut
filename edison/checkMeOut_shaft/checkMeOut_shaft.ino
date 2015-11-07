#include <Servo.h>


Servo myservo;
int pos = 90;    // variable to store the servo position

const int buttonPin = 2;
bool buttonIsPressed = 0;
unsigned long lastTimePressed;
int buttonState = 0;  


void setup() {
  Serial.begin(9600);
  pinMode(13, OUTPUT);
  pinMode(buttonPin, INPUT);
  myservo.attach(9);
  lastTimePressed = 0;
}

void loop() {
   delay(300);
   Serial.print(int(millis()) - lastTimePressed > 5000);
    
   if (int(millis()) - lastTimePressed > 300) {
    buttonState = digitalRead(buttonPin);
    
    if (buttonState == HIGH) {
      if (buttonIsPressed == 0){
        buttonIsPressed = 1;
        lastTimePressed = millis();
        Serial.print("a");
        toggleServo();
      }
    } else {
      Serial.print("B");
      buttonIsPressed = 0;
    }
    
   }
}



void toggleServo() {
  if (pos == 90) {
    pos = 0;
  } else {
    pos = 90;
  }
  myservo.write(pos);

}

