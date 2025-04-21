#include "Motor.h"

static Motor* refs[2] = {NULL, NULL};

Motor::Motor(uint8_t component, int pin, BLEServiceRunner& ble)
: _pin(pin)
, _powerControlChar(ble.characteristic(component, "020001", (uint8_t*)NULL, updatePower))
, _powerFeedbackChar(ble.characteristic(component, "020002", &_motorPower))
, _calibrationChar(ble.characteristic(component, "010000", &_motorCalibration, updateCalibration))
{
  refs[component-1] = this;
}

void Motor::begin() 
{
  _motor.attach(_pin);
}

void Motor::update()
{
  int8_t actualPower = (abs(_motorPower) < _motorCalibration) ? _motorPowerStop : _motorPower;
  int newSignal = map(actualPower, _motorPowerMin, _motorPowerMax, _motorSignalMin, _motorSignalMax);

  if (newSignal != _motorCurrentSignal)
  {
    _powerFeedbackChar.writeValue(actualPower);
    _motorCurrentSignal = newSignal;
    if (_motorCurrentSignal == _motorSignalStop)
    {
      _motor.writeMicroseconds(1500);
    }
    else
    {
      _motor.write(_motorCurrentSignal);
    }
  }
}

void Motor::updatePower(BLEDevice central, BLECharacteristic characteristic)
{
  //characteristic.readValue(This->_motorPower);
  //This->update();
}

void Motor::updateCalibration(BLEDevice central, BLECharacteristic characteristic)
{
  //characteristic.readValue(This->_motorCalibration);
  //This->update();
}