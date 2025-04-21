#include "Motor.h"

static Motor* motorRefs[2] = {NULL, NULL};

Motor::Motor(uint8_t component, int pin, BLEServiceRunner& ble)
: _pin(pin)
, _currentPower(0)
, _currentCalibration(_powerMax / 4)
, _currentSignal(_signalStop)
, _powerControlChar(ble.characteristic(component, "020001", (uint8_t*)NULL, updatePower))
, _powerFeedbackChar(ble.characteristic(component, "020002", &_currentPower))
, _calibrationChar(ble.characteristic(component, "010000", &_currentCalibration, updateCalibration))
{
  motorRefs[0] = this;
}

void Motor::begin() 
{
  _motor.attach(_pin);
}

void Motor::update()
{
  int8_t actualPower = (abs(_currentPower) < _currentCalibration) ? _powerStop : _currentPower;
  int newSignal = map(actualPower, _powerMin, _powerMax, _signalMin, _signalMax);

  if (newSignal != _currentSignal)
  {
    _powerFeedbackChar.writeValue(actualPower);
    _currentSignal = newSignal;
    if (_currentSignal == _signalStop)
    {
      _motor.writeMicroseconds(1500);
    }
    else
    {
      _motor.write(_currentSignal);
    }
  }
}

void Motor::updatePower(BLEDevice central, BLECharacteristic characteristic)
{
  Motor* This = motorRefs[0];
  characteristic.readValue(This->_currentPower);
  This->update();
}

void Motor::updateCalibration(BLEDevice central, BLECharacteristic characteristic)
{
  Motor* This = motorRefs[0];
  characteristic.readValue(This->_currentCalibration);
  This->update();
}