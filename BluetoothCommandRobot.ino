#include <Arduino.h>
#include <SoftwareSerial.h>

// --- Bluetooth (HC-05 / HC-06) ---
const uint8_t BT_RX = 10; // Arduino RX  <- BT TX
const uint8_t BT_TX = 9;  // Arduino TX  -> BT RX
SoftwareSerial BT(BT_RX, BT_TX);

// --- Mode ---
enum Mode { MODE_MOVE, MODE_STOP };
Mode mode = MODE_MOVE;

// ---------- Sensor pins ----------
const uint8_t PIN_SENSE_CENTER = 12;
const uint8_t PIN_SENSE_LEFT   = 13;
const uint8_t PIN_SENSE_RIGHT  = 11;

// ---------- Motor pins ----------
const uint8_t PIN_MOTOR_L_A = 2;
const uint8_t PIN_MOTOR_L_B = 3;
const uint8_t PIN_MOTOR_R_A = 4;
const uint8_t PIN_MOTOR_R_B = 5;

// ---------- Built-in LED ----------
const uint8_t PIN_LED = LED_BUILTIN;

// ---------- Last seen ----------
enum LastSeen { SEEN_LEFT, SEEN_CENTER, SEEN_RIGHT };
LastSeen lastSeen = SEEN_CENTER;

// ---------- Motor helpers ----------
inline void driveLeft(bool a, bool b) {
  digitalWrite(PIN_MOTOR_L_A, a ? HIGH : LOW);
  digitalWrite(PIN_MOTOR_L_B, b ? HIGH : LOW);
}
inline void driveRight(bool a, bool b) {
  digitalWrite(PIN_MOTOR_R_A, a ? HIGH : LOW);
  digitalWrite(PIN_MOTOR_R_B, b ? HIGH : LOW);
}
inline void stopAll() { driveLeft(false, false); driveRight(false, false); }
inline void forward() { driveLeft(false, true);  driveRight(false, true); }
inline void sharpLeft() { driveLeft(false, true); driveRight(true, false); }
inline void sharpRight(){ driveLeft(true, false); driveRight(false, true); }
inline void pivotLeftSoft() { driveLeft(false, true); driveRight(false, false); }
inline void pivotRightSoft(){ driveLeft(false, false); driveRight(false, true); }

// ---------- Bluetooth read ----------
void readBT() {
  if (!BT.available()) return;

  String cmd = BT.readString();
  cmd.trim();
  cmd.toLowerCase();
  if (cmd.length() == 0) return;

  if (cmd == "Move") {
    mode = MODE_MOVE;
    digitalWrite(PIN_LED, LOW);
    BT.println("OK MOVE");
    Serial.println("[BT] MOVE");
  }
  else if (cmd == "Stop") {
    mode = MODE_STOP;
    stopAll();
    digitalWrite(PIN_LED, LOW);
    BT.println("OK STOP");
    Serial.println("[BT] STOP");
  }
  else if (cmd == "Test") {
    digitalWrite(PIN_LED, HIGH);   //Built-in LED ON
    BT.println("OK TEST");
    Serial.println("[BT] TEST -> LED ON");
  }
  else {
    BT.println("ERR");
    Serial.print("[BT] Unknown: ");
    Serial.println(cmd);
  }
}

void setup() {
  Serial.begin(9600);
  BT.begin(9600);

  pinMode(PIN_SENSE_CENTER, INPUT);
  pinMode(PIN_SENSE_LEFT,   INPUT);
  pinMode(PIN_SENSE_RIGHT,  INPUT);

  pinMode(PIN_MOTOR_L_A, OUTPUT);
  pinMode(PIN_MOTOR_L_B, OUTPUT);
  pinMode(PIN_MOTOR_R_A, OUTPUT);
  pinMode(PIN_MOTOR_R_B, OUTPUT);

  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_LED, LOW);

  stopAll();
  Serial.println("READY: BT -> move / stop / test");
}

void loop() {
  // 1) Bluetooth dinle
  readBT();

  // 2) STOP modunda hareket yok
  if (mode == MODE_STOP) {
    stopAll();
    delay(10);
    return;
  }

  // ---------- Line follow ----------
  // Eğer sensörlerin çizgide LOW veriyorsa ==HIGH -> ==LOW yap
  const bool left   = (digitalRead(PIN_SENSE_LEFT)   == HIGH);
  const bool center = (digitalRead(PIN_SENSE_CENTER) == HIGH);
  const bool right  = (digitalRead(PIN_SENSE_RIGHT)  == HIGH);

  Serial.print("L:"); Serial.print(left);
  Serial.print(" M:"); Serial.print(center);
  Serial.print(" R:"); Serial.print(right);
  Serial.print(" | ");

  // SMART lastSeen (kenarlar öncelikli)
  if (right)       lastSeen = SEEN_RIGHT;
  else if (left)   lastSeen = SEEN_LEFT;
  else if (center) lastSeen = SEEN_CENTER;

  // Kavşak
  if (left && center && right) {
    Serial.println("JUNCTION -> FORWARD");
    forward();
    delay(20);
    return;
  }

  // Çizgi kayıp → SADECE yumuşak arama
  if (!left && !center && !right) {
    if (lastSeen == SEEN_LEFT) {
      Serial.println("LOST -> SEARCH LEFT (SOFT)");
      pivotLeftSoft();
    } else {
      Serial.println("LOST -> SEARCH RIGHT (SOFT)");
      pivotRightSoft();
    }
    delay(5);
    return;
  }

  // Normal sürüş
  if (center) {
    if (!left && !right) {
      Serial.println("FORWARD");
      forward();
    } else if (left && !right) {
      Serial.println("SHARP_LEFT");
      sharpLeft();
    } else if (!left && right) {
      Serial.println("SHARP_RIGHT");
      sharpRight();
    } else {
      forward();
    }
  } else {
    if (left && !right) {
      Serial.println("LEFT (SOFT)");
      pivotLeftSoft();
    } else if (!left && right) {
      Serial.println("RIGHT (SOFT)");
      pivotRightSoft();
    } else {
      stopAll();
      Serial.println("NEUTRAL");
    }
  }

  delay(5);
}
