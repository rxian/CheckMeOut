/*
  CheckMeOut Edison board physical mechanism implementation

  This is the program written for the Edison board for implementing the CheckMeOut project on the merchant's side.

  Circuit:
  * Schematics provided on Github - https://github.com/sesowo/CheckMeOut
  * RGB LED
  * RC Servo
  * Button
  * 1k Ohm Resistors
  * Intel Edison Board

  Reference:
  * Arduino Web Client Sample Code - https://www.arduino.cc/en/Tutorial/WebClient
  * Arduino Sweep Sample Code - https://www.arduino.cc/en/Tutorial/Sweep

  created 6 Nov 2015
  by R. Xian
  modified 10 Nov 2015
  by R. Xian

*/




// ##### PROGRAM MARK: importation
// <!> uses Edison library
#include <SPI.h>
#include <Ethernet.h>
#include <Servo.h>




// ##### PROGRAM MARK: initialization
// initialize serno
Servo myservo;  // at PWM pin 9
int pos = 90;

// initialize button for testing and debugging
const int buttonPin = 2;
bool buttonIsPressed = 0;
unsigned long lastTimePressed;
int buttonState = 0;

// initialize LED for status indication
int redPin = 5;
int greenPin = 6;

// initialize basic network information
byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
IPAddress ip(192, 168, 1, 177);
IPAddress myDns(1, 1, 1, 1);

// initialize web client
EthernetClient client;
char server[] = "yourWebDatabase.org"; // <!> specify the url for retriving data for the stock information
unsigned long lastConnectionTime = 0;
const unsigned long postingInterval = 3000;
bool recordData = 0;
String content = "";




// ##### PROGRAM MARK: functions
void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ;
  }
  delay(1000);
  Ethernet.begin(mac, ip, myDns);
  // Serial.print("My IP address: ");
  // Serial.println(Ethernet.localIP());

  pinMode(buttonPin, INPUT);
  lastTimePressed = 0;

  myservo.attach(9);

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  digitalWrite(redPin, HIGH);
  digitalWrite(greenPin, LOW);
}


void loop() {
// button implementation
//   if (int(millis()) - lastTimePressed > 300) {
//    buttonState = digitalRead(buttonPin);
//    if (buttonState == HIGH) {
//      if (buttonIsPressed == 0){
//        buttonIsPressed = 1;
//        lastTimePressed = millis();
//        toggleServo(0);
//        delay(5000);
//      }
//    } else {
//      buttonIsPressed = 0;
//    }
//   }

  // web client receive data
  char character;
  if (client.available()) { // <!> specify the criteria for unlocking or locking the stock
    character = client.read();
    if (character == '<') {
      recordData = 1;
      content = "";
    } else if (character == '>') {
      recordData = 0;
      if (content == "a") {
        toggleServo(1);
      } else {
        toggleServo(2);
      }
      // printContent(content);
    } else {
      if (recordData == 1) {
        content.concat(character);
      }
    }
  }

  // web client send request
  if (millis() - lastConnectionTime > postingInterval) {
    httpRequest();
  }
}


void printContent(String printContent) {
  Serial.print(printContent);
}


void httpRequest() {
  client.stop();
  if (client.connect(server, 80)) {
    lastConnectionTime = millis();
  } else {
    Serial.println("connection failed");
  }
}


void toggleServo(int cmd) {
  if (cmd == 0) {
    if (pos == 90) {
      digitalWrite(redPin, LOW);
      digitalWrite(greenPin, HIGH);
      pos = 0;
    } else {
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, LOW);
      pos = 90;
    }
  } else if (cmd == 1) {
      digitalWrite(redPin, LOW);
      digitalWrite(greenPin, HIGH);
      pos = 0;
  } else {
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, LOW);
      pos = 90;
  }
  myservo.write(pos);
}
