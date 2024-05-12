//////////////////////////////////////////////////////////////////////////////
//
//@brief: Sketch that Tests reading and detecting RFID Tag.
//
//@version: 0.0.1
//@date: 03/03/2024
//@author: Kananelo Chabeli
//
//
///////////////////////////////////////////////////////////////////////////////


//Includes
#include <Arduino.h>
#include <SoftwareSerial.h>

//defines
#define RFID_INTERRUPT_PIN 27
#define RFID_TX_PIN 4
#define RFID_RX_PIN 5

//global variables

String text;
String tagID;

SoftwareSerial rfid(RFID_RX_PIN, RFID_TX_PIN);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  rfid.begin(9600);
  Serial.print("Bring the Tag closer...");

}
char c;
void loop() {
  while(rfid.available() > 0){
    delay(5);
    c = rfid.read();
    text+=c;
  }
  if(text.length()>10){
    tagID = text.substring(1,11);
  }
  Serial.println("Card ID: "+tagID);
  Serial.println("Bring tag closer...");

}
