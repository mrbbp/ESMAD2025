import de.looksgood.ani.*;

// Définition des couleurs
color red = #FF4500;
color beige = #FFEFD5;

// Paramètres de la grille
int cols = 9;      
int rows = 16;      
float cellWidth;   
float cellHeight;  
float offsetX;     

// Une classe pour stocker le décalage de chaque ligne
class LineShift {
  float value = 0;  // La valeur à animer
}

// Tableau d'objets pour les décalages
LineShift[] lineShifts = new LineShift[rows + 1];

void setup() {
  size(540, 960);
  pixelDensity(2);
  
  // Initialisation des paramètres de la grille
  cellWidth = width / (cols - 2);
  cellHeight = height / rows;
  offsetX = cellWidth / 2;
  
  // Initialisation d'Ani
  Ani.init(this);
  Ani.setDefaultEasing(Ani.ELASTIC_OUT);
  
  // Initialisation des objets de décalage
  for (int i = 0; i < lineShifts.length; i++) {
    lineShifts[i] = new LineShift();
  }
  
  println("Setup complete");
}

void draw() {
  background(0);
  
  // Debug info
  println("Drawing frame - First line shift: " + lineShifts[0].value);
  
  // Stockage des points de la grille
  PVector[][] points = new PVector[rows + 1][cols + 2];
  
  // Création de la grille de points avec décalage
  for (int y = 0; y <= rows; y++) {
    float yPos = y * cellHeight;
    float xOffset = (y % 2 == 0) ? 0 : offsetX;
    
    float baseSkew = map(yPos, 0, height, -20, 20);
    float finalSkew = baseSkew + lineShifts[y].value;
    
    for (int x = 0; x < cols + 2; x++) {
      float xPos = (x * cellWidth) - cellWidth + xOffset;
      points[y][x] = new PVector(xPos + finalSkew, yPos);
    }
  }
  
  // Dessin des quadrilatères
  noStroke();
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      if ((x + y) % 2 == 0) {
        fill(red);
      } else {
        fill(beige);
      }
      
      beginShape();
      vertex(points[y][x].x, points[y][x].y);
      vertex(points[y][x + 1].x, points[y][x + 1].y);
      vertex(points[y + 1][x + 1].x, points[y + 1][x + 1].y);
      vertex(points[y + 1][x].x, points[y + 1][x].y);
      endShape(CLOSE);
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    println("Animation triggered");
    
    // Animation pour chaque ligne
    for (int i = 0; i < lineShifts.length; i++) {
      float edgeFactor = 1.0;
      if (i == 0 || i == rows) edgeFactor = 0.3;
      float targetShift = random(-30, 30) * edgeFactor;
      
      // Animation de la propriété 'value' de l'objet LineShift
      Ani.to(lineShifts[i], 1.5, "value", targetShift);
    }
  }
  
  if (key == 's' || key == 'S') {
    save("geometric_pattern.png");
  }
}
