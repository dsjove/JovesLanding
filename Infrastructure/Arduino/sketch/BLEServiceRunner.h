#include "BLEServiceID.h"
#include <TaskScheduler.h>

class BLEServiceRunner {
public:
  BLEServiceRunner(const char serviceID[28])
  : _id(serviceID)
  , _bleService(_id)
  , _bluetoothTask(100, TASK_FOREVER, &bluetooth_task)
  {
  }

  template <typename T>
  BLECharacteristic characteristic(const char id[8], T* value, BLECharacteristicEventHandler eventHandler = NULL)
  {
    BLECharacteristic c = _id.characteristic(id, value, eventHandler);
    _bleService.addCharacteristic(c);
    return c;
  }

  void begin(Scheduler& scheduler) {
    if (!BLE.begin()) 
    {
      Serial.println("Starting Bluetooth® Low Energy module failed!");
      while (1);
    }
    BLE.setLocalName(BLELocalName);
    BLE.setEventHandler(BLEConnected, bluetooth_connected);
    BLE.setEventHandler(BLEDisconnected, bluetooth_disconnected);
    
    BLE.setAdvertisedService(_bleService);
    BLE.addService(_bleService);

    int r = BLE.advertise();
    if (r == 1) 
    {
      Serial.println("Bluetooth® device active, waiting for connections...");
      Serial.println(BLELocalName);
      Serial.println((const char *)_id);
    }
    else 
    {
      Serial.println("Bluetooth® activation failed!");
      while (1);
    }
    scheduler.addTask(_bluetoothTask);
    _bluetoothTask.enable();
  }

private:
  BLEServiceID _id;
  BLEService _bleService;
  Task _bluetoothTask;

  static void bluetooth_task() 
  {
    BLE.poll();
  }

  static void bluetooth_connected(BLEDevice device) 
  {
    Serial.println();
    Serial.print("BT Connected: ");
    Serial.println(device.address());
  }

  static void bluetooth_disconnected(BLEDevice device) 
  {
    Serial.println();
    Serial.print("BT Disconnected: ");
    Serial.println(device.address());
  }
};
