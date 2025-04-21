#include "MatrixR4.h"

static MatrixR4* matrixRefR4 = NULL;

MatrixR4::MatrixR4(BLEServiceRunner& ble)
: _displayChar(ble.characteristic("07020000", &_current, updateDisplay))
{
  matrixRefR4 = this;
}

void MatrixR4::begin()
{
  _matrix.begin();
  _matrix.loadFrame(_current);
}

void MatrixR4::updateDisplay(BLEDevice device, BLECharacteristic characteristic)
{
  uint32_t value[3];
  characteristic.readValue(value, sizeof(value));
  matrixRefR4->set(value);
}

void MatrixR4::set(const uint32_t request[3])
{
  if (memcmp(request, _current, sizeof(_current)) != 0)
  {
    memcpy(_current, request, sizeof(_current));
    _matrix.loadFrame(_current);
  }
}