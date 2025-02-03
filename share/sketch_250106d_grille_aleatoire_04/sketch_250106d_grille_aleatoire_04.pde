import de.looksgood.ani.*;

final int COLS = 10;
final int ROWS = 10;
float[] rowHeights;
float[] oldHeights;
float[] colWidths;
float[] oldWidths;
float transition = 0;
PImage img;
PGraphics inverted;

void setup() {
  size(800, 800, P2D);
  Ani.init(this);
  
  rowHeights = new float[ROWS];
  oldHeights = new float[ROWS];
  colWidths = new float[COLS];
  oldWidths = new float[COLS];
  
  img = loadImage("../medias/portrait.jpg");
  
  inverted = createGraphics(img.width, img.height, P2D);
  inverted.beginDraw();
  inverted.image(img, 0, 0);
  inverted.filter(INVERT);
  inverted.endDraw();
  
  textureMode(NORMAL);
  regenerateGrid();
}

void draw() {
  background(255);
  float x = 0;
  noStroke();
  
  for (int row = 0; row < ROWS; row++) {
    float currentHeight = lerp(oldHeights[row], rowHeights[row], transition);
    float v1 = row / (float)ROWS;
    float v2 = (row + 1) / (float)ROWS;
    
    x = 0; // Reset x position for each row
    for (int col = 0; col < COLS; col++) {
      float currentWidth = lerp(oldWidths[col], colWidths[col], transition);
      float u1 = col / (float)COLS;
      float u2 = (col + 1) / (float)COLS;
      
      beginShape(QUADS);
      if ((row + col) % 2 == 0) {
        texture(img);
      } else {
        texture(img);
        //texture(inverted);
      }
      vertex(x, row == 0 ? 0 : sumHeights(row - 1), u1, v1);
      vertex(x + currentWidth, row == 0 ? 0 : sumHeights(row - 1), u2, v1);
      vertex(x + currentWidth, sumHeights(row), u2, v2);
      vertex(x, sumHeights(row), u1, v2);
      endShape();
      
      x += currentWidth;
    }
  }
}

float sumHeights(int upToRow) {
  float sum = 0;
  for (int i = 0; i <= upToRow; i++) {
    sum += lerp(oldHeights[i], rowHeights[i], transition);
  }
  return sum;
}

void regenerateGrid() {
  // Sauvegarder les anciennes valeurs
  arrayCopy(rowHeights, oldHeights);
  arrayCopy(colWidths, oldWidths);
  
  // Générer et normaliser les hauteurs
  float sumHeight = 0;
  for (int row = 0; row < ROWS; row++) {
    rowHeights[row] = random(20, 100);
    sumHeight += rowHeights[row];
  }
  float factorHeight = height / sumHeight;
  for (int row = 0; row < ROWS; row++) {
    rowHeights[row] *= factorHeight;
  }
  
  // Générer et normaliser les largeurs
  float sumWidth = 0;
  for (int col = 0; col < COLS; col++) {
    colWidths[col] = random(20, 100);
    sumWidth += colWidths[col];
  }
  float factorWidth = width / sumWidth;
  for (int col = 0; col < COLS; col++) {
    colWidths[col] *= factorWidth;
  }
  
  // Lancer l'animation
  transition = 0;
  Ani.to(this, 1.5, "transition", 1, Ani.ELASTIC_OUT);
}

void keyPressed() {
  if (key == ' ') {
    regenerateGrid();
  }
}
