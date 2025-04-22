#include <TaskScheduler.h>
#include "CityStreets.h"

Scheduler _runner;
CityStreets _cityStreets;

void setup()
{
  Serial.begin(9600);
  while (!Serial);
  _cityStreets.begin(_runner);
}

void loop()
{
  _runner.execute();
}

//#include <EEPROM.h>
//const int _epromIdxFirstRun = 0;
//bool _firstRun = true;
  //_firstRun = EEPROM.read(_epromIdxFirstRun) == 0;
  //if (_firstRun) {
    //Serial.println("First Run!");
    //EEPROM.write(_epromIdxFirstRun, 1);
  //}
