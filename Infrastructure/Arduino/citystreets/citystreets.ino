#include "shared/BLEServiceRunner.cpp"
#include "shared/MatrixR4.cpp"
#include "shared/ServoMotor.cpp"
#include "shared/Lighting.cpp"

#include <TaskScheduler.h>

Scheduler _runner;
BLEServiceRunner _ble("City Streets");
MatrixR4 _matrixR4(_ble);
Lighting _lighting(_ble, {{3, true}, {0, false}}, A0);
ServoMotor _servoMotor(_ble, 9);

void setup()
{
  Serial.begin(9600);
  while (!Serial);

  _ble.begin(_runner);
  _matrixR4.begin();
  _lighting.begin(_runner);
  _servoMotor.begin();
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
