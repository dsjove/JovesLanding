#include <ArduinoBLE.h>
#include <TaskScheduler.h>
#include <Arduino_LED_Matrix.h>
#include <Servo.h>
//#include <EEPROM.h>

#define LED_PIN 3
#define SERVO_PIN 9
#define LIGHT_SENSOR_PIN A0

BLEService _cityStreetsService("00000000-4369-7479-2053-747265657473");
Scheduler _runner;

void setup() {
  system_setup();
  matrix_setup();
  servo_setup();
  lighting_setup();
  bluetooth_setup();
}

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

ArduinoLEDMatrix _matrix;
uint32_t _matrixCurrent[] = {0, 0, 0};

BLECharacteristic _matrixDisplayCharacteristic(
  "07020000-4369-7479-2053-747265657473", 
  BLERead | BLEWriteWithoutResponse | BLENotify, 
  sizeof(_matrixCurrent));

void matrix_setup() {
  _matrix.begin();

  const uint32_t heart[] = {
      0xB194a444,
      0x44042081,
      0x100a0841
  };
  matrix_set(heart);
  _matrixDisplayCharacteristic.writeValue(_matrixCurrent, sizeof(_matrixCurrent));
  _matrixDisplayCharacteristic.setEventHandler(BLEWritten, matrix_updateDisplay);
  _cityStreetsService.addCharacteristic(_matrixDisplayCharacteristic);
}

void matrix_updateDisplay(BLEDevice device, BLECharacteristic characteristic) {
  uint32_t value[3];
  characteristic.readValue(value, sizeof(value));
  matrix_set(value);
}

void matrix_set(const uint32_t request[3]) {
  if (memcmp(request, _matrixCurrent, sizeof(_matrixCurrent)) != 0) {
    memcpy(_matrixCurrent, request, sizeof(_matrixCurrent));
    _matrix.loadFrame(_matrixCurrent);
  }
}

Servo _servo;
const int8_t _servoPowerMin = -127;
const int8_t _servoPowerStop = 0;
const int8_t _servoPowerMax = 127;
const int _servoSignalMin = 0;
const int _servoSignalStop = 90;
const int _servoSignalMax = 180;
int8_t _servoPower = 0;
uint8_t _servoCalibration = _servoPowerMax / 4;
int _servoCurrentSignal = _servoSignalStop;
//const int _epromIdxServoCalibration = 1;

BLECharacteristic _servoPowerControlCharacteristic(
  "02020001-4369-7479-2053-747265657473", 
  BLEWriteWithoutResponse,
  sizeof(_servoPower));
BLECharacteristic _servoPowerFeedbackCharacteristic(
  "02020002-4369-7479-2053-747265657473", 
  BLERead | BLENotify, 
  sizeof(_servoPower));
BLECharacteristic _servoCalibrationCharacteristic(
  "02010000-4369-7479-2053-747265657473", 
  BLERead | BLEWriteWithoutResponse| BLENotify, 
  sizeof(_servoCalibration));

void servo_setup() {
  _servo.attach(SERVO_PIN);

  //if (_firstRun) {
    //EEPROM.write(_epromIdxServoCalibration, _servoCalibration);
  //}
  //else {
    //_servoCalibration = EEPROM.read(_epromIdxServoCalibration);
  //}

  _servoPowerControlCharacteristic.setEventHandler(BLEWritten, servo_updatePower);
  _cityStreetsService.addCharacteristic(_servoPowerControlCharacteristic);

  _servoPowerFeedbackCharacteristic.writeValue(_servoPower);
  _cityStreetsService.addCharacteristic(_servoPowerFeedbackCharacteristic);

  _servoCalibrationCharacteristic.writeValue(_servoCalibration);
  _servoCalibrationCharacteristic.setEventHandler(BLEWritten, servo_updateCalibration);
  _cityStreetsService.addCharacteristic(_servoCalibrationCharacteristic);
}

void servo_updatePower(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_servoPower);
  servo_update();
}

void servo_updateCalibration(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_servoCalibration);
  //EEPROM.write(_epromIdxServoCalibration, _servoCalibration);
  servo_update();
}

void servo_update() {
  //Serial.print(_servoPower);
  //Serial.print("->");
  int8_t actualPower = (abs(_servoPower) < _servoCalibration) ? _servoPowerStop : _servoPower;
  //Serial.print(actualPower);
  //Serial.print("->");
  int newSignal = map(actualPower, _servoPowerMin, _servoPowerMax, _servoSignalMin, _servoSignalMax);
  //Serial.println(newSignal);

  if (newSignal != _servoCurrentSignal) {
    _servoPowerFeedbackCharacteristic.writeValue(actualPower);
    _servoCurrentSignal = newSignal;
    if (_servoCurrentSignal == _servoSignalStop) {
      _servo.writeMicroseconds(1500);
    }
    else {
      _servo.write(_servoCurrentSignal);
    }
  }
}
uint8_t _lightPower = 0;
uint8_t _lightCalibration = 255;
uint8_t _lightSensed = 0;
uint8_t _lightCurrentSignal = 0;

BLECharacteristic _lightPowerControlCharacteristic(
  "03020001-4369-7479-2053-747265657473",
  BLEWriteWithoutResponse,
  sizeof(_lightPower));
BLECharacteristic _lightPowerFeedbackCharacteristic(
  "03020002-4369-7479-2053-747265657473",
  BLERead | BLENotify,
  sizeof(_lightPower));
BLECharacteristic _lightCalibrationCharacteristic(
  "03010000-4369-7479-2053-747265657473",
  BLERead | BLEWriteWithoutResponse| BLENotify,
  sizeof(_lightCalibration));
BLECharacteristic _lightSensedFeedbackCharacteristic(
  "03040002-4369-7479-2053-747265657473",
  BLERead | BLENotify,
  sizeof(_lightSensed));

Task _lightingTask(1000, TASK_FOREVER, &lighting_sense);

void lighting_setup() {
  pinMode(LED_PIN, OUTPUT);
  //pinMode(LIGHT_SENSOR_PIN, INPUT);

  //if (_firstRun) {
    //EEPROM.write(_epromIdxLightingCalibration, _lightCalibration);
  //}
  //else {
    //_lightCalibration = EEPROM.read(_epromIdxLightingCalibration);
  //}

  _lightPowerControlCharacteristic.setEventHandler(BLEWritten, lighting_updatePower);
  _cityStreetsService.addCharacteristic(_lightPowerControlCharacteristic);

  _lightPowerFeedbackCharacteristic.writeValue(_lightPower);
  _cityStreetsService.addCharacteristic(_lightPowerFeedbackCharacteristic);

  _lightCalibrationCharacteristic.writeValue(_lightCalibration);
  _lightCalibrationCharacteristic.setEventHandler(BLEWritten, lighting_updateCalibration);
  _cityStreetsService.addCharacteristic(_lightCalibrationCharacteristic);

  _lightSensedFeedbackCharacteristic.writeValue(_lightSensed);
  _cityStreetsService.addCharacteristic(_lightSensedFeedbackCharacteristic);

  _runner.addTask(_lightingTask);
  _lightingTask.enable();
}

void lighting_updatePower(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_lightPower);
  lighting_update();
}

void lighting_updateCalibration(BLEDevice central, BLECharacteristic characteristic) {
  characteristic.readValue(_lightCalibration);
  //EEPROM.write(_epromIdxLightingCalibration, _lightCalibration);
  lighting_update();
}

void lighting_sense() {
  int sensorValue = analogRead(LIGHT_SENSOR_PIN);
  uint8_t signal = map(sensorValue, 920, 1014, 0, 255);
Serial.println(signal);
  if (signal != _lightSensed) {
    _lightSensed = signal;
    _lightSensedFeedbackCharacteristic.writeValue(_lightSensed);
    lighting_update();
  }
}

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
    _lightPowerFeedbackCharacteristic.writeValue(signal);
    _lightCurrentSignal = signal;
    analogWrite(LED_PIN, signal);
  }
}

Task _bluetoothTask(100, TASK_FOREVER, &bluetooth_task);

void bluetooth_setup() {
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy module failed!");
    while (1);
  }
  BLE.setLocalName("City Streets");
  BLE.setEventHandler(BLEConnected, bluetooth_connected);
  BLE.setEventHandler(BLEDisconnected, bluetooth_disconnected);
  
  BLE.setAdvertisedService(_cityStreetsService);
  BLE.addService(_cityStreetsService);

  int r = BLE.advertise();
  if (r == 1) {
    Serial.println("Bluetooth® device active, waiting for connections...");
    Serial.println();
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
