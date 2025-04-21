#include "BLEServiceRunner.h"
#include <TaskScheduler.h>

BLEServiceRunner::BLEServiceRunner(const char name[30], const char serviceID[28])
: _id(name, serviceID)
, _bleService(_id)
, _bluetoothTask(100, TASK_FOREVER, &bluetooth_task)
{
}

void BLEServiceRunner::begin(Scheduler& scheduler) {
  if (!BLE.begin()) 
  {
    Serial.println("Starting Bluetooth® Low Energy module failed!");
    while (1);
  }
  BLE.setLocalName(_id.name());
  BLE.setEventHandler(BLEConnected, bluetooth_connected);
  BLE.setEventHandler(BLEDisconnected, bluetooth_disconnected);
  
  BLE.setAdvertisedService(_bleService);
  BLE.addService(_bleService);

  int r = BLE.advertise();
  if (r == 1) 
  {
    Serial.println("Bluetooth® device active, waiting for connections...");
    Serial.println(_id.name());
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

void BLEServiceRunner::bluetooth_task() 
{
  BLE.poll();
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