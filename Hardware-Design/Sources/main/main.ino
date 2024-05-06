#include <SoftwareSerial.h>
#include "main.h"

//-------------------------Global Variables------------------------------------//

SoftwareSerial RFID(RFID_RX_PIN,RFID_TX_PIN);
fs::FS &filemanager = LittleFS;
bool tag_id_read_done = false;
String tag_id;

//-----------------------------Data acquisition variables-----------------------//
float vref;
const float calibration = 1.1;
measurement_t meas;
//-------------------------Function Declaration--------------------------------//

char c;

void setup()
{
  Serial.begin(115200);
  //RFID.begin(9600); //Start the UART transmission
  //pinMode(RFID_INTERRUPT_PIN,INPUT_PULLUP);
  //esp_sleep_enable_ext0_wakeup((gpio_num_t)RFID_INTERRUPT_PIN,LOW);
  //check();
  meas = {1,0.005};
  vref = init_adc();
 }


void loop()
{
  float input = get_voltage(ADC_SCALE_PIN,vref,calibration);
  kalman_filter(input,0.025,&meas,0);
  Serial.printf("Input Voltage: %f\nFilter Output:%f\n",input,meas.curr_est);
  delay(1000);
}

// void check()
// {
//   while (RFID.available() > 0) {
//     c = RFID.read();
//     tag_id += c;
//     //function to continuously get the adc  samples here
//   }
//   Serial.println("Card ID : " + tag_id);
//   delay(2000);
//   Serial.println("Sleeping...");
//   esp_deep_sleep_start();
// }