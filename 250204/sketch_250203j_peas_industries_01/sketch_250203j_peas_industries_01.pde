import controlP5.*;

ControlP5 cp5;
int cols = 20;
int rows = 3;

void setup() {
 size(800, 400);
 
 cp5 = new ControlP5(this);
 
 cp5.addSlider("cols")
    .setPosition(10, 10)
    .setRange(1, 50)
    .setValue(20);
    
 cp5.addSlider("rows")
    .setPosition(10, 30)
    .setRange(1, 30)
    .setValue(3);
}

void draw() {
 background(200);
 
 float cellWidth = width / cols;
 float cellHeight = height / rows;
 
 // Skip if cells too small
 if (cellWidth < 10 || cellHeight < 10) return;
 
 for (int i = 0; i < cols; i++) {
   for (int j = 0; j < rows; j++) {
     if ((i + j) % 2 == 0) {
       fill(0);
     } else {
       fill(255);
     }
     rect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
   }
 }
}
