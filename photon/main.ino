#include "neopixel/neopixel.h"

#define PIN 6

// ------------
// JOLTEON
// ------------
#define RED_LED_PIN D0
#define YELLOW_LED_PIN D1
#define PIXEL_PIN 6
#define PIXEL_COUNT 240
#define PIXEL_TYPE WS2812B

Adafruit_NeoPixel strip = Adafruit_NeoPixel(PIXEL_COUNT, PIXEL_PIN, PIXEL_TYPE);

void setup() {
    // Initialize PINS
    pinMode(RED_LED_PIN, OUTPUT);
    pinMode(YELLOW_LED_PIN, OUTPUT);
    strip.begin();

    // Initialize Photon endpoints
    Particle.function("yellowLED",ledToggle);
    Particle.function("LEDstatus",ledStatus);
    Particle.function("ls",lsON);
    Particle.function("ls_rgb",lsRGB);

    // Shut down all power to output pins
    digitalWrite(RED_LED_PIN, LOW);
    digitalWrite(YELLOW_LED_PIN, LOW);
    strip.show();
}

void loop() {
    digitalWrite(RED_LED_PIN, HIGH);
    rainbow(20);
}

int ledStatus(String command) {
    switch (digitalRead(YELLOW_LED_PIN)) {
    case HIGH:
        return 1;
        break;
    case LOW:
        return 0;
        break;
    default:
        return -1;
        break;
  }

}

int ledToggle(String command) {

    if (digitalRead(YELLOW_LED_PIN) == HIGH) {
        digitalWrite(YELLOW_LED_PIN,LOW);
        return 0;
    } else if (digitalRead(YELLOW_LED_PIN) == LOW) {
        digitalWrite(YELLOW_LED_PIN,HIGH);
        return 1;
    } else {
        return -1;
    }
}

int lsON(String command) {
    if (command == "true"){
        strip.setBrightness(200);
        strip.show();
        return 1;
    } else if (command == "false") {
        strip.setBrightness(0);
        strip.show();
        return 0;
    } else {
        return -1;
    }
}

int lsRGB(String command) {
    return 1;
}

void rainbow(uint8_t wait) {
    uint16_t i, j;

    for(j=0; j<256; j++) {
        for(i=0; i<strip.numPixels(); i++) {
            strip.setPixelColor(i, Wheel((i+j) & 255));
        }
        strip.show();
        delay(wait);
    }
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
    WheelPos = 255 - WheelPos;
    if(WheelPos < 85) {
        return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
    }
    if(WheelPos < 170) {
        WheelPos -= 85;
        return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
    }
    WheelPos -= 170;
    return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
}
