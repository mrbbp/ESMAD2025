# Processing - faire ses outils

Created: 26 septembre 2023 18:07

# les trucs à connaitre

## Lancer la lecture

`Command + R`

## Taille de la fenêtre

```java
size(600,600);
// size(600,600, P2D);
pixelDensity(2); // écran retina
```

## Fullscreen

```java
fullscreen();
fullscreen(1); // l'écran principal
fullscreen(2,P2D);  // sur le deuxième écran avec moteur P2D
```

## Utiliser la souris

```java
//mouseX , mouseY
imageMode(CENTER); // positionne l'image par son centre (modifie la "poignée")
image(img,mouseX,mouseY,); // positionne l'image au curseur

void mouseMoved() {
	// quand la souris s'est déplacée
}
void mouseReleased() {
	// quand le bouton de la souris est a été relaché (ne déclenche qu'une seule fois)
}
void mousePressed() {
	// quand le bouton de la souris a été appuyé (ne déclenche qu'une seule fois)
}
```

## Déclencher des événements avec le clavier

```java
void keyReleased() {
  if (key =='s' || key == 'S') {
    …
  }
}
```

## Importer une image

```java
PImage img;
img = loadImage("portrait.jpg");
img.resise(largeur,0);
// img.resise(0,hauteur);
image(img,0,0);

```

## Copier une portion d’image

```java
PImage img, imgF;
img = loadImage("portrait.jpg");
imgF = createImage(img.width,img.height,RGB);
copy(img,dx,dy,dwith,dheight,fx,fy,fwidth,fheight);
```

## Importer un svg

```java
PShape motif;
motif = loadShape("croix_2.svg");
shapeMode(CENTER);
shape(motif, width/2, height/2);
// shape(motif, width/2, height/2, largeur, hauteur);
```

## Colorer les tracés d’un svg

```java
PShape motif;
motif = loadShape("croix_2.svg");
noStroke();
shape(motif, width/2, height/2);
**motif.disableStyle();
fill(200,0,0);**
```

## Importer plusieurs documents dans une table (Array)

```java
PShape[] motif = new PShape[2];
for (int i=0;i<2;i++) {
  motif[i] = loadShape("truchet_"+i+".svg");
}
shapeMode(CENTER);
shape(motif[floor(random(2))], width/2,height/2);
```

## Enregistrer une image

### Enregistrer un **png / jpg**

`save("nom.ext")`

### Enregister une suite d’images (png / jpg)

`saveFrame("nom###.png")`

### Enregistrer un **pdf**

```java
import processing.pdf.*;

beginRecord(PDF, "fichier.pdf");
…
endRecord();
```

```java
import processing.pdf.*;
Boolean save = false;

void draw() {
	if (save) {
		beginRecord(PDF, "fichier.pdf");
	}
	/* 
			ici on dessine
	*/
	if (save) {
		endRecord();
		save = false;
	}
}

void keyReleased() {
  if (key =='s' || key == 'S') {
	   save = true;
  }
}
```

[PDF Export / Libraries](https://processing.org/reference/libraries/pdf/index.html)

### Enregistrer une animation en pdf

```java
import processing.pdf.*;

beginRecord(PDF, "frame-####.pdf");
…
endRecord();
```

### Dessiner dans un pdf

```java
import processing.pdf.*;

PGraphics pdf = createGraphics(300, 300, PDF, "output.pdf");
```

### Enregistrer en **svg**

```java
import processing.svg.*;

beginRecord(SVG, "fichier.svg");
…
endRecord();
```

[SVG Export / Libraries](https://processing.org/reference/libraries/svg/index.html)

## Tourner une forme / une image

```java
rectMode(CENTER);
pushMatrix(); // mémorise la position
	translate(width/2,height/2); // déplace le centre du monde au centre de la fenêtre
	rotate(radians(45)); // tourne de 45°
	square(0,0,50); // dessine un carré (en 0,0)
popMatrix(); // revient à la position initiale
```

## Remapper une valeur (changer l’échelle de la valeur)

On peut modifier simplement les plages de valeur d’une donnée en entrée, pour une autre plage de valeur en sortie.

On peut recevoir un valeur en 0 et 1 (un générateur d’aléatoire) et la transformer en valeur entre 0 et 128, ou entre -100 et + 100.

```java
int resultat = int(map(valeur, inMin, inMax, outMin,outMax));
//int resultat = int(map(valeur,0,1,-100,100));
```

<aside>
💡 Par défaut les valeurs retournées sont en ***float***

</aside>

## Midi via midibus (Hervé BI)

```java
import themidibus.*; //Importe la bibliothèque

MidiBus leBus; // instancie l'objet MidiBus

void setup() {
	MidiBus.list(); // liste les devices midi branchés 
	// initialise l'objet midiBus sur les bons ports en entrée / sortie (vérifier dans la console)
  //               Parent In Out
  //                  |    |  |
  leBus = new MidiBus(this, 1, 2);
  // initialise les valeurs du device
	// dépend de la programmation du device, ici l'envoie d'une note renvoie l'état des potentiomètres
  leBus.sendNoteOff(new Note(0,64,127));
}

/* gestionnaire midi controllerChange */
void controllerChange(int canal, int numero, int valeur) {
    switch(numero) {
      case 36: // si le numero du contrôleur est 36
				/* placer le code pour ce contrôleur */
        break;
      default:
        println(numero,valeur,"port non configuré");
    }
}
/*  
		Afin de pouvoir les combiner et conserver une correspondance de mappage avec le GRID de IntechStudio
		les boitiers `Hervé-Bi midi` (potentimètre rotatif) utilisent les contrôleurs 31,32 ou 33,34
		les boitiers `Robert midi` (encodeur rotatif) utilisent le controleur 35 et 36 pour le click
		
		De conception plus ancienne, la `boitapotar` 8 potars utilise les controleurs 31 à 38
			(comme le GRID de IntechStudio)
*/
```

## Usage de Robert en midi

```java
/*
  croquis pour la prise en charge de Robert Midi
  Robert est composé d'un encodeur rotatif (vis sans fin) avec un click
	le Contrôleur midi est en 35 et 36 (click)
  le code ici gère un compteur 'RE' qui augmente et diminue selon le sens de rotation.
  l'encodeur en midi renvoie une valeur tournante comprise entre 0 et 127 (modulo 128)
  
  on peut aussi récupérer la valeur brute tournante et l'utiliser pour boucler sur un Array;
  
  p.ex : 
    int[] table = new int[10] ; // crée une table de 10 élements
    println(valeur%table.length); // boucle sur les valeurs de la table
*/
import themidibus.*; //Import the library

MidiBus leBus; // The MidiBus
int[] table = new int[10] ;

void setup() {
  MidiBus.list(); 
  //                   Parent In Out
  //                     |    |  |
  //myBus = new MidiBus(this, 1, 2);
  delay(100);
  leBus = new MidiBus(this, 1, 2);
    // initialise les valeurs du device
  leBus.sendNoteOff(new Note(0,64,127));
  delay(100);
}

void draw() {
  
  
}
int oldV = 999;
int RE = 0;

void controllerChange(int channel, int nombre, int valeur) {
    switch(nombre) {
      case 36:
        println("bouton pressé");
        /* ajouter le code pour le click */
        break;
      case 35:
        println(valeur%table.length);
        //println(oldV,valeur);
        if (oldV == 999) { // premiere fois
           oldV = valeur;
           if (valeur > 0) { RE++; } 
           if (valeur < 0) { RE--; }
        } else {
          if (valeur == 0 && oldV == 127) { RE++; } 
          else if (valeur == 127 && oldV == 0) { RE--; } 
          else { // les autres cas
            if (valeur > oldV) { RE++; } 
            else { RE--; }
          }
        }
        // mise à jour des valeurs
        oldV = valeur;
        break;
      default:
        println("port: ",nombre,"valeur: ",valeur);
    }
    println( "RE: ",RE);
}
```