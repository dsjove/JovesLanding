#define BTChar(x) x "-" BTService
#define BTServiceIdentifier BTChar("00000000")

#include "citystreets.h"

#include <TaskScheduler.h>
//#include <EEPROM.h>
#ifdef HAS_MATRIX
#include <Arduino_LED_Matrix.h>
#endif
#ifdef SERVO_PIN
#include <Servo.h>
#endif
#ifdef BTService
#include <ArduinoBLE.h>
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
#ifdef BTService
  bluetooth_setup();
#endif
}

Scheduler _runner;

#ifdef BTService
BLEService _btService(BTServiceIdentifier);
#endif

void loop() {
  _runner.execute();
}

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
uint32_t _matrixCurrent[] = {0, 0, 0};

#ifdef BTService
BLECharacteristic _matrixDisplayCharacteristic(
  BTChar("07020000"), 
  BLERead | BLEWriteWithoutResponse | BLENotify, 
  sizeof(_matrixCurrent));
#endif

void matrix_setup() {
  _matrix.begin();

  const uint32_t heart[] = {
      0xB194a444,
      0x44042081,
      0x100a0841
  };
  matrix_set(heart);
#ifdef BTService
  _matrixDisplayCharacteristic.writeValue(_matrixCurrent, sizeof(_matrixCurrent));
  _matrixDisplayCharacteristic.setEventHandler(BLEWritten, matrix_updateDisplay);
  _btService.addCharacteristic(_matrixDisplayCharacteristic);
#endif
}

#ifdef BTService
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

#ifdef BTService
BLECharacteristic _motorPowerControlCharacteristic(
  BTChar("02020001"), 
  BLEWriteWithoutResponse,
  sizeof(_motorPower));
BLECharacteristic _motorPowerFeedbackCharacteristic(
  BTChar("02020002"), 
  BLERead | BLENotify, 
  sizeof(_motorPower));
BLECharacteristic _motorCalibrationCharacteristic(
  BTChar("02010000"), 
  BLERead | BLEWriteWithoutResponse| BLENotify, 
  sizeof(_motorCalibration));
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

#ifdef BTService
  _motorPowerControlCharacteristic.setEventHandler(BLEWritten, motor_updatePower);
  _btService.addCharacteristic(_motorPowerControlCharacteristic);

  _motorPowerFeedbackCharacteristic.writeValue(_motorPower);
  _btService.addCharacteristic(_motorPowerFeedbackCharacteristic);

  _motorCalibrationCharacteristic.writeValue(_motorCalibration);
  _motorCalibrationCharacteristic.setEventHandler(BLEWritten, motor_updateCalibration);
  _btService.addCharacteristic(_motorCalibrationCharacteristic);
#endif
}

#ifdef BTService
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
#ifdef BTService
    _motorPowerFeedbackCharacteristic.writeValue(actualPower);
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
uint8_t _lightPower = 0;
uint8_t _lightCalibration = 255;
uint8_t _lightSensed = 0;
uint8_t _lightCurrentSignal = 0;

#ifdef BTService
BLECharacteristic _lightPowerControlCharacteristic(
  BTChar("03020001"),
  BLEWriteWithoutResponse,
  sizeof(_lightPower));
BLECharacteristic _lightPowerFeedbackCharacteristic(
  BTChar("03020002"),
  BLERead | BLENotify,
  sizeof(_lightPower));
BLECharacteristic _lightCalibrationCharacteristic(
  BTChar("03010000"),
  BLERead | BLEWriteWithoutResponse| BLENotify,
  sizeof(_lightCalibration));
BLECharacteristic _lightSensedFeedbackCharacteristic(
  BTChar("03040002"),
#ifdef LIGHT_SENSOR_PIN
  BLERead | BLENotify,
#else
  BLERead | BLEWriteWithoutResponse| BLENotify,
#endif
  sizeof(_lightSensed));
#endif

#ifdef LIGHT_SENSOR_PIN
Task _lightingTask(1000, TASK_FOREVER, &lighting_sense);
#endif

void lighting_setup() {
  #ifdef LED_PIN
  pinMode(LED_PIN, OUTPUT);
  #endif

  //if (_firstRun) {
    //EEPROM.write(_epromIdxLightingCalibration, _lightCalibration);
  //}
  //else {
    //_lightCalibration = EEPROM.read(_epromIdxLightingCalibration);
  //}

#ifdef BTService
  _lightPowerControlCharacteristic.setEventHandler(BLEWritten, lighting_updatePower);
  _btService.addCharacteristic(_lightPowerControlCharacteristic);

  _lightPowerFeedbackCharacteristic.writeValue(_lightPower);
  _btService.addCharacteristic(_lightPowerFeedbackCharacteristic);

  _lightCalibrationCharacteristic.writeValue(_lightCalibration);
  _lightCalibrationCharacteristic.setEventHandler(BLEWritten, lighting_updateCalibration);
  _btService.addCharacteristic(_lightCalibrationCharacteristic);

  _lightSensedFeedbackCharacteristic.writeValue(_lightSensed);
#ifndef LIGHT_SENSOR_PIN
  _lightSensedFeedbackCharacteristic.setEventHandler(BLEWritten, lighting_updateSensed);
#endif
  _btService.addCharacteristic(_lightSensedFeedbackCharacteristic);
#endif
#ifdef LIGHT_SENSOR_PIN
  _runner.addTask(_lightingTask);
  _lightingTask.enable();
#endif
}

#ifdef BTService
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
#ifdef BTService
    _lightSensedFeedbackCharacteristic.writeValue(_lightSensed);
#endif
    lighting_update();
  }
}
#else
#ifdef BTService
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
  #ifdef BTService
    _lightPowerFeedbackCharacteristic.writeValue(signal);
  #endif
    _lightCurrentSignal = signal;
  #ifdef LED_PIN
    analogWrite(LED_PIN, signal);
  #else
    Serial.print("Light -> ");
    Serial.println(signal);
  #endif
  }
}
#endif

#ifdef BTService
Task _bluetoothTask(100, TASK_FOREVER, &bluetooth_task);

void bluetooth_setup() {
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy module failed!");
    while (1);
  }
  #ifdef BTLocalName
  BLE.setLocalName(BTLocalName);
  #endif
  BLE.setEventHandler(BLEConnected, bluetooth_connected);
  BLE.setEventHandler(BLEDisconnected, bluetooth_disconnected);
  
  BLE.setAdvertisedService(_btService);
  BLE.addService(_btService);

  int r = BLE.advertise();
  if (r == 1) {
    Serial.println("Bluetooth® device active, waiting for connections...");
    Serial.println(BTLocalName);
    Serial.println(BTServiceIdentifier);
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
