#include "Flash.h"
#include "esp32-hal-ledc.h"

namespace Flash
{
  static int thePin = -1;
  static int led_duty = 0;
  static bool isStreaming = false;

  void setup(int pin) {
    thePin = pin;
    const int freq = 5000;  // Frequency in Hz
    const int resolution = 8;  // 8-bit resolution (0-255)
    ledcAttach(thePin, freq, resolution);
  }

  bool hasFlash() {
    return thePin != -1;
  }

  int getBrightness() {
    return led_duty;
  }

  void setBrightness(int val) {
    led_duty = val;
    if (isStreaming) {
      Flash::enable(true, false);
    }
  }

  void enable(bool en, bool updateStreaming) {  // Turn LED On or Off
    if (updateStreaming) {
      isStreaming = en;
    }
    int duty = en ? led_duty : 0;
    if (en && isStreaming && (led_duty > 255)) {
      duty = 255;
    }
    ledcWrite(thePin, duty);
  }

}