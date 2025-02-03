import processing.svg.*;

// Constantes globales
final int GRID_COLS = 10;
final int GRID_ROWS = 10;
final int MAX_MODULE_HEIGHT = 4;
final int MODULE_VARIANTS = 4;

// Variables calculées dynamiquement
int MODULE_BASE_SIZE;  // Calculé dans setup()
int MODULE_MARGIN;     // Calculé dans setup()

// Palette de couleurs
color[] PALETTE = {
  #FF6B6B, // rouge corail
  #4ECDC4, // turquoise
  #45B7D1, // bleu ciel
  #96CEB4, // vert menthe
  #FFBE0B, // jaune soleil
  #FF006E, // rose vif
  #8338EC  // violet
};

// Variable globale pour la grille
Grid grid;
color couleur;

boolean saveFrame = false;
String timestamp;

void setup() {
  size(800, 800);
  pixelDensity(2);
  calculateModuleDimensions();
  grid = new Grid();
  grid.placeInitialModules();
  grid.fillRemaining();
  noLoop();
}

void draw() {
  if (saveFrame) beginRecord(SVG, "grille_" + timestamp + ".svg");
  background(255);

  // Calcul de la largeur totale avec toutes les marges
  float totalWidth = (GRID_COLS * MODULE_BASE_SIZE) + ((GRID_COLS - 1) * MODULE_MARGIN);
  float totalHeight = (GRID_ROWS * MODULE_BASE_SIZE) + ((GRID_ROWS - 1) * MODULE_MARGIN);

  // Calcul des marges pour centrer
  float marginX = (width - totalWidth) / 2;
  float marginY = (height - totalHeight) / 2;

  translate(marginX, marginY);
  grid.display();

  if (saveFrame) {
    endRecord();
    save("grille_" + timestamp + ".png");
    println("Fichiers sauvegardés : grille_" + timestamp + ".png/svg");
    saveFrame = false;
  }
}

//void calculateModuleDimensions() {
//  float availableSpace = min(width, height);
//  float divider = GRID_COLS + (GRID_COLS - 1) / 19.0;
//  MODULE_BASE_SIZE = floor(availableSpace / divider);
//  MODULE_MARGIN = floor(MODULE_BASE_SIZE / 19.0);
//}
void calculateModuleDimensions() {
  // Calcul séparé pour la largeur et la hauteur
  // Pour chaque unité de module, nous avons besoin d'1/19e d'espace pour la marge
  float moduleWidthByScreen = width / (GRID_COLS + (GRID_COLS - 1) / 19.0);
  float moduleHeightByScreen = height / (GRID_ROWS + (GRID_ROWS - 1) / 19.0);
  
  // On prend la plus petite dimension pour garder les modules carrés
  MODULE_BASE_SIZE = floor(min(moduleWidthByScreen, moduleHeightByScreen));
  
  // La marge est exactement 1/19e de la taille du module
  MODULE_MARGIN = floor(MODULE_BASE_SIZE / 19.0);
  
  // Vérification et ajustement si nécessaire pour remplir l'écran
  float totalWidth = (GRID_COLS * MODULE_BASE_SIZE) + ((GRID_COLS - 1) * MODULE_MARGIN);
  float totalHeight = (GRID_ROWS * MODULE_BASE_SIZE) + ((GRID_ROWS - 1) * MODULE_MARGIN);
  
  // Si les dimensions totales sont trop petites, on ajuste
  if (totalWidth < width * 0.98 && totalHeight < height * 0.98) {
    float widthScale = (width * 0.98) / totalWidth;
    float heightScale = (height * 0.98) / totalHeight;
    float scale = min(widthScale, heightScale);
    
    MODULE_BASE_SIZE = floor(MODULE_BASE_SIZE * scale);
    MODULE_MARGIN = floor(MODULE_BASE_SIZE / 19.0);  // Maintien du ratio exact 1/19e
  }
}

class Module {
  int size;
  int variant;
  int x, y;
  boolean isHorizontal;
  PShape svg;
  Grid parentGrid;  // Référence à la grille parente

  Module(int size, int variant, boolean isHorizontal, Grid grid) {
    this.size = size;
    this.variant = variant;
    this.isHorizontal = isHorizontal;
    this.parentGrid = grid;
    loadSVG();
  }

  void loadSVG() {
    String path = "medias/module_" + size + "_" + variant + ".svg";
    svg = loadShape(path);
    //svg.disableStyle();
  }

  void display() {
    pushMatrix();
    if (isHorizontal) {
      translate(x * (MODULE_BASE_SIZE + MODULE_MARGIN),
        y * (MODULE_BASE_SIZE + MODULE_MARGIN));
      translate(0, MODULE_BASE_SIZE);
      rotate(-HALF_PI);
    } else {
      translate(x * (MODULE_BASE_SIZE + MODULE_MARGIN),
        y * (MODULE_BASE_SIZE + MODULE_MARGIN));
    }

    if (size == 1 && variant == 0) {
      svg.disableStyle();
      fill(parentGrid.currentColor);
      noStroke();
    } else {
      stroke(0);
      noFill();
    }

    shape(svg, 0, 0, MODULE_BASE_SIZE, size * MODULE_BASE_SIZE + (size - 1) * MODULE_MARGIN);
    popMatrix();
  }
}

class Grid {
  boolean[][] occupied;
  ArrayList<Module> modules;
  color currentColor;  // Couleur pour tous les module_1_0

  Grid() {
    occupied = new boolean[GRID_ROWS][GRID_COLS];
    modules = new ArrayList<Module>();
    currentColor = PALETTE[int(random(PALETTE.length))];  // Une seule couleur par grille
  }

  boolean canPlace(int x, int y, Module module) {
    if (module.isHorizontal) {
      if (x + module.size > GRID_COLS || y + 1 > GRID_ROWS) return false;
      for (int i = 0; i < module.size; i++) {
        if (occupied[y][x + i]) return false;
      }
    } else {
      if (x + 1 > GRID_COLS || y + module.size > GRID_ROWS) return false;
      for (int i = 0; i < module.size; i++) {
        if (occupied[y + i][x]) return false;
      }
    }
    return true;
  }

  void place(int x, int y, Module module) {
    module.x = x;
    module.y = y;

    if (module.isHorizontal) {
      for (int i = 0; i < module.size; i++) {
        occupied[y][x + i] = true;
      }
    } else {
      for (int i = 0; i < module.size; i++) {
        occupied[y + i][x] = true;
      }
    }
    modules.add(module);
  }

  int getRandomModuleSize() {
    float r = random(7);
    if (r < 3) return 1;      // 4/7 chance
    if (r < 6) return 2;      // 2/7 chance
    return 3;                 // 1/7 chance
  }

  //void placeInitialModules() {
  //  int totalArea = GRID_ROWS * GRID_COLS;
  //  int currentArea = 0;
  //  int placedModules = 0;

  //  // 20 essais maximum pour placer chaque module
  //  int maxAttempts = 20;

  //  while (placedModules < 4 && maxAttempts > 0) {
  //    int size = 2 + int(random(2));  // Taille 2 ou 3

  //    if (currentArea + size <= totalArea * 0.25) {  // 25% de la surface
  //      // Position aléatoire
  //      int x = int(random(GRID_COLS - size));
  //      int y = int(random(GRID_ROWS - 1));

  //      Module module = new Module(size, int(random(1, MODULE_VARIANTS)), true, this);
  //      if (canPlace(x, y, module)) {
  //        place(x, y, module);
  //        currentArea += size;
  //        placedModules++;
  //      }
  //    }
  //    maxAttempts--;
  //  }
  //}
  void placeInitialModules() {
    int totalArea = GRID_ROWS * GRID_COLS;
    float targetPercent = 0.2; // 10% de la surface
    int currentArea = 0;
    int maxAttempts = 40;  // Plus d'essais car on ne fixe pas le nombre de modules
    
    while (currentArea < totalArea * targetPercent && maxAttempts > 0) {
      int size = 2 + int(random(2));  // Taille 2 ou 3
      
      // Position aléatoire
      int x = int(random(GRID_COLS - size));
      int y = int(random(GRID_ROWS - 1));
      
      Module module = new Module(size, int(random(1, MODULE_VARIANTS)), true, this);
      if (canPlace(x, y, module)) {
        place(x, y, module);
        currentArea += size;
      }
      maxAttempts--;
    }
  }

  void fillRemaining() {
    for (int x = 0; x < GRID_COLS; x++) {
      int y = 0;
      while (y < GRID_ROWS) {
        if (!occupied[y][x]) {
          int maxSize = 1;
          while (maxSize < MAX_MODULE_HEIGHT && y + maxSize < GRID_ROWS && !occupied[y + maxSize][x]) {
            maxSize++;
          }

          int size = getRandomModuleSize();
          while (size > maxSize) {
            size = getRandomModuleSize();
          }
          Module module;
          if (size > 1) {
            module = new Module(size, int(random(1, MODULE_VARIANTS)), false, this);
          } else {
            module = new Module(size, int(random(MODULE_VARIANTS)), false, this);
          }
          if (canPlace(x, y, module)) {
            place(x, y, module);
          }
          y += size;
        } else {
          y++;
        }
      }
    }
  }

  void display() {
    for (Module module : modules) {
      module.display();
    }
  }
}

void keyPressed() {
  if (key == ' ') {  // Barre d'espace
    // Réinitialisation de la grille
    grid = new Grid();
    grid.placeInitialModules();
    grid.fillRemaining();
    redraw();
  }
  if (key == 's' ||  key == 'S') {  // Sauvegarde
    timestamp = year() + nf(month(), 2) + nf(day(), 2) + "_" +
      nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    saveFrame = true;
    redraw();
  }
}
