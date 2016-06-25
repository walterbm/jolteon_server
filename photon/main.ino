// ------------
// Blink RED and YELLO LEDs
// ------------


int redLED = D0;
int yellowLED = D1;

void setup() {

  pinMode(redLED, OUTPUT);
  pinMode(yellowLED, OUTPUT);

  Particle.function("yellowLED",ledToggle);

  digitalWrite(redLED, LOW);
  digitalWrite(yellowLED, LOW);

}


void loop() {

  digitalWrite(redLED, HIGH);

  delay(10000);

  digitalWrite(redLED, LOW);

  delay(10000);

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

