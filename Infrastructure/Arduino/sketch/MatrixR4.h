#pragma once
#include <Arduino_LED_Matrix.h>
#include "BLEServiceRunner.h"

class MatrixR4 {
public:
  MatrixR4(BLEServiceRunner& ble);
  
  void begin();

private:
  std::array<uint32_t, 3> _current;

  BLECharacteristic _displayChar;
  static void updateDisplay(BLEDevice device, BLECharacteristic characteristic);

  ArduinoLEDMatrix _matrix;

  void set(const std::array<uint32_t, 3>& data);
};