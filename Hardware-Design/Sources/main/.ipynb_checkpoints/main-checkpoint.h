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
#define ADC_OFFSET_ERROR  -159
#define ADC_GAIN_ERROR (3277/3502)
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

void kalman(const uint16_t measurement, // Measured ADC value
	   const float* measurement_variance,  // Approximate variance of the measured Value
	   float* predicted_estimate, // extrapolated estimate
	   float* predicted_estimate_variance, // estrapolated variance
	   float* current_estiname_variance, // current estimate
	   float* process_noise_variance // process noise ( approximated or measured)
	   );


float get_adc(uint8_t adc_pin_number, //The ADC pin number from which to read data from
	      int16_t* offset_error, // The offset error of the ADC determined during calibration
	      float* gain_error // The gain error of the ADC determined during calibratio process
	      );
	  
float getweight(float* filtered_adc_value //The final value of ADC approximted with kalman()
		);

//---------------------------RFID Tag Detecting and Reading Fucntions----------------------------//




//----------------------------Data Retrieval and Communication Functions-------------------------//



//------------------------------Power Control Functions------------------------------------------//

#endif





































