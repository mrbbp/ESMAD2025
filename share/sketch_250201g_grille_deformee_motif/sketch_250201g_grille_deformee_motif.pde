import de.looksgood.ani.*;
import controlP5.*;

PVector[][] points;
float noiseAmount = 20;
String pattern = "100101100";
ControlP5 cp5;
int cols = 10;
int rows = 10;

void setup() {
  size(1000, 800);
  Ani.init(this);
  setupControls();
  initializeGrid();
  noStroke();
}

void setupControls() {
  cp5 = new ControlP5(this);
  cp5.addSlider("cols")
     .setPosition(820, 50)
     .setRange(2, 20)
     .setValue(10);
     
  cp5.addSlider("rows")
     .setPosition(820, 80)
     .setRange(2, 20)
     .setValue(10);
     
  cp5.addSlider("noiseAmount")
     .setPosition(820, 110)
     .setRange(0, 50)
     .setValue(20);
}

void initializeGrid() {
  points = new PVector[cols + 1][rows + 1];
  initializePoints();
}

void initializePoints() {
  float cellWidth = 800.0/cols;
  float cellHeight = 800.0/rows;
  
  for (int y = 0; y <= rows; y++) {
    for (int x = 0; x <= cols; x++) {
      if (points[x][y] == null) {
        points[x][y] = new PVector(x * cellWidth, y * cellHeight);
      }
      
      float targetX = x * cellWidth;
      float targetY = y * cellHeight;
      
      if (x > 0 && x < cols && y > 0 && y < rows) {
        targetX += random(-noiseAmount, noiseAmount);
        targetY += random(-noiseAmount, noiseAmount);
      }
      else if (x == 0 && y > 0 && y < rows) {
        targetY += random(-noiseAmount, noiseAmount);
      }
      else if (x == cols && y > 0 && y < rows) {
        targetY += random(-noiseAmount, noiseAmount);
      }
      else if (y == 0 && x > 0 && x < cols) {
        targetX += random(-noiseAmount, noiseAmount);
      }
      else if (y == rows && x > 0 && x < cols) {
        targetX += random(-noiseAmount, noiseAmount);
      }
      
      Ani.to(points[x][y], 1.5, "x", targetX, Ani.ELASTIC_OUT);
      Ani.to(points[x][y], 1.5, "y", targetY, Ani.ELASTIC_OUT);
    }
  }
}

void draw() {
  background(128);
  float cellWidth = 800.0/cols;
  float cellHeight = 800.0/rows;
  
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      int patternIndex = (y * cols + x) % pattern.length();
      if (pattern.charAt(patternIndex) == '1') {
        fill(0);
      } else {
        fill(255);
      }
      quad(points[x][y].x, points[x][y].y,
           points[x+1][y].x, points[x+1][y].y,
           points[x+1][y+1].x, points[x+1][y+1].y,
           points[x][y+1].x, points[x][y+1].y);
    }
  }
}

void controlEvent(ControlEvent event) {
  if(event.isController()) {
    if(event.getController().getName().equals("cols") || 
       event.getController().getName().equals("rows")) {
      initializeGrid();
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    initializePoints();
  }
}
