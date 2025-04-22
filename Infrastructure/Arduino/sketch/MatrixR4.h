#pragma once
#include <Arduino_LED_Matrix.h>
#include "BLEServiceRunner.h"

class MatrixR4 {
public:
  MatrixR4(BLEServiceRunner& ble);
  void begin();

private:
  uint32_t _current[3] = {
      0xB194a444,
      0x44042081,
      0x100a0841
  };

  BLECharacteristic _displayChar;
  static void updateDisplay(BLEDevice device, BLECharacteristic characteristic);

  ArduinoLEDMatrix _matrix;

  void set(const uint32_t request[3]);
};