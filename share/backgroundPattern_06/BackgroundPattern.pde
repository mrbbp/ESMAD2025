/**
 * Classe gérant un motif répété en arrière-plan avec possibilité de chargement d'images ou de SVG.
 * <pre>
 * Exemple d'utilisation :
 * 
 * BackgroundPattern bg;
 * 
 * void setup() {
 *   size(800, 600);
 *   
 *   // Création du motif
 *   bg = new BackgroundPattern(this, "pattern.svg");
 *   
 *   // Configuration du motif
 *   bg.setSize(100, 0);           // Largeur 100px, hauteur proportionnelle
 *   bg.setStrokeWeight(2);        // Épaisseur des traits (SVG uniquement)
 *   bg.setStrokeCap(SQUARE);      // Style des traits (SVG uniquement)
 *   bg.rotate(45);                // Rotation de 45° de chaque motif
 *   bg.followMouse(true);         // Active l'orientation vers la souris
 * }
 * 
 * void draw() {
 *   background(255);
 *   bg.display();                 // Affiche le motif
 * }
 * 
 * ou encore
 *
 * BackgroundPattern bg;
 * 
 * void setup() {
 *   size(800, 600);
 *   bg = new BackgroundPattern(this, "pattern.svg");
 *   bg.setSize(100, 0);           // Largeur 100px, hauteur proportionnelle
 *   bg.setPadding(50);            // Marge intérieure de 50px
 *   bg.setStrokeWeight(2);        // Épaisseur des traits (SVG uniquement)
 * }
 * 
 * void draw() {
 *   background(255);
 *   bg.display();
 * }
 * </pre>
 */
class BackgroundPattern {
  PApplet parent;
  PImage pattern;
  PShape svgPattern;
  boolean isSVG;
  String repeatX = "repeat";
  String repeatY = "repeat";
  int padding = 0;
  int patternWidth, patternHeight;
  float rotation = 0;
  float globalRotation = 0;
  boolean followingMouse = false;
  float strokeWeight = 1;
  float originalRatio;

  /**
   * Constructeur initialisant un nouveau motif d'arrière-plan
   * @param p PApplet parent (le sketch Processing)
   * @param path chemin vers le fichier image ou SVG
   */
  BackgroundPattern(PApplet p, String path) {
    parent = p;
    load(path);
  }

    /**
   * Charge un nouveau motif
   * @param path chemin vers le fichier image ou SVG
   * @return true si le chargement a réussi, false sinon
   */
  boolean load(String path) {
    boolean success = false;
    isSVG = path.toLowerCase().endsWith(".svg");
    
    if (isSVG) {
      try {
        PShape newPattern = parent.loadShape(path);
        if (newPattern != null) {
          svgPattern = newPattern;
          pattern = null;
          originalRatio = svgPattern.width / svgPattern.height;
          patternWidth = int(svgPattern.width);
          patternHeight = int(svgPattern.height);
          success = true;
        } else {
          parent.println("Erreur: Impossible de charger le SVG " + path);
        }
      } catch (Exception e) {
        parent.println("Erreur lors du chargement du SVG: " + e.getMessage());
      }
    } else {
      PImage newPattern = parent.loadImage(path);
      if (newPattern != null) {
        pattern = newPattern;
        svgPattern = null;
        originalRatio = float(pattern.width) / pattern.height;
        patternWidth = pattern.width;
        patternHeight = pattern.height;
        success = true;
      } else {
        parent.println("Erreur: Impossible de charger l'image " + path);
      }
    }
    
    return success;
  }

  /**
   * Définit la taille du motif de façon proportionnelle.
   * Si width est 0, la largeur sera calculée proportionnellement à la hauteur donnée.
   * Si height est 0, la hauteur sera calculée proportionnellement à la largeur donnée.
   * Si aucun n'est 0, utilise les dimensions exactes spécifiées.
   * @param width largeur en pixels, ou 0 pour calcul automatique basé sur la hauteur
   * @param height hauteur en pixels, ou 0 pour calcul automatique basé sur la largeur
   */
  void setSize(int width, int height) {
    if (width == 0 && height > 0) {
      // Calcule la largeur proportionnelle à partir de la hauteur donnée
      patternHeight = height;
      patternWidth = int(height * originalRatio);
    } 
    else if (height == 0 && width > 0) {
      // Calcule la hauteur proportionnelle à partir de la largeur donnée
      patternWidth = width;
      patternHeight = int(width / originalRatio);
    }
    else {
      // Utilise les dimensions exactes spécifiées
      patternWidth = width;
      patternHeight = height;
    }
  }

  /**
   * Contrôle si le motif est dessiné au-delà des limites de la fenêtre.
   * Si "no-repeat" est spécifié pour un axe, les motifs ne seront dessinés 
   * que dans les limites de la fenêtre sur cet axe.
   * <pre>
   * Exemples :
   * bg.setRepeat("repeat", "repeat");      // dessine sans limite
   * bg.setRepeat("no-repeat", "repeat");   // limite aux bords gauche et droit
   * bg.setRepeat("repeat", "no-repeat");   // limite aux bords haut et bas
   * bg.setRepeat("no-repeat", "no-repeat"); // limite à la fenêtre
   * </pre>
   * @param x "repeat" pour dessiner sans limite horizontale, "no-repeat" pour limiter à la fenêtre
   * @param y "repeat" pour dessiner sans limite verticale, "no-repeat" pour limiter à la fenêtre
   */
  void setRepeat(String x, String y) {
      repeatX = x;
      repeatY = y;
  }

  /**
   * Définit une marge intérieure uniforme autour de la zone de dessin des motifs
   * @param p taille de la marge en pixels
   */
  void setPadding(int p) {
    padding = p;
  }

  /**
   * Définit la rotation individuelle des motifs en degrés
   * @param degrees angle de rotation
   */
  void rotate(float degrees) {
    rotation = degrees;
  }

  /**
   * Définit la rotation globale du fond en degrés
   * @param degrees angle de rotation
   */
  void globalRotate(float degrees) {
    globalRotation = degrees;
  }

  /**
   * Active ou désactive l'orientation automatique des motifs vers la souris
   * @param follow true pour activer le suivi de souris, false pour désactiver
   */
  void followMouse(boolean follow) {
    followingMouse = follow;
  }

  /**
   * Change l'épaisseur des traits pour les motifs SVG
   * @param weight épaisseur en pixels
   */
  void setStrokeWeight(float weight) {
    if (isSVG && svgPattern != null) {
      strokeWeight = weight;
      applyStrokeWeight(svgPattern, weight);
    }
  }

  /**
   * Définit le style des extrémités des traits pour les motifs SVG
   * @param cap style d'extrémité : ROUND, SQUARE, ou PROJECT
   */
  void setStrokeCap(int cap) {
    if (isSVG && svgPattern != null) {
      applyStrokeCap(svgPattern, cap);
    }
  }

  /**
   * Dessine le motif d'arrière-plan avec les paramètres actuels
   */

  void display() {
    if ((isSVG && svgPattern == null) || (!isSVG && pattern == null)) return;
    
    // On ignore le padding si on a une rotation globale
    boolean usesPadding = padding > 0 && globalRotation % 360 == 0;
    
    float effectiveWidth = parent.width - (usesPadding ? 2 * padding : 0);
    float effectiveHeight = parent.height - (usesPadding ? 2 * padding : 0);
    
    // Marge supplémentaire pour la rotation
    float extraMargin = 0;
    if (globalRotation % 360 != 0) {
      float diagonal = parent.sqrt(parent.width * parent.width + parent.height * parent.height);
      extraMargin = diagonal - parent.min(parent.width, parent.height);
    }
    
    // Nombre de motifs nécessaires
    int countX = ceil((effectiveWidth + 2 * extraMargin) / patternWidth) + 2;
    int countY = ceil((effectiveHeight + 2 * extraMargin) / patternHeight) + 2;
    
    // Point de départ
    float startX = -extraMargin - (usesPadding ? 0 : patternWidth);
    float startY = -extraMargin - (usesPadding ? 0 : patternHeight);
    
    parent.pushMatrix();
    
    parent.translate(parent.width/2, parent.height/2);
    parent.rotate(parent.radians(globalRotation));
    parent.translate(-parent.width/2, -parent.height/2);
    
    // Calcul de la position de la souris pour followMouse
    float mouseX = parent.mouseX - parent.width/2;
    float mouseY = parent.mouseY - parent.height/2;
    float cosRot = parent.cos(-parent.radians(globalRotation));
    float sinRot = parent.sin(-parent.radians(globalRotation));
    float transformedMouseX = mouseX * cosRot - mouseY * sinRot + parent.width/2;
    float transformedMouseY = mouseX * sinRot + mouseY * cosRot + parent.height/2;
    
    // Dessiner la grille
    for (int i = 0; i < countY; i++) {
      for (int j = 0; j < countX; j++) {
        float x = startX + j * patternWidth;
        float y = startY + i * patternHeight;
        
        // On dessine toujours si on est en rotation globale
        // Sinon on vérifie le padding
        if (!usesPadding || 
           (x + patternWidth >= padding && 
            x <= parent.width - padding && 
            y + patternHeight >= padding && 
            y <= parent.height - padding)) {
            
          parent.pushMatrix();
          float centerX = x + patternWidth/2;
          float centerY = y + patternHeight/2;
          parent.translate(centerX, centerY);
          
          if (followingMouse) {
            float angle = angleToPoint(centerX, centerY, transformedMouseX, transformedMouseY);
            parent.rotate(parent.radians(angle));
          } else {
            parent.rotate(parent.radians(rotation));
          }
          
          if (isSVG) {
            float scaleX = float(patternWidth) / svgPattern.width;
            float scaleY = float(patternHeight) / svgPattern.height;
            parent.scale(scaleX, scaleY);
            parent.shape(svgPattern, -svgPattern.width/2, -svgPattern.height/2);
          } else {
            parent.image(pattern, -patternWidth/2, -patternHeight/2, 
                        patternWidth, patternHeight);
          }
          
          parent.popMatrix();
        }
      }
    }
    
    parent.popMatrix();
  }


  // Méthodes privées
  
  private void applyStrokeWeight(PShape shape, float weight) {
    shape.setStrokeWeight(weight);
    
    int childCount = shape.getChildCount();
    if (childCount > 0) {
      for (int i = 0; i < childCount; i++) {
        applyStrokeWeight(shape.getChild(i), weight);
      }
    }
  }
  
  private void applyStrokeCap(PShape shape, int cap) {
    shape.setStrokeCap(cap);
    
    int childCount = shape.getChildCount();
    if (childCount > 0) {
      for (int i = 0; i < childCount; i++) {
        applyStrokeCap(shape.getChild(i), cap);
      }
    }
  }
  
  private float angleToPoint(float x1, float y1, float x2, float y2) {
    float dx = x2 - x1;
    float dy = y2 - y1;
    float angle = parent.degrees(parent.atan2(dy, dx));
    return angle + 90;
  }
}
