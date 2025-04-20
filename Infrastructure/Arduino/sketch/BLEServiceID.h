#include <ArduinoBLE.h>

class BLEServiceID
{
public:
  BLEServiceID(const char serviceID[28])
  {
    ::memset(_id, '0', 8);
    _id[8] = '-';
    ::memcpy(_id + 9, serviceID, 28);
  }

  operator const char* () const
  {
    return _id;
  }

  template <typename T>
  BLECharacteristic characteristic(const char id[8], T* value, BLECharacteristicEventHandler eventHandler = NULL) const 
  {
    char fullID[37];
    ::memcpy(fullID, id, 8);
    ::memcpy(fullID + 8, _id + 8, 29);

    uint16_t permissions = 0;
    if (value)
    {
      permissions |= BLERead;
      permissions |= BLENotify;
    }
    if (eventHandler)
    {
      permissions |= BLEWriteWithoutResponse;
    }
    BLECharacteristic characteristic(fullID, permissions, sizeof(T));
    if (value) 
    {
      characteristic.writeValue(value, sizeof(T));
    }
    if (eventHandler)
    {
      characteristic.setEventHandler(BLEWritten, eventHandler);
    }
    return characteristic;
  }
private:
  char _id[37];
};
