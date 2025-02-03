import controlP5.*;

ControlP5 cp5;
int cols = 20;
int rows = 3;
float probAlternance = 0.33;
float probBlanc = 0.33;
int[][] cellStates; // 0=alternance, 1=noir, 2=blanc

void setup() {
 size(800, 400);
 
 cp5 = new ControlP5(this);
 cp5.addSlider("cols").setPosition(10, 10).setRange(1, 50).setValue(20);
 cp5.addSlider("rows").setPosition(10, 30).setRange(1, 30).setValue(3);
 cp5.addSlider("probAlternance").setPosition(10, 50).setRange(0, 1).setValue(0.33);
 cp5.addSlider("probBlanc").setPosition(10, 70).setRange(0, 1).setValue(0.33);
 
 createPattern();
}

void createPattern() {
 cellStates = new int[cols][rows];
 for (int i = 0; i < cols; i++) {
   for (int j = 0; j < rows; j++) {
     float r = random(1);
     if (r < probAlternance) cellStates[i][j] = 0;
     else if (r < probAlternance + probBlanc) cellStates[i][j] = 2;
     else cellStates[i][j] = 1;
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
     switch(cellStates[i][j]) {
       case 0: // alternance
         fill((i + j) % 2 == 0 ? 0 : 255);
         break;
       case 1: // noir
         fill(0);
         break;
       case 2: // blanc
         fill(255);
         break;
     }
     rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
   }
 }
}

void probAlternance(float value) {
 probAlternance = value;
 createPattern();
}

void probBlanc(float value) {
 probBlanc = value;
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
