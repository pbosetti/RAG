#include <OneWire.h>
#include <DallasTemperature.h>

#define VERSION      "0.1"
#define PROMPT       Serial.println(">")
#define LOOP_DELAY   100
#define ANALOG_PINS  16
#define DIGITAL_PINS 21
#define BAUD         115200

// Data wire is plugged into pin 2 on the Arduino
#define ONE_WIRE_BUS 2

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);
uint8_t number_of_sensors;

void printAddress(DeviceAddress deviceAddress)
{
  for (uint8_t i = 0; i < 8; i++) {
    if (deviceAddress[i] < 16) Serial.print("0");
    Serial.print(deviceAddress[i], HEX);
  }
}

// (Re)Scan for OneWire devices
uint8_t scan_devices(uint8_t d)
{
  delay(d);
  sensors.begin();
  uint8_t n = sensors.getDeviceCount();
  return n;  
}

void setup(void)
{
  // start serial port
  Serial.begin(BAUD);
  while (Serial.available() == 0) {
    delay(10);
  }
  Serial.print("Temperature and current monitor ");
  Serial.println(VERSION);
  for (int i = 0; i < DIGITAL_PINS; i++) {
    pinMode(i, INPUT);
  }


  // Start up the library
  Serial.print("Locating devices...");
  do {
    number_of_sensors = scan_devices(500);
  } 
  while (number_of_sensors < 1);
  Serial.print("Found ");
  Serial.print(number_of_sensors, DEC);
  Serial.println(" devices.");
  DeviceAddress address;
  for (int i = 0; i < number_of_sensors; i++) {
    Serial.print("Sensor ");
    Serial.print(i, DEC);
    Serial.print(" address ");
    sensors.getAddress(address, i);
    printAddress(address);
    Serial.println();
  }

  // report parasite power status
  Serial.print("Parasite power is: "); 
  if (sensors.isParasitePowerMode()) 
    Serial.println("ON");
  else 
    Serial.println("OFF");
  PROMPT;
}


void loop(void)
{ 
  static uint8_t v = 0;
  DeviceAddress address;
  char ch;
  if (Serial.available()) {
    ch = Serial.read();
    // Serial command parsing:
    switch(ch) {
    case '0'...'9': // Accumulates values
      v = v * 10 + ch - '0';
      break;

    case 's':
      number_of_sensors = scan_devices(500);
      Serial.println("---");
      for (int i = 0; i < number_of_sensors; i++) {
        Serial.print("- ");
        sensors.getAddress(address, i);
        printAddress(address);
        Serial.println();
      }
      PROMPT;
      break;

    case 'a':
      if (v > 0 && v <= ANALOG_PINS) {
        Serial.println(analogRead(v-1));
      }
      else {
        Serial.println("---");
        for (int i = 0; i < ANALOG_PINS; i++) {
          Serial.print("- ");
          Serial.println(analogRead(i));
        }
      }
      v = 0;
      PROMPT;
      break;

    case 'd':
      if (v > 0 && v <= DIGITAL_PINS) {
        Serial.println(analogRead(v-1));
      }
      else {
        Serial.println("---");
        for (int i = 0; i < DIGITAL_PINS; i++) {
          Serial.print("- ");
          Serial.println(digitalRead(i));
        }
      }
      v = 0;
      PROMPT;
      break;

    case 't':
      sensors.requestTemperatures(); // Send the command to get temperatures
      if (v > 0 && v <= number_of_sensors) {
        Serial.println(sensors.getTempCByIndex(v-1));
      }
      else {
        Serial.println("---");
        for (int i = 0; i < number_of_sensors; i++) {
          sensors.getAddress(address, i);
          Serial.print("- ");
          Serial.print(":address: ");
          printAddress(address);
          Serial.println();
          Serial.print("  :temp: ");      
          Serial.println(sensors.getTempCByIndex(i));
        }
      }
      v = 0;
      PROMPT;
      break;
    }
  }
  else {
    delay(LOOP_DELAY);
  }
}
















