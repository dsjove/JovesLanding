struct LightOutput {
	int pin;
	bool dimmable;
};

#include "citystreets.h"

#include <TaskScheduler.h>
//#include <EEPROM.h>
#ifdef HAS_MATRIX
#include <Arduino_LED_Matrix.h>
#endif
#ifdef SERVO_PIN
#include "Motor.h"
#endif
#ifdef BLELocalName
#include "BLEServiceRunner.h"
#endif

Scheduler _runner;
#ifdef BLELocalName
BLEServiceRunner _ble(BLELocalName);
Motor m(2, 0, _ble);
#endif

void setup() {
  system_begin();
#ifdef HAS_MATRIX
  matrix_begin();
#endif
#ifdef HAS_MOTOR
  motor_begin();
#endif
#ifdef HAS_LIGHTING
  lighting_begin();
#endif
#ifdef BLELocalName
  _ble.begin(_runner);
#else
  Serial.println("NO BLE Enabled");
#endif
}

void loop() {
  _runner.execute();
}

//const int _epromIdxFirstRun = 0;
//bool _firstRun = true;

void system_begin() {
  Serial.begin(9600);
  while (!Serial);

  //_firstRun = EEPROM.read(_epromIdxFirstRun) == 0;
  //if (_firstRun) {
    //Serial.println("First Run!");
    //EEPROM.write(_epromIdxFirstRun, 1);
  //}
}

#ifdef HAS_MATRIX
ArduinoLEDMatrix _matrix;
uint32_t _matrixCurrent[3] = {
      0xB194a444,
      0x44042081,
      0x100a0841
  };

#ifdef BLELocalName
BLECharacteristic _matrixDisplayChar = _ble.characteristic("07020000", &_matrixCurrent, matrix_updateDisplay);
#endif

void matrix_begin() {
  _matrix.begin();
  _matrix.loadFrame(_matrixCurrent);
}

#ifdef BLELocalName
void matrix_updateDisplay(BLEDevice device, BLECharacteristic characteristic) {
  uint32_t value[3];
  characteristic.readValue(value, sizeof(value));
  matrix_set(value);
}
#endif

void matrix_set(const uint32_t request[3]) {
  if (memcmp(request, _matrixCurrent, sizeof(_matrixCurrent)) != 0) {
    memcpy(_matrixCurrent, request, sizeof(_matrixCurrent));
    _matrix.loadFrame(_matrixCurrent);
  }
}
#endif

#ifdef HAS_MOTOR
#ifdef SERVO_PIN
Servo _motor;
#endif
const int8_t _motorPowerMin = -127;
const int8_t _motorPowerStop = 0;
const int8_t _motorPowerMax = 127;
const int _motorSignalMin = 0;
const int _motorSignalStop = 90;
const int _motorSignalMax = 180;
int8_t _motorPower = 0;
uint8_t _motorCalibration = _motorPowerMax / 4;
int _motorCurrentSignal = _motorSignalStop;
//const int _epromIdxServoCalibration = 1;

#ifdef BLELocalName
BLECharacteristic _motorPowerControlChar = _ble.characteristic("02020001", (uint8_t*)NULL, motor_updatePower);
BLECharacteristic _motorPowerFeedbackChar = _ble.characteristic("02020002", &_motorPower);
BLECharacteristic _motorCalibrationChar = _ble.characteristic("02010000", &_motorCalibration, motor_updateCalibration);
#endif

void motor_begin() {
#ifdef SERVO_PIN
  _motor.attach(SERVO_PIN);
#endif
  //if (_firstRun) {
    //EEPROM.write(_epromIdxServoCalibration, _motorCalibration);
  //}
  //else {
    //_motorCalibration = EEPROM.read(_epromIdxServoCalibration);
  //}
}

#ifdef BLELocalName
void motor_updatePower(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_motorPower);
  motor_update();
}

void motor_updateCalibration(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_motorCalibration);
  //EEPROM.write(_epromIdxServoCalibration, _motorCalibration);
  motor_update();
}
#endif

void motor_update() {
  int8_t actualPower = (abs(_motorPower) < _motorCalibration) ? _motorPowerStop : _motorPower;
  int newSignal = map(actualPower, _motorPowerMin, _motorPowerMax, _motorSignalMin, _motorSignalMax);

  if (newSignal != _motorCurrentSignal) {
#ifdef BLELocalName
    _motorPowerFeedbackChar.writeValue(actualPower);
#endif
    _motorCurrentSignal = newSignal;
#ifdef SERVO_PIN
    if (_motorCurrentSignal == _motorSignalStop) {
      _motor.writeMicroseconds(1500);
    }
    else {
      _motor.write(_motorCurrentSignal);
    }
#else
  Serial.print("Motor -> ");
  Serial.println(newSignal);
#endif
  }
}
#endif

#ifdef HAS_LIGHTING
#ifdef LIGHT_OUTPUT
const LightOutput _lightOutput[] = LIGHT_OUTPUT;
#endif
uint8_t _lightPower = 0;
uint8_t _lightCalibration = 255;
uint8_t _lightSensed = 0;
uint8_t _lightCurrentSignal = 0;

#ifdef BLELocalName
BLECharacteristic _lightPowerControlChar = _ble.characteristic("03020001", (uint8_t*)NULL, lighting_updatePower);
BLECharacteristic _lightPowerFeedbackChar = _ble.characteristic("03020002", &_lightPower);
BLECharacteristic _lightCalibrationChar = _ble.characteristic("03010000", &_lightCalibration, lighting_updateCalibration);
#ifdef LIGHT_SENSOR_PIN
BLECharacteristic _lightSensedFeedbackChar = _ble.characteristic("03040002", &_lightSensed);
#else
BLECharacteristic _lightSensedFeedbackChar = _ble.characteristic("03040002", &_lightSensed, lighting_updateSensed);
#endif
#endif

#ifdef LIGHT_SENSOR_PIN
Task _lightingTask(1000, TASK_FOREVER, &lighting_sense);
#endif

void lighting_begin() {
  #ifdef LIGHT_OUTPUT
  for (LightOutput light : _lightOutput) {
    pinMode(light.pin, OUTPUT);
  }
  #endif

  //if (_firstRun) {
    //EEPROM.write(_epromIdxLightingCalibration, _lightCalibration);
  //}
  //else {
    //_lightCalibration = EEPROM.read(_epromIdxLightingCalibration);
  //}
#ifdef LIGHT_SENSOR_PIN
  _runner.addTask(_lightingTask);
  _lightingTask.enable();
#endif
}

#ifdef BLELocalName
void lighting_updatePower(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_lightPower);
  lighting_update();
}

void lighting_updateCalibration(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_lightCalibration);
  //EEPROM.write(_epromIdxLightingCalibration, _lightCalibration);
  lighting_update();
}
#endif

#ifdef LIGHT_SENSOR_PIN
void lighting_sense() {
  int sensorValue = analogRead(LIGHT_SENSOR_PIN);
  uint8_t signal = map(sensorValue, 920, 1014, 0, 255);
  if (signal != _lightSensed) {
    _lightSensed = signal;
#ifdef BLELocalName
    _lightSensedFeedbackChar.writeValue(_lightSensed);
#endif
    lighting_update();
  }
}
#else
#ifdef BLELocalName
void lighting_updateSensed(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_lightSensed);
  lighting_update();
}
#endif
#endif

void lighting_update() {
  const uint8_t powerMin = 0;
  const uint8_t powerStop = 0;
  const uint8_t powerMax = 255;

  uint8_t signal;
  if (_lightCalibration == 0 || _lightCalibration < _lightSensed) {
      signal = 0;
  }
  else {
      signal = _lightPower;
  }

  if (signal != _lightCurrentSignal) {
  #ifdef BLELocalName
    _lightPowerFeedbackChar.writeValue(signal);
  #endif
    _lightCurrentSignal = signal;

  #ifdef LIGHT_OUTPUT
  for (LightOutput light : _lightOutput) {
      if (light.dimmable) {
        analogWrite(light.pin, signal);
      }
      else {
        digitalWrite(light.pin, signal);
      }
  }
  #else
    Serial.print("Light -> ");
    Serial.println(signal);
  #endif
  }
}
#endif
