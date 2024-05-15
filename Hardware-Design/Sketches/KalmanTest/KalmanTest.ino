/////////////////////////////////////////////////////////////////
//
//@brief: Skecth that collects data for testing and investigate 
//          Kalman Filter. Uses Calibrated ADC values.
//
// @author: Kananelo Chabeli
/////////////////////////////////////////////////////////////////

//
#include <Arduino.h>


//defines
#define OFFSET_ERROR (-159.01)
#define NON_IDEAL_SLOPE 1297.0
#define IDEAL_SLOPE 1241.0
#define ADC_PIN_NUMBER 39

//Structure that encapsulates  kalman filter estimates
typedef struct measurement_t{
  float curr_est; //current estimate
  float curr_est_var; //current estimate variance
};

measurement_t meas;
//returns the calibrated adc voltage at the given pin
float get_voltage_custom(uint8_t adc_pin_number){
  float calibrated_code = (analogRead(adc_pin_number) - OFFSET_ERROR)*(IDEAL_SLOPE/NON_IDEAL_SLOPE);
  return (calibrated_code / pow(2.0,12))*3.3;
}

//Implements Kalman Filter Algorithm
void kalman_filter(const float voltage, const float volt_var, measurement_t* meas,const float proc_noise = 0.0f){
  
  //Calculate Kalman Gain
  float gain = meas ->curr_est_var/(volt_var + meas -> curr_est_var);
  //calculate the current estimate
  meas ->curr_est = meas->curr_est+ gain*(voltage - meas->curr_est);
  //Compute Measurement Error
  meas->curr_est_var = (1-gain)*meas->curr_est_var;
}

void setup() {
  Serial.begin(1152000);
  Serial.println("***************KALMAN FILTER TESTING SKETCH************************");
  Serial.println("Connect DC power to GPIO39, and set voltage to 2.0V");
  Serial.println("Output is formatted as: <Filter Input>, <Filter Output>");
  //system initial estimates
  meas = {1.57,0.5};//huge estimatin variance
}

void loop() {
  float voltage = get_voltage_custom(ADC_PIN_NUMBER);
  // put your main code here, to run repeatedly:
  kalman_filter(voltage,0.05,&meas,0.002); // set very small process Noise.
  //sprint such that output can nicely be copied to clipbard
  Serial.printf("%f,%f",voltage, meas.curr_est);
}
