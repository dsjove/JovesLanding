#include "MatrixR4.h"

static MatrixR4* matrixRefR4 = NULL;

MatrixR4::MatrixR4(BLEServiceRunner& ble)
: _current({0xB194a444, 0x44042081, 0x100a0841})
, _displayChar(ble.characteristic("07020000", &_current, updateDisplay))
{
  matrixRefR4 = this;
}

void MatrixR4::begin()
{
  _matrix.begin();
  _matrix.loadFrame(_current.data());
}

void MatrixR4::updateDisplay(BLEDevice device, BLECharacteristic characteristic)
{
  std::array<uint32_t, 3> value;
  characteristic.readValue(value.data(), sizeof(value));
  matrixRefR4->set(value);
}

void MatrixR4::set(const std::array<uint32_t, 3>& data)
{
  if (data != _current)
  {
    _current = data;
    _matrix.loadFrame(_current.data());
  }
}
