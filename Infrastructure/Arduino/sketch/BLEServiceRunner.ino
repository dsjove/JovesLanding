#include "BLEServiceRunner.h"
#include <TaskScheduler.h>

bool generatid(const char name[13], const char serviceID[28], char _id[37])
{
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
        *output = '0';
        *(output + 1) = '0';
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

BLEServiceRunner::BLEServiceRunner(const char name[30], const char serviceID[28])
: _b(generatid(name, serviceID, _id))
, _bleService(_id)
, _bluetoothTask(100, TASK_FOREVER, &bluetooth_task)
{
    ::strncpy(_name, name, sizeof(_name));
}

void BLEServiceRunner::begin(Scheduler& scheduler)
{
  if (!BLE.begin()) 
  {
    Serial.println("Starting Bluetooth® Low Energy module failed!");
    while (1);
  }
  BLE.setLocalName(_name);
  BLE.setEventHandler(BLEConnected, bluetooth_connected);
  BLE.setEventHandler(BLEDisconnected, bluetooth_disconnected);
  
  BLE.setAdvertisedService(_bleService);
  BLE.addService(_bleService);

  int r = BLE.advertise();
  if (r == 1) 
  {
    Serial.println("Bluetooth® device active, waiting for connections...");
    Serial.println(_name);
    Serial.println(_id);
  }
  else 
  {
    Serial.println("Bluetooth® activation failed!");
    while (1);
  }
  scheduler.addTask(_bluetoothTask);
  _bluetoothTask.enable();
}

void BLEServiceRunner::bluetooth_task() 
{
  BLE.poll();
}

BLECharacteristic BLEServiceRunner::characteristic(const char id[9], size_t size, void* value, BLECharacteristicEventHandler eventHandler)
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
  BLECharacteristic characteristic(fullID, permissions, size);
  if (value) 
  {
    characteristic.writeValue(value, size);
  }
  if (eventHandler)
  {
    characteristic.setEventHandler(BLEWritten, eventHandler);
  }
  _bleService.addCharacteristic(characteristic);
  return characteristic;
}

void BLEServiceRunner::bluetooth_connected(BLEDevice device) 
{
  Serial.println();
  Serial.print("BT Connected: ");
  Serial.println(device.address());
}

void BLEServiceRunner::bluetooth_disconnected(BLEDevice device) 
{
  Serial.println();
  Serial.print("BT Disconnected: ");
  Serial.println(device.address());
}