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
//----------------------------------DEFINES-----------------------------------------------------//

//---------------------------------Function Prototypes------------------------------------------//
/**
  The function Initializes the system, set-up wifi access point, web server and other configuration on 
  boot.
*/
void System_Init(void){

}

#endif