#include <Arduino.h>

#define ADC_PIN 34

uint16_t multisample(uint8_t k){
    uint16_t accum = 0;
    for (int i =0; i <k; i++){
      accum += analogRead(ADC_PIN);
    }
    return (uint16_t) accum/k;
}
void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  analogReadResolution(12);
  Serial.println("ADC Calibration.\n");
  Serial.print("Connect Analog Voltage of pin: ");
  Serial.println(ADC_PIN);
}

void loop() {
  // put your main code here, to run repeatedly:
  uint16_t adcValue = multisample(1);
  Serial.printf("%d,\n",adcValue);
}
