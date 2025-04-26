#include "CityStreets.h"

CityStreets::CityStreets()
: _ble("City Streets")
, _matrixR4(_ble)
, _lighting({{3, true}, {0, false}}, A0, _ble)
, _servoMotor(9, _ble)
{
}

void CityStreets::begin(Scheduler& scheduler)
{
  _ble.begin(scheduler);
  _matrixR4.begin();
  _lighting.begin(scheduler);
  _servoMotor.begin();
}
