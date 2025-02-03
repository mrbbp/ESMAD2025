/*
  v2:
   - ajout de rotate(float degré) tourne le motif
 v3:
   - ajout de globalRotate(float degré) tourne le fond
 v4:
   - ajout followMouse(true)
 v5:
   - modif epaisseur stroke et caps
 v6:
   - setSize() peut n'avoir qu'un parametre de defini
   - javadoc + exemple dans la classe
   - setPadding
   - suppression setOffset()
   - ajout load();
   
 */
import themidibus.*;

BackgroundPattern bg;

float patternRotation = 0;
float globalRotation = 0;
float epaisseur = 1;

void setup() {
  size(1000, 1000);
  pixelDensity(2);

  //bg = new BackgroundPattern(this, "motif64.png");
  //bg.setSize(64, 64);
  bg = new BackgroundPattern(this, "fleche.svg");
  bg.setSize(0,100);
    // Ou pour créer un motif unique centré :
  //bg.setRepeat("no-repeat", "no-repeat");
  bg.followMouse(true); // Activer le suivi de souris
}

void draw() {
  background(255);
  //patternRotation = map(mouseX, 0, width, 0, 360);
  //if (!bg.followingMouse) {
  //  bg.rotate(patternRotation);
  //}
  bg.globalRotate(globalRotation+=.5);
  //bg.setStrokeWeight(epaisseur);
  //bg.setStrokeCap(SQUARE);
  bg.setPadding(50);
  bg.display();
}

void keyPressed() {
  if (key == ' ') {
    // Espace pour activer/désactiver le suivi de souris
    bg.followMouse(!bg.followingMouse);
  }
  if (key == '1' || key=='&') bg.load("code.svg");
  if (key == '2' || key=='é') bg.load("is.svg");
  if (key == '3' || key=='"') bg.load("good.svg");
  if (key == '4' || key=='\'') bg.load("fleche.svg");
}
