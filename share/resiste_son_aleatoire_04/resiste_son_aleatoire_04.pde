/* avec un shuffle au demarrage et tirage dans l'ordre du désordre 
    commence le premier extrait

*/
import processing.sound.*;

//add your sounds to an array.
SoundFile[] sons = new SoundFile[37];
int nbrSons = 37;

IntList liste;
int tirage = 0;
boolean first = true;

void setup() {
  liste = new IntList();
  for (int i = 0; i < nbrSons; i++) {
    sons[i] = new SoundFile(this, "e" + i + ".wav");
    if (i>0) {
      liste.append(i);
    }
  }
  liste.shuffle();
  println(liste);
  liste.append(liste.get(0));
  liste.set(0,0);
  println(liste);
  // lit le premier fichier
  tirage = 0;
}

void draw() {
  if (first) {
    if (sons[liste.get(tirage)].isPlaying()) {
      println("ça lit");
      first = false;
    } else {
       sons[liste.get(tirage)].play();
      println("vide");
    }
  } else {
    if (!sons[liste.get(tirage)].isPlaying()) {
      // si son fini
      if (tirage < nbrSons-1) {
        tirage++;
        // lit le suivant dans la liste
        sons[liste.get(tirage)].play();
        println(tirage, liste.get(tirage));
      } else {
        noLoop();
        println("playlist finie");
      }
    }
  }
}
