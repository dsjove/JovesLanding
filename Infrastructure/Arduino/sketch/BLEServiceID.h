#pragma once
#include <ArduinoBLE.h>

class BLEServiceID
{
public:
  BLEServiceID(const char name[13], const char serviceID[28] = NULL)
  {
    ::strncpy(_name, name, sizeof(_name));
    ::memset(_id, '0', 8);
    _id[8] = '-';

    if (serviceID != NULL) 
    {
      ::memcpy(_id + 9, serviceID, 28);
    }
    else
    {
      const char* input = name;
      char* output = _id + 9;
      _id[36] = 0;

      for (int i = 0; i < 12; i++)
      {
        if (!(*input))
        {
          *output = 'F';
          *(output + 1) = 'F';
          output += 2;
        }
        else
        {
          sprintf(output, "%02X", *input);
          output += 2;
          input++;
        }
        if (i == 1 || i == 3 || i == 5)
        {
          *output = '-';
          output++;
        }
      }
    }
  }

  operator const char* () const
  {
    return _id;
  }

  const char* name() const 
  {
    return _name;
  }

  template <typename T>
  BLECharacteristic characteristic(uint8_t component, const char id[7], T* value, BLECharacteristicEventHandler eventHandler = NULL) const 
  {
    char charID[9];
    snprintf(charID, sizeof(charID), "%02X%s", component, id);
    return characteristic(charID, value, eventHandler);
  }

  template <typename T>
  BLECharacteristic characteristic(const char id[9], T* value, BLECharacteristicEventHandler eventHandler = NULL) const 
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
  char _name[13];
  char _id[37];
};
