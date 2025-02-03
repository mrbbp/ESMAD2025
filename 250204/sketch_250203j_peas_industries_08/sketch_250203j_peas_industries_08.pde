import controlP5.*;

ControlP5 cp5;
int cols = 20;
int rows = 3;
float regularite = 0.5;
float regularite2 = 0.8;
boolean[][] cells;

void setup() {
  size(800, 400);
  
  cp5 = new ControlP5(this);
  cp5.addSlider("cols").setPosition(10, 10).setRange(1, 50).setValue(20);
  cp5.addSlider("rows").setPosition(10, 30).setRange(1, 3).setValue(3); // Fixé à 3 lignes
  cp5.addSlider("regularite").setPosition(10, 50).setRange(0, 1).setValue(0.5).setLabel("Régularité L1");
  cp5.addSlider("regularite2").setPosition(10, 70).setRange(0, 1).setValue(0.8).setLabel("Régularité L2");
  
  noStroke();
  createPattern();
}

void createPattern() {
  cells = new boolean[cols][3]; // Fixé à 3 lignes
  
  // Première ligne
  for(int i = 0; i < cols; i++) {
    boolean lastColor = i > 0 ? cells[i-1][0] : false;
    if(random(1) < regularite) lastColor = !lastColor;
    cells[i][0] = lastColor;
  }

  // Deuxième ligne
  for(int i = 0; i < cols; i++) {
    cells[i][1] = !cells[i][0];
    if(random(1) > regularite2) cells[i][1] = !cells[i][1];
  }
  
  // Troisième ligne
  for(int i = 0; i < cols; i++) {
    boolean lastColor = i > 0 ? cells[i-1][2] : false;
    if(random(1) < regularite) lastColor = !lastColor;
    cells[i][2] = lastColor;
  }
}

void draw() {
  background(200);
  float cellWidth = width / cols;
  float cellHeight = height / 3;
  
  if (cellWidth < 10 || cellHeight < 10) return;
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < 3; j++) {
      fill(cells[i][j] ? 255 : 0);
      rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
    }
  }
}

void regularite(float value) {
  regularite = value;
  createPattern();
}

void regularite2(float value) {
  regularite2 = value;
  createPattern();
}

void cols(int value) {
  cols = value;
  createPattern();
}
