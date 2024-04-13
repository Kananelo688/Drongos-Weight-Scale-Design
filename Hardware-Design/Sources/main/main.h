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
//----------------------------------MACROS-----------------------------------------------------//
#define ADC_OFFSET_ERROR  (-159.75)  //obtained during calibration
#define ADC_GAIN_ERROR 	(1326.51515151) //obtained during calibration
#define KALMAN_PROCESS_NOISE   (0)
#define ADC_SCALE_PIN 34
//---------------------------------Global Constants---------------------------------------------//
const float PROCESS_NOISE = 1000; //Just A rough Estimate
//---------------------------------Global Variables---------------------------------------------//


//---------------------------------System Setup Functions---------------------------------------//

/**
*Function that initializes the system parameters such as WiFi Access Point
*/

void system_init();

//-----------------------Data Acquisition Fucntions---------------------------------------------//
//Sets up the adc of 
/**
* @brief: Function filters the measure adc samples using Kalman Filter Algorithm. 
* 
*@param: measurement- a 16-bit ADC sample value.
*@param: measurement_variance - the estimated or measured variance of that ADC.
*@param: predicted_estimate -extrapolated ADC sample.
*/

void kalman(const float input_voltage,const float meas_var,float* predicted_voltage, float* predicted_voltage_variance,float* currrent_var);

float get_input(const uint8_t adc_pin_number,float offset, float gain);
	  
float get_weight(const float filtered_adc_value);

//---------------------------RFID Tag Detecting and Reading Fucntions----------------------------//




//----------------------------Data Retrieval and Communication Functions-------------------------//



//------------------------------Power Control Functions------------------------------------------//

#endif





































