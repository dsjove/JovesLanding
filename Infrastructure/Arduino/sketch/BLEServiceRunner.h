#pragma once
#include <ArduinoBLE.h>
#include <TaskScheduler.h>

class BLEServiceRunner {
public:
  BLEServiceRunner(const char name[30], const char serviceID[28] = NULL);

  template <typename T>
  BLECharacteristic characteristic(const char id[9], const T* value, BLECharacteristicEventHandler eventHandler = NULL)
  {
    return characteristic(id, sizeof(T), value, eventHandler);
  }

  BLECharacteristic characteristic(const char id[9], size_t size, const void* value, BLECharacteristicEventHandler eventHandler);

  void begin(Scheduler& scheduler);

private:
  const bool _b;
  char _name[13];
  char _id[37];
  BLEService _bleService;
  Task _bluetoothTask;

  static void bluetooth_task();
  static void bluetooth_connected(BLEDevice device);
  static void bluetooth_disconnected(BLEDevice device);
};
