#pragma once

#include <Servo.h>
#include "BLEServiceRunner.h"

class Motor {
public:
  Motor(uint8_t component, int pin, BLEServiceRunner& ble);

  void begin();

private:
  const int _pin;
  Servo _motor;

  const int8_t _motorPowerMin = -127;
  const int8_t _motorPowerStop = 0;
  const int8_t _motorPowerMax = 127;
  const int _motorSignalMin = 0;
  const int _motorSignalStop = 90;
  const int _motorSignalMax = 180;
  int8_t _motorPower = 0;
  uint8_t _motorCalibration = _motorPowerMax / 4;
  int _motorCurrentSignal = _motorSignalStop;
  BLECharacteristic _powerControlChar;
  BLECharacteristic _powerFeedbackChar;
  BLECharacteristic _calibrationChar;

  void update();

  static void updatePower(BLEDevice central, BLECharacteristic characteristic);

  static void updateCalibration(BLEDevice central, BLECharacteristic characteristic);
};
