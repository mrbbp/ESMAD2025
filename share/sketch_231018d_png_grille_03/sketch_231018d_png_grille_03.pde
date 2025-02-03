/*
  paint on a grid with differents pictures/patterns (6)
  each time you release the mouse button, the pattern change.
*/
PImage[] motifs = new PImage[6];
int compteur = 0;
int largeurPinceau = 25;

void setup() {
  size(800,800);
  pixelDensity(2);
  background(255);
  noStroke();
  fill(50);
  for (int i=0; i<6; i++) {
    motifs[i] = loadImage("motif_"+i+".png");
    motifs[i].resize(largeurPinceau,largeurPinceau);
  }
}

void draw() {
  if (mousePressed) {
    image(motifs[compteur%6],int(mouseX/largeurPinceau)*largeurPinceau,int(mouseY/largeurPinceau)*largeurPinceau);
    //circle(int(mouseX/largeurPinceau)*largeurPinceau,int(mouseY/largeurPinceau)*largeurPinceau,largeurPinceau*1);
  }
}

void mousePressed() {
  compteur++;
}
