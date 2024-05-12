////////////////////////////////////////////////////////////
//@brief: Sketch that collect data for calibratin ADC
///
// @author: Kananelo Chabeli
////////////////////////////////////////////////////////////


//includes

#include <Arduino.h>

//defines

#define ADC_PIN_NUMBER 39

//returns the average of adc samples. ( reducing effect of quantization noise)
uint16_t multisample(int ADC_PIN, int k){
  int val=0;
  for(int i=0;i<k;k++){
    val+=analogRead(ADC_PIN); 
  }
  return val/k; //return the average
}
void setup() {
  Serial.begin(115200);
  Serial.println("********************ADC Calibration Process*************")
}

void loop() {
  // put your main code here, to run repeatedly:
  int value = multisample(ADC_PIN_NUMBER,10); //get aaverage of 10 samples
  Serial.printf("ADC Value: %d",value);
  delay(5000);
}
