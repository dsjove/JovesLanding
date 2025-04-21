#pragma once
#include "BLEServiceRunner.h"
#include <TaskScheduler.h>
#include <vector>

struct LightOutput {
	int pin;
	bool dimmable;
};

class Lighting {
public:
  Lighting(std::vector<LightOutput> output, int sensor, BLEServiceRunner& ble);
  void begin(Scheduler& scheduler);

private:
  const std::vector<LightOutput> _output;
  const int _sensor;
  uint8_t _currentPower;
  uint8_t _currentCalibration;
  uint8_t _currentAmbient;
  uint8_t _currentSignal;
  
  BLECharacteristic _powerControlChar;
  BLECharacteristic _powerFeedbackChar;
  BLECharacteristic _calibrationChar;
  BLECharacteristic _sensedFeedbackChar;

  Task _lightingTask;

  static void updatePower(BLEDevice central, BLECharacteristic characteristic);
  static void updateCalibration(BLEDevice central, BLECharacteristic characteristic);
  static void senseAmbient_task();
  static void updateSensed(BLEDevice central, BLECharacteristic characteristic);
  void update();
};
