import de.looksgood.ani.*;

final int COLS = 10;
final int ROWS = 10;
float[] rowHeights;
float[] oldHeights;
float transition = 0;

void setup() {
  size(800, 800);
  Ani.init(this);
  
  rowHeights = new float[ROWS];
  oldHeights = new float[ROWS];
  regenerateHeights();
}

void draw() {
  background(255);
  float cellWidth = width / (float)COLS;
  float y = 0;
  
  for (int row = 0; row < ROWS; row++) {
    float currentHeight = lerp(oldHeights[row], rowHeights[row], transition);
    
    for (int col = 0; col < COLS; col++) {
      float x = col * cellWidth;
      
      if ((row + col) % 2 == 0) {
        fill(0);
      } else {
        fill(255);
      }
      
      rect(x, y, cellWidth, currentHeight);
    }
    y += currentHeight;
  }
}

void regenerateHeights() {
  // Sauvegarder les anciennes hauteurs
  arrayCopy(rowHeights, oldHeights);
  
  float sum = 0;
  for (int row = 0; row < ROWS; row++) {
    rowHeights[row] = random(20, 100);
    sum += rowHeights[row];
  }
  
  float factor = height / sum;
  for (int row = 0; row < ROWS; row++) {
    rowHeights[row] *= factor;
  }
  
  // Réinitialiser et lancer l'animation
  transition = 0;
  Ani.to(this, 1.5, "transition", 1, Ani.ELASTIC_OUT);
}

void keyPressed() {
  if (key == ' ') {
    regenerateHeights();
  }
}
