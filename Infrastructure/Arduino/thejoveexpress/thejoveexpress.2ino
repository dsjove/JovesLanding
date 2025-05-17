#include <TaskScheduler.h>

#include "shared/BLEServiceRunner.cpp"
#include "shared/Lighting.cpp"

Scheduler _runner;
BLEServiceRunner _ble("City Streets");
Lighting _lighting({{3, true}, {0, false}}, A0, _ble);

void setup()
{
  Serial.begin(9600);
  while (!Serial);

  _ble.begin(_runner);
  _lighting.begin(_runner);
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
