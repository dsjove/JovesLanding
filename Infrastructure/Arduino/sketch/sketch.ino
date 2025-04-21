#include "citystreets.h"

#include <TaskScheduler.h>
//#include <EEPROM.h>
#include "BLEServiceRunner.h"

#ifdef HAS_MATRIX
#include "MatrixR4.h"
#endif
#ifdef HAS_MOTOR
#include "Motor.h"
#endif
#ifdef HAS_LIGHTING
#include "Lighting.h"
#endif

BLEServiceRunner _ble(BLELocalName);

#ifdef HAS_MATRIX
MatrixR4 matrixR4(_ble);
#endif

#ifdef HAS_MOTOR
Motor motor(2, SERVO_PIN, _ble);
#endif

#ifdef HAS_LIGHTING
Lighting lighting(LIGHT_OUTPUT, LIGHT_SENSOR_PIN, _ble);
#endif

Scheduler _runner;

void setup()
{
  system_begin();

#ifdef HAS_MATRIX
  matrixR4.begin();
#endif

#ifdef HAS_MOTOR
  motor.begin();
#endif

#ifdef HAS_LIGHTING
  lighting.begin(_runner);
#endif

  _ble.begin(_runner);
}

void loop()
{
  _runner.execute();
}

//const int _epromIdxFirstRun = 0;
//bool _firstRun = true;

void system_begin()
{
  Serial.begin(9600);
  while (!Serial);

  //_firstRun = EEPROM.read(_epromIdxFirstRun) == 0;
  //if (_firstRun) {
    //Serial.println("First Run!");
    //EEPROM.write(_epromIdxFirstRun, 1);
  //}
}
