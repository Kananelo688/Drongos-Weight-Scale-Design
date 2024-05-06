
/**
 * A C++ source file that implements fucntion prototypes in 'main.h' Interface.
 * 
 * @author: Kananelo Chabeli
 * */


#include "main.h"


float get_voltage_custom(uint8_t adc_pin_number){
  float calibrated_code = (analogRead(adc_pin_number) - OFFSET_ERROR)*(IDEAL_SLOPE/NON_IDEAL_SLOPE);
  return (calibrated_code / pow(2.0,12))*3.3;
}

//----------------------------------Sytem Control Functions----------------------------------------------------------------//
void system_init(){
  analogReadResolution(12);
}


//----------------------------------Data Acqusition Function Definitions---------------------------------------------------//

void kalman_filter(const float voltage, const float volt_var, measurement_t* meas,const float proc_noise = 0.0f){
  
  //Calculate Kalman Gain
  float gain = meas ->curr_est_var/(volt_var + meas -> curr_est_var);

  //calculate the current estimate
  meas ->curr_est = meas->curr_est+ gain*(voltage - meas->curr_est);

  //Compute Measurement Error
  meas->curr_est_var = (1-gain)*meas->curr_est_var;
}

float get_voltage(const uint8_t adc_pin_number,float vref, float calibration){
  int adc_val = analogRead(adc_pin_number);
  //Serial.printf("ADC Value: %d.\n",adc_val);
	return (adc_val / 4095.0) * 3.3 * (1100 / vref) * calibration;;
}
float init_adc(){
  esp_adc_cal_characteristics_t adc_chars;
  esp_adc_cal_characterize(ADC_UNIT_1, ADC_ATTEN_DB_11, ADC_WIDTH_BIT_12, 1100, &adc_chars);
  return adc_chars.vref;
}
	  
float get_weight(const float filtered_adc_input)
{
	//TO:DO
	return 0.01;
}


String read_id(SoftwareSerial& rfid){
  char c ;
  String retVal;
  while(rfid.available()>0){
    c = rfid.read();
    retVal+=c;
  }

  if(retVal.length()>20){
    retVal = retVal.substring(1,11);
  }
  Serial.println("No Tag Detected. Sleeping...");
  delay(1000); //wait 10 seconds before 
  return retVal;
}
//-----------------------Data Communication and Connection Fucntions----------------------------------//
void init_wifi(const char* ssid, const char* password){
  WiFi.softAP(ssid,password);
}
//returns the server object
//Initialized Memory
void init_memory(fs::FS &filemanager){
  Serial.print("Configuring memory...");
  if(!LittleFS.begin(FORMAT_LITTLEFS_IF_FAILED)){
    Serial.print("Memory failed to format.\n");
  }
  Serial.print("Done.\n");
}
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
//reads the entire file as a string.
char* read_all(fs::FS &file, const char* filename){
    //Serial.print("Reading data...");
    File root = file.open(filename); //open the file in open
    int length = root.size();
    char* data =(char*) malloc(length+1);
    data[length] = '\0';
    if(!root){
      Serial.print("Failed to open file.\n");
      free(data);
      return NULL;
    }
    int i =0;
    while(root.available()){
      data[i] = root.read();
      i++;
    }
   // Serial.print("Done.\n");
    //delete the current data file,
   file.remove(filename);
    return data; //this should be allocated by the system
}
//----------------------------
// typedef struct data_entry_t{
//   String tag_id;
//   String time;
//   float weight;
// };
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



















