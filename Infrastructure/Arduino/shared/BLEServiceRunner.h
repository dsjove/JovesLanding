#pragma once
#include <string>
#include <ArduinoBLE.h>
#include <TaskScheduler.h>

class BLEServiceRunner
{
public:
  //serviceID must be in the format of "0000-0000-0000-000000000000" or empty to use first 12 bytes of name
  //The first 4 bytes (8 hexidecimal digits) are reserved.
  BLEServiceRunner(const std::string& name, const std::string& serviceID = "");

  template <typename T>
  BLECharacteristic characteristic(const std::string& id, const T* value, BLECharacteristicEventHandler eventHandler = NULL)
  {
    return characteristic(id, sizeof(T), value, eventHandler);
  }

  template <typename T, std::size_t N>
  BLECharacteristic characteristic(const std::string& id, const std::array<T, N>* value, BLECharacteristicEventHandler eventHandler = NULL)
  {
    return characteristic(id, sizeof(const std::array<T, N>), value && N > 0 ? value->data() : NULL, eventHandler);
  }

  //only first 8 bytes of id used
  BLECharacteristic characteristic(const std::string& id, size_t size, const void* value, BLECharacteristicEventHandler eventHandler);

  void begin(Scheduler& scheduler);

private:
  const std::string _name;
  const std::string _id;
  BLEService _bleService;
  Task _bluetoothTask;

  static void bluetooth_task();
  static void bluetooth_connected(BLEDevice device);
  static void bluetooth_disconnected(BLEDevice device);
};
