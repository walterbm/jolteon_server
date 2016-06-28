// ------------
// Blink a RED and YELLOW LEDs
// ------------


int redLED = D0;
int yellowLED = D1;

void setup() {

  pinMode(redLED, OUTPUT);
  pinMode(yellowLED, OUTPUT);

  Particle.function("yellowLED",ledToggle);
  Particle.function("LEDstatus",ledStatus);

  digitalWrite(redLED, LOW);
  digitalWrite(yellowLED, LOW);

}


void loop() {

  digitalWrite(redLED, HIGH);

  delay(10000);

  digitalWrite(redLED, LOW);

  delay(10000);

}

int ledStatus(String command) {
    switch (digitalRead(yellowLED)) {
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

    if (digitalRead(yellowLED) == HIGH) {
        digitalWrite(yellowLED,LOW);
        return 0;
    } else if (digitalRead(yellowLED) == LOW) {
        digitalWrite(yellowLED,HIGH);
        return 1;
    } else {
        return -1;
    }
}
