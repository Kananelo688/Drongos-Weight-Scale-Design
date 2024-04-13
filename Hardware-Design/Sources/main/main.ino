#include "main.h"


//testing kalman filter
int num_measurements = 10;
const int array[] = {1123,1119,1119,1119,1113,1120,1072,1119,1136,1122};
void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  system_init();
  Serial.print("Testing Kalman Filter...\n");
}

void loop() {
  float predicted_val = 1.1; //initial estimate
  float predicted_var = 0.01 + KALMAN_PROCESS_NOISE;
  float current_var = 0.01;
  float measure_var = 0.01;
  for (int i =0; i<num_measurements; i++){
    float input = get_input(array[i],ADC_OFFSET_ERROR,ADC_GAIN_ERROR);
    Serial.printf("Current Measurement: %.2f v\n", input);
    kalman(input,measure_var,&predicted_val, &predicted_var, &current_var);
    Serial.printf("Extrapolated Measurement: %.2f v\n", predicted_var);
    delay(1000);
  }
   delay(1000);
  // put your main code here, to run repeatedly:

}
