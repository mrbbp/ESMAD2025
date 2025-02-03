import controlP5.*;

ControlP5 cp5;
int cols = 20;
int rows = 3;
float regularite = 0.5;
boolean[][] cells;

void setup() {
 size(800, 400);
 
 cp5 = new ControlP5(this);
 cp5.addSlider("cols").setPosition(10, 10).setRange(1, 50).setValue(20);
 cp5.addSlider("rows").setPosition(10, 30).setRange(1, 30).setValue(3);
 cp5.addSlider("regularite").setPosition(10, 50).setRange(0, 1).setValue(0.5);
 
 noStroke();
 createPattern();
}

void createPattern() {
 cells = new boolean[cols][rows];
 
 // Première ligne (et lignes impaires)
 for(int i = 0; i < cols; i++) {
   boolean lastColor = i > 0 ? cells[i-1][0] : false;
   if(random(1) < regularite) lastColor = !lastColor;
   for(int j = 0; j < rows; j += 2) {
     cells[i][j] = lastColor;
   }
 }
 
 // Lignes paires (inverse avec léger aléatoire)
 for(int i = 0; i < cols; i++) {
   for(int j = 1; j < rows; j += 2) {
     cells[i][j] = !cells[i][j-1];
     if(random(1) > regularite * 1.5) cells[i][j] = !cells[i][j];
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
     fill(cells[i][j] ? 255 : 0);
     rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
   }
 }
}

void regularite(float value) {
 regularite = value;
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
