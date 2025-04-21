#pragma once
#include "BLEServiceID.h"
#include <TaskScheduler.h>

class BLEServiceRunner {
public:
  BLEServiceRunner(const char name[30], const char serviceID[28] = NULL);

  template <typename T>
  BLECharacteristic characteristic(uint8_t component, const char id[7], T* value, BLECharacteristicEventHandler eventHandler = NULL) 
  {
    BLECharacteristic c = _id.characteristic(component, id, value, eventHandler);
    _bleService.addCharacteristic(c);
    return c;
  }

  template <typename T>
  BLECharacteristic characteristic(const char id[9], T* value, BLECharacteristicEventHandler eventHandler = NULL)
  {
    BLECharacteristic c = _id.characteristic(id, value, eventHandler);
    _bleService.addCharacteristic(c);
    return c;
  }

  void begin(Scheduler& scheduler);

private:
  BLEServiceID _id;
  BLEService _bleService;
  Task _bluetoothTask;

  static void bluetooth_task();
  static void bluetooth_connected(BLEDevice device);
  static void bluetooth_disconnected(BLEDevice device);
};
