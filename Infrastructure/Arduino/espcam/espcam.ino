#include "env.h"
#include "Camera.h"
#include "CamServer.h"
#include "Flash.h"
#include "ESP32Config.h"

#include "shared/MyTime.cpp"
#include "shared/MyWifi.cpp"

#include <SD_MMC.h>

Camera _camera;
MyWifi _wifi;
CamServer _server;

bool begin() {
  Serial.begin(115200);
  while (!Serial);
  Serial.println();

  Serial.print("SD Card: ");
  if (SD_MMC.begin()) {
    Serial.println("success");
  }
  else {
    Serial.println("failed");
    return false;
  }

  Serial.print("Configuration: ");
  ESP32Config config("server", &SD_MMC);
  if (config.begin()) {
    Serial.println("success");
  }
  else {
    Serial.println("failed");
    return false;
  }

  Serial.print("Camera: ");
  if (_camera.begin(config)) {
    Serial.println("success");
  }
  else {
    Serial.println("failed");
    return false;
  }

  if (_wifi.begin(
      config.getString("ssid").c_str(), 
      config.getString("password").c_str())) {
  }
  else {
    return false;
  }

  Serial.print("Time: ");
  struct tm time;
  if (MyTime::configureTime(
      (MyTime::TimeZone)config.getInt("timezone", MyTime::TimeZone::CST),
      config.getBool("dlst", true), 
      &time)) {
    char buffer[27];
    MyTime::timestamp(buffer, &time);
    Serial.println(buffer);
  }
  else {
    Serial.println("failed");
    return false;
  }

  Serial.print("HTTP Server: ");
  if (_server.begin(
      config.getString("name", "Christof").c_str(), 
      config.getString("service", "espcam").c_str())) {
    Serial.printf("%s\n", _server.url().c_str());
  }
  else {
    return false;
  }

  return true;
}

void setup() {
  if (begin()) {
    Flash::setIntensity(255);
    delay(250);
    Flash::setIntensity(0);
  }
  else {
    ESP.restart();
  }
}

void loop() {
  // Everything is done in another task by the web server
  delay(10000);
}
