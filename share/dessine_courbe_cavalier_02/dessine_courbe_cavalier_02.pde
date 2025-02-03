/*
  written with google gemini on an idea by JN Lafargue @jeannoellafargue
  the position of the points corresponds to the possible movements of a knight on a chessboard.
  with a random or fixed start
*/
import java.util.ArrayList;

class Position {
  int x, y;
  Position(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

ArrayList<Position> parcoursCavalier(int tailleX, int tailleY, int limite) {
  int[][] plateau = new int[tailleX][tailleY];
  ArrayList<Position> parcours = new ArrayList<Position>();

  // Position de départ aléatoire
  //int x = int(random(tailleX));
  //int y = int(random(tailleY));
  int x = tailleX/2;
  int y = 0;
  plateau[x][y] = 1;
  parcours.add(new Position(x, y));

  int[] dx = {-2, -1, 1, 2, 2, 1, -1, -2};
  int[] dy = {1, 2, 2, 1, -1, -2, -2, -1};

  while (parcours.size() < limite) {
    boolean trouve = false;
    ArrayList<Position> mouvementsPossibles = new ArrayList<Position>();
    
    // Trouver tous les mouvements possibles depuis la dernière position
    for (int i = 0; i < 8; i++) {
      int nx = x + dx[i];
      int ny = y + dy[i];
      if (nx >= 0 && nx < tailleX && ny >= 0 && ny < tailleY && plateau[nx][ny] == 0) {
        mouvementsPossibles.add(new Position(nx, ny));
      }
    }

    // Si au moins un mouvement est possible, choisir un au hasard
    if (mouvementsPossibles.size() > 0) {
      int choix = int(random(mouvementsPossibles.size()));
      Position nouvellePosition = mouvementsPossibles.get(choix);
      x = nouvellePosition.x;
      y = nouvellePosition.y;
      plateau[x][y] = 1;
      parcours.add(nouvellePosition);
      trouve = true;
    }

    // Si aucun mouvement possible, on sort de la boucle
    if (!trouve) {
      break;
    }
  }

  return parcours;
}

ArrayList<Position> parcours;
int tailleX = 12; // largeur echiquier
int tailleY = 12; // hauteur échiquier
int limite = 30;
int initX, initY;
int size = 32;
int scaleTot = 15;

void setup() {
  size(800,800);
  initX = (width/2)-(tailleX*size/2);
  initY = (height/2)-(tailleY*size/2);
  pixelDensity(2);
  parcours = parcoursCavalier(tailleX, tailleY, limite);
  for (Position p : parcours) {
    // Dessiner un cercle à la position p.x, p.y
    //println(p.x,p.y);
  }
  println(parcours.size());
  frameRate(12);
  ///noLoop();
}

void draw() {
  background(220);
  strokeWeight(3);
  stroke(255,128,0);
  noFill();
  beginShape();
  for (int i=0;i<parcours.size();i++) {
    //println(parcours.get(i).x);
    curveVertex((parcours.get(i).x*size)+initY,(parcours.get(i).y*size)+initY);
    //vertex(parcours.get(i+1).x*8,parcours.get(i+1).y*12);
  }
  endShape();
  for (int i=0;i<parcours.size();i++) {
    if (i > 0 && i<parcours.size()-1) {
      noStroke();
      fill(0);
      circle((parcours.get(i).x*size)+initY,(parcours.get(i).y*size)+initY, 10);
    }
  }
  
  parcours = parcoursCavalier(tailleX, tailleY, limite);
  // ... (votre code pour afficher le parcours, par exemple)
  //for (Position p : parcours) {
  //  // Dessiner un cercle à la position p.x, p.y
  //  println(p.x,p.y);
  //}
}
void mousePressed() {
  // Redessiner lors d'un clic de souris
  //saveFrame("G_Nees_1970_Untitled_###.png");
  background(255);
  redraw();
}
