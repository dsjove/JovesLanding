namespace Flash
{

void setup(int pin);

bool hasFlash();

int getBrightness();

void setBrightness(int val);

void enable(bool en, bool updateStreaming);

}