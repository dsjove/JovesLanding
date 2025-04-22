#pragma once
#include "BLEServiceRunner.h"
#include "MatrixR4.h"
#include "ServoMotor.h"
#include "Lighting.h"

class CityStreets {
public:
  CityStreets();
  
  void begin(Scheduler& scheduler);

private:
  BLEServiceRunner _ble;
  MatrixR4 _matrixR4;
  Lighting _lighting;
  ServoMotor _servoMotor;
};
