#include "FS.h"
/**
  An API for the minotroing and controlling systems that weights Drongos Birds in the Kalahari Desert
  This is development in fulfilment of EEE4113F project

  @author: Kananelo Chabeli
  @version: 10/04/2024
*/

#ifndef MAIN_H
#define MAIN_H

//-----------------------------------INCLUDES---------------------------------------------------//
#include <Arduino.h>
#include <string.h> 
#include <WiFi.h> //for setting up WiFi Acces Point
#include <WebServer.h> //for creating web server
#include <stdint.h>
#include <FS.h>
#include <LittleFS.h>
#include "esp_adc_cal.h"
#include <SoftwareSerial.h>
//----------------------------------MACROS-----------------------------------------------------//

#define KALMAN_PROCESS_NOISE   (0)
#define ADC_SCALE_PIN 39
#define USER_BUTTON_PIN 34
#define FORMAT_LITTLEFS_IF_FAILED true
#define DATA_FILENAME "/Data/data.json"
#define END_OF_DATA_FILE -1
#define DATA_READ_OK 1
#define RFID_RX_PIN 5 //recieve pin here
#define RFID_TX_PIN 4 //Transmit pin, if we want to write some data into the bird's tag
#define RFID_INTERRUPT_PIN 27 //GPIO PIN thoruh which interrupt is sent when card is in range

#define OFFSET_ERROR (-175.01)
#define NON_IDEAL_SLOPE 1297.0
#define IDEAL_SLOPE 1241.0

//---------------------------------System Setup Functions---------------------------------------//


float get_voltage_custom(uint8_t adc_pin_number);

//-----------------------------------------------------------------------------------------------//

/**
*Function that initializes the system parameters such as WiFi Access Point
*/

void init_system();

//-----------------------Data Acquisition Fucntions---------------------------------------------//


typedef struct measurement_t{
  float curr_est; //current estimate
  float curr_est_var; //current estimate variance
};

/**
* @brief: Function filters the measure adc samples using Kalman Filter Algorithm. 
*/
void kalman_filter(const float voltage, const float volt_var, measurement_t* meas,const float proc_n);

//initializes and calibrates the adc
float init_adc();

//returns the input voltage given
float get_voltage(const uint8_t adc_pin_number,float vref, float calib);
	  
float get_weight(const float voltage);

//---------------------------RFID Tag Detecting and Reading Fucntions----------------------------//

SoftwareSerial init_rfid();//
String read_id(SoftwareSerial& rfid); //function that reads the Tag ID and returns it.
//----------------------------Data Retrieval and Communication Functions-------------------------//
//Begins WiFi, Sets-up the Access Point
void init_wifi(const char* ssid, const char* password);
//Setting up the WebServer
WebServer init_server();

//--------------------------------------Data management functions----------------------------------//
typedef struct data_entry_t{
  String tag_id;
  String time;
  String data;
  float weight;
};

int get_data(File* root, data_entry_t* data);

float get_battery(void);

void init_memory(fs::FS &filemanager);
//reads line of the file( this returns dynamic pointer and must be freed in the main program)
char* read_all(fs::FS &file, const char* filename);
void write_line(fs::FS &file, const char* filename, const char* message);
//------------------------------Power Control Functions------------------------------------------//

#endif





































