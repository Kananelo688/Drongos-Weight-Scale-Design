/**
  Final Sketch to monitoring and controlling Electronic scale used for weighing Drongois
  Birds in the Kalahari Desert.
  Completed in fulfilment of EEE4113F Engineering Sysrtem Design
  Author: Kanenlo Chabeli
  Date: 30 April 2024
**/

//--------------------------------------------------INCLUDES-------------------------------------------------//

#include <Arduino.h>

//-----------------------------Header files for wirelss connection and webserver set up----------------------//

#include <WiFi.h> //for setting up WiFi Acces Point
#include <WebServer.h> //for creating web server

//-----------------------------Header files for File management----------------------------------------------//
#include <FS.h>
#include <LittleFS.h>

//---------------------------Header File for ADC Calibration-------------------------------------------------//
#include "esp_adc_cal.h"

//----------------------------Header file for RFID Detection and Reading-------------------------------------//
#include <SoftwareSerial.h>

#include <RTClib.h>
//-----------------------------------------------DEFINES-----------------------------------------------------//

#define ADC_SCALE_PIN 35 //ADC Channel through with analog voltage from sacel will be sampled
#define USER_BUTTON_PIN 34 // User Button to interrupt ESP32's sleep mode
#define FORMAT_LITTLEFS_IF_FAILED true 
#define DATA_FILENAME "/Data/data.txt"
#define END_OF_DATA_FILE -1
#define DATA_READ_OK 1
#define RFID_RX_PIN 5
#define RFID_TX_PIN 4
#define RFID_INTERRUPT_PIN 27
#define MAXIMUM_SIZE_OF_FLOAT 20
#define MAXIMUM_SIZE_OF_DATA_ENTRY 100
#define MAXIMUM_SIZE_OF_TIME 12
//-------------------------------------Data element Structure------------------------------------------------//

typedef struct measurement_t{
  float curr_est; //current estimate
  float curr_est_var; //current estimate variance
};
//----------------------------------Used for retrieving data entry from the file.
typedef struct data_entry_t{
  String tag_id;
  String time;
  float weight;
};

//---------------------------------------------GLOBAL CONSTANTS----------------------------------------------//
RTC_DATA_ATTR int set_time = 0; //Integer that determines if time should be set.
const float calibration = 1.001;
char FLOAT[MAXIMUM_SIZE_OF_FLOAT];
measurement_t measurement = {1.0,0.025};
SoftwareSerial RFID(RFID_RX_PIN,RFID_TX_PIN);
fs::FS &filemanager = LittleFS;
String tag_id;
const char* Tag_ID;
//-----------------------------------------Functions---------------------------------------------------------//
/**************************************************************************************************************
@brief: Implements one dimensional Kalman Filter algorithm for filtering the input signal.

@param: voltage  - current measurement of voltage
@param: volt_var - variance of the measurement
@param: meas - pointer to measuremt_t structure
@param: process noise.
***************************************************************************************************************
*/
void kalman_filter(const float voltage, const float volt_var, measurement_t* meas,const float proc_noise = 0.0f){
  
  //Calculate Kalman Gain
  float gain = meas ->curr_est_var/(volt_var + meas -> curr_est_var);

  //calculate the current estimate
  meas ->curr_est = meas->curr_est+ gain*(voltage - meas->curr_est);

  //Compute Measurement Error
  meas->curr_est_var = (1-gain)*meas->curr_est_var;
}
/**
@brief: initializes ADC and calibrates it using express-if API
*/
float init_adc(){
  esp_adc_cal_characteristics_t adc_chars;
  esp_adc_cal_characterize(ADC_UNIT_1, ADC_ATTEN_DB_11, ADC_WIDTH_BIT_12, 1100, &adc_chars);
  return adc_chars.vref;
}
/********************************************************************************************************
@brief: Returns voltage at the input of the ADC.

@param: vref - reference voltage
@param: calibration of the adc.
*********************************************************************************************************
*/
float get_voltage(const uint8_t adc_pin_number,const float vref,const  float calibration){
  int adc_val = analogRead(adc_pin_number);
  //Serial.printf("ADC Value: %d.\n",adc_val);
	return (adc_val / 4095.0) * 3.3 * (1100 / vref) * calibration;;
}

void init_memory(fs::FS &filemanager){
  //Serial.print("Configuring memory...");
  if(!LittleFS.begin(FORMAT_LITTLEFS_IF_FAILED)){
    //Serial.print("Memory failed to format.\n");
    while(1);
  }
  //Serial.print("Done.\n");
}
/*******************************************************************************************************
@brief: write a  data entry into the file.
@param: reference to the file.
@param: filename- data filename
@param: message - message to write into data file.
********************************************************************************************************
*/
//writes given data to the file.
void write_line(fs::FS &file, const char* filename, const char* message){
  //Serial.printf("Writing %s to the file %s, ...",message, filename);
    File root = file.open(filename, FILE_APPEND);
    if(!root){
        return ;
    }else{
      root.print(message);
      root.close();
    }
    //Serial.print("Done.\n");
}
/******************************************************************************************
@brief: retrieves data from the storage

@param: root - the root file
@param: data - pointer to data structure
*******************************************************************************************
*/
int get_data(File* root, data_entry_t* data){
  //Serial.print("get_data function invoked... processing....\n");
  char c;
  String id;
  String weight;
  int spaces = 0;
  String time;
  bool processed = false;
  while(root->available()>0){
    c = root->read();
    //Serial.print("Character Read: ");
    //Serial.println(c);
    if (c == ' '){
      spaces++;
      c = root->read();
    }
    if(spaces == 0){
      id+=c;
     // Serial.println("Current_ID: "+id);
    }else if(spaces == 1){
      time+=c;
      //Serial.println("Current Time: "+time);
    }else if (spaces == 2){
      weight+=c;
      //Serial.println("Current Weight: "+weight);
    }
    if(c == '\n'){
      //Serial.print("End of Line.\n");
      processed = true;
      break;
    }
  }
  if(processed){

    data->tag_id = id;
    data->time = time;
    data->weight = atof(weight.c_str());
    //Serial.printf("Return Value %d\n",DATA_READ_OK);
    return DATA_READ_OK;
  }
  //Serial.printf("Return Value: %d\n",END_OF_DATA_FILE);
  return END_OF_DATA_FILE;
}

/**********************************************************************************************************
@brief: Initailise WiFi Access point with the given ssid and password, other deives can connect to this.

@param: ssid - WiFi SSID
@param: password - password of the WiFi.
***********************************************************************************************************
*/
void init_wifi(const char* ssid, const char* password){
  WiFi.softAP(ssid,password);
}

/**********************************************************************************************************
@brief: Samples analag signal when RFID is within the Range and write it to the data file.

***********************************************************************************************************
**/
void data_acquire()
{
  //Serial.println("Bring Card Closer...");
  float vref = init_adc(); //Initialize the ADC
  char c;
  while (RFID.available()> 0) {
    //Serial.print("Reading Card...\n");
    delay(5);
    c = RFID.read();
    tag_id += c;
    //float volt = get_voltage(ADC_SCALE_PIN,vref,calibration);
    //kalman_filter(volt,0.05,&measurement);
    
    //function to continuously get the adc  samples here
  }
  //gcvt(measurement.curr_est,10,FLOAT);
  //prepare the Tag ID
  if(tag_id.length() > 11){
    tag_id = tag_id.substring(1,11); // Extract the Tag ID
    Serial.println("Tag ID: "+tag_id);
  }
  Tag_ID = tag_id.c_str();
  //data_entry = tag_id + " " + time+" " ;
  Serial.printf("Sleeping...");
  delay(2000);
  esp_deep_sleep_start();
}

/***********************************************************************************************************
*@brief: Returns the current time in the form: HH:MM:SS
************************************************************************************************************
*/
void get_time(char* time_str){
    RTC_DS3231 rtc;
    time_str[0] = ' '; //add empty space
    if(!rtc.begin()) {
      Serial.println("RTC Module not Found");
      while(1);
    }
    if(set_time == 0) {
      rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
      set_time = 1;
    }
    DateTime now = rtc.now(); //Get the current Time
    if(now.hour()<10){
      time_str[1] = '0';
      time_str[2] = 48 + now.hour();
    }else{
      int quot = now.hour()/10; //gets the first digit
      int rem = now.hour()%10; //gets the second digit
      time_str[1] = 48+quot;
      time_str[2] = 48+rem;
    }
    time_str[3] = ':';
    if(now.minute()<10){
      time_str[4] = '0';
      time_str[5] = 48+now.minute();
    }else {
      int quot = now.minute()/10; //gets the first digit
      int rem = now.minute()%10; //gets the second digit
      time_str[4] = 48+quot;
      time_str[5] = 48+rem;
    }
    time_str[6] = ':';
    if(now.second()<10) {
      time_str[7] = '0';
      time_str[8] = 48+now.second();
    }else{
       int quot = now.second()/10; //gets the first digit
      int rem = now.second()%10; //gets the second digit
      time_str[7] = 48+quot;
      time_str[8] = 48+rem;
    }
    
}
void setup() {
  // put your setup code here, to run once:
  delay(1000);
  Serial.begin(115200);
  RFID.begin(9600); //starting UART connection
  pinMode(RFID_INTERRUPT_PIN,INPUT_PULLUP);
  esp_sleep_enable_ext0_wakeup((gpio_num_t)RFID_INTERRUPT_PIN,LOW);
  data_acquire();
}

void loop() {
  // put your main code here, to run repeatedly:
  //data_acquire();
 //elay(500);
}

