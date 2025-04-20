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
#include <Servo.h>
#endif
#ifdef BLEFacilityID
#include "BTServiceID.h"
#endif

void setup() {
  system_setup();
#ifdef HAS_MATRIX
  matrix_setup();
#endif
#ifdef HAS_MOTOR
  motor_setup();
#endif
#ifdef HAS_LIGHTING
  lighting_setup();
#endif
#ifdef BLEFacilityID
  bluetooth_setup();
#else
  Serial.println("NO BLE Enabled");
#endif
}

Scheduler _runner;
void loop() {
  _runner.execute();
}

#ifdef BLEFacilityID
BTServiceID _bleID(BLEFacilityID);
BLEService _bleService(_bleID);
#define BTChar(x) x "-" BLEFacilityID
#endif

//const int _epromIdxFirstRun = 0;
//bool _firstRun = true;

void system_setup() {
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

#ifdef BLEFacilityID
BLECharacteristic _matrixDisplayChar = _bleID.characteristic("07020000", &_matrixCurrent, matrix_updateDisplay);
#endif

void matrix_setup() {
  _matrix.begin();
  _matrix.loadFrame(_matrixCurrent);

 #ifdef BLEFacilityID
  _bleService.addCharacteristic(_matrixDisplayChar);
#endif
}

#ifdef BLEFacilityID
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

#ifdef BLEFacilityID
BLECharacteristic _motorPowerControlChar = _bleID.characteristic("02020001", (uint8_t*)NULL, motor_updatePower);
BLECharacteristic _motorPowerFeedbackChar = _bleID.characteristic("02020002", &_motorPower);
BLECharacteristic _motorCalibrationChar = _bleID.characteristic("02010000", &_motorCalibration, motor_updateCalibration);
#endif

void motor_setup() {
#ifdef SERVO_PIN
  _motor.attach(SERVO_PIN);
#endif
  //if (_firstRun) {
    //EEPROM.write(_epromIdxServoCalibration, _motorCalibration);
  //}
  //else {
    //_motorCalibration = EEPROM.read(_epromIdxServoCalibration);
  //}

#ifdef BLEFacilityID
  _bleService.addCharacteristic(_motorPowerControlChar);
  _bleService.addCharacteristic(_motorPowerFeedbackChar);
  _bleService.addCharacteristic(_motorCalibrationChar);
#endif
}

#ifdef BLEFacilityID
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
#ifdef BLEFacilityID
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

#ifdef BLEFacilityID
BLECharacteristic _lightPowerControlChar = _bleID.characteristic("03020001", (uint8_t*)NULL, lighting_updatePower);
BLECharacteristic _lightPowerFeedbackChar = _bleID.characteristic("03020002", &_lightPower);
BLECharacteristic _lightCalibrationChar = _bleID.characteristic("03010000", &_lightCalibration, lighting_updateCalibration);
#ifdef LIGHT_SENSOR_PIN
BLECharacteristic _lightSensedFeedbackChar = _bleID.characteristic("03040002", &_lightSensed);
#else
BLECharacteristic _lightSensedFeedbackChar = _bleID.characteristic("03040002", &_lightSensed, lighting_updateSensed);
#endif
#endif

#ifdef LIGHT_SENSOR_PIN
Task _lightingTask(1000, TASK_FOREVER, &lighting_sense);
#endif

void lighting_setup() {
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

#ifdef BLEFacilityID
  _bleService.addCharacteristic(_lightPowerControlChar);
  _bleService.addCharacteristic(_lightPowerFeedbackChar);
  _bleService.addCharacteristic(_lightCalibrationChar);
  _bleService.addCharacteristic(_lightSensedFeedbackChar);
#endif
#ifdef LIGHT_SENSOR_PIN
  _runner.addTask(_lightingTask);
  _lightingTask.enable();
#endif
}

#ifdef BLEFacilityID
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
#ifdef BLEFacilityID
    _lightSensedFeedbackChar.writeValue(_lightSensed);
#endif
    lighting_update();
  }
}
#else
#ifdef BLEFacilityID
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
  #ifdef BLEFacilityID
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

#ifdef BLEFacilityID
Task _bluetoothTask(100, TASK_FOREVER, &bluetooth_task);

void bluetooth_setup() {
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy module failed!");
    while (1);
  }
  #ifdef BLELocalName
  BLE.setLocalName(BLELocalName);
  #endif
  BLE.setEventHandler(BLEConnected, bluetooth_connected);
  BLE.setEventHandler(BLEDisconnected, bluetooth_disconnected);
  
  BLE.setAdvertisedService(_bleService);
  BLE.addService(_bleService);

  int r = BLE.advertise();
  if (r == 1) {
    Serial.println("Bluetooth® device active, waiting for connections...");
    Serial.println(BLELocalName);
    Serial.println((const char *)_bleID);
  }
  else {
    Serial.println("Bluetooth® activation failed!");
    while (1);
  }
  _runner.addTask(_bluetoothTask);
  _bluetoothTask.enable();
}

void bluetooth_task() {
  BLE.poll();
}

void bluetooth_connected(BLEDevice device) {
  Serial.println();
  Serial.print("BT Connected: ");
  Serial.println(device.address());
}

void bluetooth_disconnected(BLEDevice device) {
  Serial.println();
  Serial.print("BT Disconnected: ");
  Serial.println(device.address());
}
#endif
