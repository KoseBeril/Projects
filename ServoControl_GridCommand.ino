#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
void penDown(int offset = 0, bool extreme = false);
void penUp();
void goIdle();
void handleCmd(String cmd);
void moveToGrid(int base, int shoulder);
// ================= SERVO AYARLARI =================
// Min-max değerleri servoya göre ayarla 
#define SERVOMIN  150   // 0°
#define SERVOMAX  600   // 180°

int servoBaseCh     = 4; // PCA9685 CH0
int servoShoulderCh = 0; // PCA9685 CH1
int servoElbowCh    = 7; // PCA9685 CH2"""

// ================ PINLER VE POZLAR =================
#define BASE_HOME     90
#define SHOULDER_HOME 90
#define SHOULDER_IDLE 90
#define BASE_IDLE     150

#define ELBOW_UP     80 // yüksüz servo için ideal açı
#define ELBOW_DOWN   95

#define X_SIZE        5
#define STEPS         100
#define SERVO_DELAY   2

#define BASE_00  115 //1 -- grid numbers
#define SHOULDER_00  40

#define BASE_01  85  //2
#define SHOULDER_01  40

#define BASE_02  65  //3
#define SHOULDER_02  45

#define BASE_10 107  //4
#define SHOULDER_10  68

#define BASE_11  87  //5
#define SHOULDER_11  67

#define BASE_12  70  //6
#define SHOULDER_12  72

#define BASE_20  103  //7
#define SHOULDER_20 102

#define BASE_21  89 //8
#define SHOULDER_21  100

#define BASE_22  77 //9
#define SHOULDER_22  105

// Elbow offset tablosu (row, col)

int elbowOffset[3][3] = {
  { 20, 20, 20 },
  { 5, 5, 5 },
  { 3, 3, 3 }
};

// Grid angles
struct GridPos {
  int base;
  int shoulder;
};

GridPos grid[3][3] = {
  { {BASE_00, SHOULDER_00}, {BASE_01, SHOULDER_01}, {BASE_02, SHOULDER_02} },
  { {BASE_10, SHOULDER_10}, {BASE_11, SHOULDER_11}, {BASE_12, SHOULDER_12} },
  { {BASE_20, SHOULDER_20}, {BASE_21, SHOULDER_21}, {BASE_22, SHOULDER_22} }
};

// =====================================================

void setup() {
  // komut okuma ve servo driver ayarları
  Serial.begin(115200);
  Wire.begin();
  pwm.begin();
  pwm.setPWMFreq(50);

  goIdle();
  //test();
}

void loop() {

  // =====================================================
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');
    cmd.trim();
    handleCmd(cmd);
  }

}

// ============= SERVO YAZMA =======
int angleToPWM(int angle) {
  return map(angle, 0, 180, SERVOMIN, SERVOMAX);
}

void writeServo(int ch, int angle) {
  pwm.setPWM(ch, 0, angleToPWM(angle));
}


// ================ ANA FONKSİYON =======================

void drawX(int cx, int cy, int size, int offset) {

  int TLx = cx - size;
  int TLy = cy + size;

  int TRx = cx + size;
  int TRy = cy + size;

  int BLx = cx - size;
  int BLy = cy - size;

  int BRx = cx + size;
  int BRy = cy - size;

  penUp();
  moveTo(BLx-2, BLy);
  delay(400);

  penDown(offset);
  delay(400);
  drawLineSmooth(BLx, BLy, TRx, TRy+5);

  penUp();
  delay(1200);

  moveTo(TLx-2, TLy+2);
  delay(1000);

  penDown(offset);
  delay(300);
  drawLineSmooth(TLx, TLy, BRx, BRy-5);
  delay(500);

  penUp();
  delay(300);
}

// ================ SMOOTH LINE ========================

void drawLineSmooth(int x0, int y0, int x1, int y1) {

  int prevX = x0;
  int prevY = y0;

  for (int i = 0; i <= STEPS; i++) {

    float t = (float)i / STEPS;
    float easeT = easeIn(t);

    int bx = round(x0 + (x1 - x0) * easeT);
    int sy = round(y0 + (y1 - y0) * easeT);

    smoothMove(servoBaseCh, prevX, bx);
    smoothMove(servoShoulderCh, prevY, sy);

    prevX = bx;
    prevY = sy;
  }
}

// ================ SMOOTH MOVE ========================

void smoothMove(int ch, int from, int to) {
  if (from < to) {
    for (int p = from; p <= to; p++) {
      writeServo(ch, p);
      delay(SERVO_DELAY);
    }
  } else {
    for (int p = from; p >= to; p--) {
      writeServo(ch, p);
      delay(SERVO_DELAY);
    }
  }
}


// ====================== EASE =========================

float easeIn(float t)   { return t * t; }
float easeOut(float t)  { return t * (2 - t); }


// ===================== PEN ===========================

void penDown(int offset = 0, bool extreme = false) {
  int target = ELBOW_DOWN + offset;
  if (extreme) {
    smoothMove(servoElbowCh, ELBOW_DOWN, ELBOW_UP);
    return;
  }
  smoothMove(servoElbowCh, ELBOW_UP, target);
}


void penUp() {
  smoothMove(servoElbowCh, ELBOW_DOWN, ELBOW_UP);
}


// ===================== HOME ==========================

/*void goHome() {
  writeServo(servoBaseCh, BASE_HOME);
  writeServo(servoShoulderCh, SHOULDER_HOME);
  writeServo(servoElbowCh, ELBOW_UP);
  delay(600);
}*/

void moveTo(int x, int y) {
  smoothMove(servoBaseCh, x, x);
  smoothMove(servoShoulderCh, y, y);
  delay(150);
}

void goIdle() {
  //penUp();
  writeServo(servoBaseCh, BASE_IDLE);
  writeServo(servoShoulderCh, SHOULDER_IDLE);
  writeServo(servoElbowCh, ELBOW_UP);
  delay(500);
}

void handleCmd(String cmd) {
  cmd.trim();
  int gridNum = cmd.toInt();
  if (gridNum < 1 || gridNum > 9) return;

  int g = gridNum - 1;
  int row = g / 3;
  int col = g % 3;

  int baseTarget = grid[row][col].base;
  int shoulderTarget = grid[row][col].shoulder;

  // 1- Gride git
  //moveToGrid(BASE_HOME, SHOULDER_HOME);
  //delay(1000);
  moveToGrid(baseTarget, shoulderTarget);

  // 2- Bekle
  delay(1500);

  // 3- Çiz
  drawX(baseTarget, shoulderTarget, X_SIZE, elbowOffset[row][col]);

  // 4- Idle
  moveToGrid(BASE_HOME, SHOULDER_HOME);
  delay(1000);
  goIdle();
}


void moveToGrid(int base, int shoulder) {
  writeServo(servoBaseCh, base);
  writeServo(servoShoulderCh, shoulder);
  delay(400);
}

void test(){
  for(int i = 0; i<3; i++){
    for (int j = 0; j < 3; j++){
      moveToGrid(grid[i][j].base, grid[i][j].shoulder);
      penDown();
      delay(300);
      penUp();
      delay(600);
      goIdle();
      delay(600);
    }
  }
}





