import controlP5.*;

ControlP5 cp5;
int cols = 20;
int rows = 3;
float alternanceProb = 0.5;
boolean[][] alternatePattern;

void setup() {
  size(800, 400);
  
  cp5 = new ControlP5(this);
  cp5.addSlider("cols").setPosition(10, 10).setRange(1, 50).setValue(20);
  cp5.addSlider("rows").setPosition(10, 30).setRange(1, 30).setValue(3);
  cp5.addSlider("alternanceProb").setPosition(10, 50).setRange(0, 1).setValue(0.5);
  
  createPattern();
}

void createPattern() {
  alternatePattern = new boolean[cols][rows];
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      alternatePattern[i][j] = random(1) < alternanceProb;
    }
  }
}

void draw() {
  background(200);
  
  float cellWidth = width / cols;
  float cellHeight = height / rows;
  
  if (cellWidth < 10 || cellHeight < 10) return;
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (alternatePattern[i][j]) {
        fill((i + j) % 2 == 0 ? 0 : 255);
      } else {
        fill(0);
      }
      rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
    }
  }
}

void alternanceProb(float value) {
  alternanceProb = value;
  createPattern();
}

void cols(int value) {
  cols = value;
  createPattern();
}

void rows(int value) {
  rows = value;
  createPattern();
}
