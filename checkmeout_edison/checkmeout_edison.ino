#include <SPI.h>
#include <Ethernet.h>
#include <Servo.h>


Servo myservo;
int pos = 90;    // variable to store the servo position

const int buttonPin = 2;
bool buttonIsPressed = 0;
unsigned long lastTimePressed;
int buttonState = 0;  

int redPin = 5;
int greenPin = 6;











// assign a MAC address for the ethernet controller.
// fill in your address here:
byte mac[] = {
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED
};
// fill in an available IP address on your network here,
// for manual configuration:
IPAddress ip(192, 168, 1, 177);

// fill in your Domain Name Server address here:
IPAddress myDns(1, 1, 1, 1);

// initialize the library instance:
EthernetClient client;

char server[] = "rxian.me";
//IPAddress server(64,131,82,241);

unsigned long lastConnectionTime = 0;             // last time you connected to the server, in milliseconds
const unsigned long postingInterval = 3000; // delay between updates, in milliseconds
// the "L" is needed to use long type numbers


bool recordData = 0;
String content = "";



void setup() {
  // start serial port:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  // give the ethernet module time to boot up:
  delay(1000);
  // start the Ethernet connection using a fixed IP address and DNS server:
  Ethernet.begin(mac, ip, myDns);
  // print the Ethernet board/shield's IP address:
  Serial.print("My IP address: ");
  Serial.println(Ethernet.localIP());




  Serial.begin(9600);
  pinMode(13, OUTPUT);
  pinMode(buttonPin, INPUT);
  myservo.attach(9);
  lastTimePressed = 0;

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);

  digitalWrite(redPin, HIGH);
  digitalWrite(greenPin, LOW);

  
}







void loop() {
  
//   if (int(millis()) - lastTimePressed > 300) {
//    buttonState = digitalRead(buttonPin);
//    
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
//    
//   }





  char character;
  
  if (client.available()) {
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
      printContent(content);
    } else {
      if (recordData == 1) {
        content.concat(character);
      }
    }
//    Serial.write(c);
  }
  
  // if ten seconds have passed since your last connection,
  // then connect again and send data:
  if (millis() - lastConnectionTime > postingInterval) {
    httpRequest();
  }

}




void printContent(String printContent) {
  Serial.print(printContent);
}







// this method makes a HTTP connection to the server:
void httpRequest() {
  // close any connection before send a new request.
  // This will free the socket on the WiFi shield
  client.stop();

  // if there's a successful connection:
  if (client.connect(server, 80)) {
    // Serial.println("connecting...");
    // send the HTTP PUT request:
    client.println("GET /test.html HTTP/1.1");
    client.println("Host: rxian.me");
    client.println("User-Agent: arduino-ethernet");
    client.println("Connection: close");
    client.println();

    // note the time that the connection was made:
    lastConnectionTime = millis();
  } else {
    // if you couldn't make a connection:
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
