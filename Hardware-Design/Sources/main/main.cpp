
/**
 * A C++ source file that implements fucntion prototypes in 'main.h' Interface.
 * 
 * @author: Kananelo Chabeli
 * */


#include "main.h"


//----------------------------------Sytem Control Functions----------------------------------------------------------------//
void system_init(){
  analogReadResolution(12);
}


//----------------------------------Data Acqusition Function Definitions---------------------------------------------------//


void kalman(const float input_voltage,const float meas_var,float* predicted_voltage, float* predicted_var,float* current_var){
	//Step 1: Calculate Kalman Gan
	
	float gain = (*predicted_var)/(*predicted_var+meas_var);

	//Step 2:
	*predicted_voltage = (*predicted_voltage) + gain*(meas_var - *predicted_voltage);

	//Step 3: Calculate next varinace
	*current_var = (1-gain)*(*predicted_var);

	//Step 4: Extra polate the input
	*predicted_var = *current_var + KALMAN_PROCESS_NOISE;
}

float get_input(const uint8_t adc_pin_number,float offset, float gain){
	return (adc_pin_number-offset)/gain;
}
	  
float get_weight(const float filtered_adc_input)
{
	//TO:DO
	return 0.01;
}
