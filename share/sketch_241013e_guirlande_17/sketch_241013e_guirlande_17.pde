/*
  
 v8:
 - plusieurs feuilles utilisées
 - enregistre dans un fichier JSON la structure
 v9 :
 - charge un fichier json pour reconstituer un dessin (structure)
 v10
 - ajout d'un bouton de chargement et de sauvegarde
 v11
 - refactor du code de drawLeaf avec de nouvelles feuilles
 v12
 - ajout d'une animation des feuilles avec bruit de perlin en fonction de l'ordre de dessin des segments
 v13
 - calcule d'une distance des segments à une source pour initialiser les mouvements des feuilles
 - ajout de la seed dans le json
 v14
 - ajout d'une progressBar pdt l'enregistrement
 - changement des feuilles et de l'algo de placement dans drawLeaf
 v15
 - ajout d'un slider pour modifier l'incrément du deplacement dans le bruit de perlin
 - prise en charge d'un device midi pour régler le seedIncrement (interfce physique et sur ecran)
 - sauvegarde/chargement des réglages de maxRot, minRot et du seedIncrement dans le fichier JSON
 - correction premier numéro image (0)
 - ajout d'un mode esquisse (pas de svg juste des traits)
 - ajout d'un bouton pour enregistrer une sequence
 - modif des valeurs de seedIncrement par defaut
 v16
 - redisposition de l'interface en haut et en bas de l'écran
 - ajout d'un slider pour la taille des éléments svg graphiques (scaleG)
 - ajout de vScaleG dans les settings du json
 - ajout du glisser-Déposer d'un fichier json (avec invite en fond d'écran)
 - ajout d'un saveOnExit du fichier json encours (pas d'image sauvegardée)
 - refactor du code (un peu)
 v17
  - ajout d'un seed pour la position des points avec un facteur d'agrandissement
  - ajout d'un slider pour la taille min des segments (minDistance remplace final int MIN_DISTANCE)
  - ajout d'un slider pour amplitude du mouvement des points (ampAnimPoint) - qui modifie amplitudeMax dans la classe AnimatedPoint
  - correction orientation et position de la première feuille
  - réintroduction du scale des premieres et dernières feuilles.
 
 TODO
 afficher les raccourcis clavier
 
 */
import processing.svg.*;
import controlP5.*;
//import themidibus.*; // Ajout de la bibliothèque MIDI
import drop.*;

// Constantes
final color BACKGROUND_COLOR = #f2f2f2;
final int MIN_DISTANCE = 20;
final int MAX_COUNTER_IMG = 250;
final float SCALE_DEBUT_FIN = 0.7;

// CLASSES PRINCIPALES
class Segment {
  PVector start, end, direction;
  float angle, scale, fScale, seed, seedM;
  int gdFirst, nShapeL, nShapeR;

  Segment(PVector start, PVector end) {
    this.start = start;
    this.end = end;
    this.direction = PVector.sub(end, start).normalize();
    this.angle = random(-30, 30);
    this.scale = random(0.19, .222);
    this.fScale = 70;//random(30, 50);
    this.gdFirst = round(random(1));
    this.nShapeL = int(random(svgShape.length));
    this.nShapeR = int(random(svgShape.length));

    // Calcul de la distance à l'origine pour placer la graine
    //if (dist(0, 0, start.x, start.y) >= dist(0, 0, end.x, end.y)) {
      this.seedM = this.seed = (dist(0, 0, end.x, end.y)/500);
    //} else {
    //  this.seedM = this.seed = (1/dist(0, 0, start.x, start.y)/500);
    //}
  }
}

class Line {
  ArrayList<Segment> segments;
  ArrayList<AnimatedSegment> animatedSegments;

  Line() {
    segments = new ArrayList<Segment>();
  }

  void addSegment(PVector start, PVector end) {
    segments.add(new Segment(start, end));
  }
}

// Variables globales
ArrayList<Line> allLines;
Line currentLine;
PShape[] svgShape = new PShape[14];

// Interface utilisateur
ControlP5 cp5;
Slider progressImg, seedSlider, scaleG, ampAnimPoint;
Toggle esquisseToggle;
Button saveJ, saveSeq;

// État de l'application
boolean isDrawing = false;
boolean recordSVG = false;
boolean recordVideo = false;
boolean fileLoaded = false;
boolean esquisse = false;
boolean dessine = true;
boolean clearScreen = true;
boolean saveOnExit = false;

// Paramètres
float xoff = 0;
float seed = random(1);
float vScaleG = .25;
float seedIncrement = 0.03;
int compteurImg = 0;
int rotMin = 40;
int rotMax = -20;
int nLines = 0;
color BACKGROUND = BACKGROUND_COLOR;
float minDistance = 20; // remplace final int MIN_DISTANCE = 20;
float amplitudeMax = 16.0;  // déplacé de AnimatedPoint

// Gestion fichiers
String currentFileName;
String messageAcc = "Glissez-déposez un fichier JSON\nou dessinez\n\n<E> pour passer en mode ESQUISSE\n<S> pour sauvegarder un png et un svg\n<V> pour lancer l'enregistrement de 250 img";
String message = messageAcc;
String messageNonJSON = "Ce n'est pas un fichier JSON valide!";

// DragNDrop
SDrop drop;
DropListener dropListener;

/* SETUP */
void setup() {
  size(1000, 1000);
  background(225);
  pixelDensity(2);
  allLines = new ArrayList<Line>();

  /* DragNDrop*/
  drop = new SDrop(this);
  dropListener = new DropListener() {
    public void dropEvent(DropEvent theDropEvent) {
      handleDropEvent(theDropEvent);
    }
  };
  drop.addDropListener(dropListener);

  // Initialisation MIDI
  //MidiBus.list(); // Liste tous les périphériques MIDI disponibles
  //bus = new MidiBus(this, 1,2);

  // Charge le fichier SVG
  for (int i=0; i<svgShape.length; i++) {
    svgShape[i] = loadShape("feuille_4_"+i+".svg");
  }

  cp5 = new ControlP5(this);

  // bouton de chargement du json
  cp5.addButton("loadJSON")
    .setPosition(110, 10)
    .setSize(100, 20)
    .setCaptionLabel("Charger JSON");

  // bouton de sauvegarde du json
  saveJ = cp5.addButton("saveJSON")
    .setPosition(230, 10)
    .setSize(100, 20)
    .setCaptionLabel("Enregistrer JSON")
    .setVisible(false)
    ;

  saveSeq = cp5.addButton("video")
    .setPosition(width-110, 10)
    .setSize(100, 20)
    .setCaptionLabel("Enreg. Seq.")
    .onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent event) {
      // Cette fonction est appelée pendant le glissement
      recordVideo = true;
      println("enregistre séquence");
    }
  }
  )
  .setVisible(false)
    ;
    
  // Slider pour la distance minimale des segments
  cp5.addSlider("minDistance")
    .setPosition(10, height - 30)  // position au-dessus des autres sliders
    .setSize(150, 20)
    .setRange(5, 40)
    .setDecimalPrecision(0)
    .setValue(20)
    .setNumberOfTickMarks(46)
    .setLabel("Dist. min. seg.")
    .getCaptionLabel()
    .setColor(color(0, 0, 0))
    ;
  // nouveau slider pour le contrôle de l'incrément
  seedSlider = cp5.addSlider("seedIncrement")
    .setPosition(230, height - 30)  // positionné à droite du bouton
    .setSize(200, 20)
    .setRange(0.001, 0.03)
    .setDecimalPrecision(3)
    .setValue(0.008)
    .setNumberOfTickMarks(200)
    .setLabel("Seed Incr.")
    .setVisible(false)
    ;

  scaleG = cp5.addSlider("vScaleG")
    .setPosition(490, height - 30)  // positionné à droite du bouton
    .setSize(160, 20)
    .setRange(0.01, .7)
    .setDecimalPrecision(2)
    .setValue(vScaleG)
    .setNumberOfTickMarks(200)
    .setLabel("Scale seg")
    .setVisible(false)
    ;
    
   ampAnimPoint = cp5.addSlider("amplitudeMax")
    .setPosition(710, height - 30)  // après scaleG (500 + 200 + 60)
    .setSize(200, 20)
    .setRange(1, 30)
    .setDecimalPrecision(1)
    .setValue(16.0)
    .setNumberOfTickMarks(291)
    .setLabel("Amp. Max.")
    .setVisible(false)
    ;
    
  // Création du slider/progress bar
  progressImg = cp5.addSlider("progress")
    .setPosition(width/2 - 100, height/2 - 10)
    .setSize(200, 20)
    .setRange(0, MAX_COUNTER_IMG)
    .setValue(0)
    .setLock(true)
    .setLabel("Enregistrement de l'image")
    .setVisible(false)
    ;
    
  /* style des composants */
  seedSlider.getCaptionLabel()
    .setColor(color(0, 0, 0));
  scaleG.getCaptionLabel()
    .setColor(color(0, 0, 0));
  progressImg.getCaptionLabel()
    .setColor(color(0, 0, 0))
    .align(ControlP5.CENTER, ControlP5.TOP)
    ;
  progressImg.getCaptionLabel().getStyle().marginTop = -15;
  ampAnimPoint.getCaptionLabel()
    .setColor(color(0, 0, 0));

  // Checkbox pour le mode esquisse
  esquisseToggle = cp5.addToggle("esquisse")
    .setPosition(10, 10)
    .setSize(20, 20)
    .setCaptionLabel("Mode Esquisse")
    .setValue(false);

  // Personnalisation du style du label
  esquisseToggle.getCaptionLabel()
    .setColor(color(25, 25, 25))
    .align(ControlP5.LEFT, ControlP5.CENTER)
    .getStyle().setMarginLeft(25)
    ;

  //delay(1000);
  //bus.sendNoteOff(new Note(0,64,127));
}

// Classe pour stocker temporairement les points animés
class AnimatedPoint {
  PVector original;
  PVector animated;
  float seed;
  
  AnimatedPoint(PVector point, float seed) {
    original = point.copy();
    animated = point.copy();
    this.seed = seed;
  }
  
  void update() {
    //float amplitudeMax = 16.0;
    // Utilise la même seed mais avec des offsets différents pour X et Y
    float noiseX = noise(seed + frameCount * 0.02) * 2 - 1;
    float noiseY = noise(seed + 1000 + frameCount * 0.02) * 2 - 1;
    animated.x = original.x + noiseX * amplitudeMax;
    animated.y = original.y + noiseY * amplitudeMax;
  }
}

class AnimatedSegment {
  AnimatedPoint start;
  AnimatedPoint end;
  Segment originalSegment;
  
  AnimatedSegment(Segment segment) {
    originalSegment = segment;
    // Utilise la seed du segment pour l'animation
    start = new AnimatedPoint(segment.start, segment.seedM);
    end = new AnimatedPoint(segment.end, segment.seedM);
  }
  
  void update() {
    start.update();
    end.update();
  }
  
  PVector getAnimatedDirection() {
    return PVector.sub(end.animated, start.animated);
  }
}

void drawLine(Line line) {
  // Crée ou met à jour les segments animés si nécessaire
  if (line.animatedSegments == null) {
    line.animatedSegments = new ArrayList<AnimatedSegment>();
    // Plus besoin de seed additionnelle car on utilise segment.seedM
    for (Segment segment : line.segments) {
      // Correction : enlever le second paramètre seed
      line.animatedSegments.add(new AnimatedSegment(segment));
    }
  }
  
  // Met à jour les positions animées
  for (AnimatedSegment animSegment : line.animatedSegments) {
    animSegment.update();
  }
  
  // Dessine les segments animés
  for (int i = 0; i < line.segments.size(); i++) {
    Segment originalSegment = line.segments.get(i);
    AnimatedSegment animSegment = line.animatedSegments.get(i);
    
    // Utilise la valeur du slider pour l'incrément
    originalSegment.seedM = originalSegment.seedM - seedIncrement;
    
    // Dessiner les tiges avec les positions animées
    stroke(25, 25, 25);
    strokeWeight(3);
    line(animSegment.start.animated.x, animSegment.start.animated.y, 
         animSegment.end.animated.x, animSegment.end.animated.y);
         
    // Dessine les feuilles avec la position et direction animées
    if (originalSegment.gdFirst%2==0) {
      drawLeafSVG(originalSegment, animSegment, true);
      drawLeafSVG(originalSegment, animSegment, false);
    } else {
      drawLeafSVG(originalSegment, animSegment, false);
      drawLeafSVG(originalSegment, animSegment, true);
    }
  }
}

void drawLeafSVG(Segment originalSegment, AnimatedSegment animSegment, boolean isLeft) {
  int shape = isLeft ? originalSegment.nShapeL : originalSegment.nShapeR;
  if (esquisse) {
    stroke(0, 255, 0); // vert
    strokeWeight(2);
    pushMatrix();
    translate(animSegment.start.animated.x, animSegment.start.animated.y);
    // Utilise la direction animée
    PVector animDirection = animSegment.getAnimatedDirection();
    rotate(animDirection.heading());
    translate(animDirection.mag(), 0);
    float n = (noise(originalSegment.seedM) * (rotMax-rotMin))+rotMin;
    if (isLeft) {
      rotate(- radians(n) - HALF_PI/2);
    } else {
      rotate(radians(n) + HALF_PI/2);
    }
    line(0, 0, originalSegment.fScale, 0);
    popMatrix();
  //} else {
  //  pushMatrix();
  //  translate(animSegment.start.animated.x, animSegment.start.animated.y);
  //  // Utilise la direction animée
  //  PVector animDirection = animSegment.getAnimatedDirection();
  //  rotate(animDirection.heading());
  //  translate(animDirection.mag(), 0);
  //  rotate(HALF_PI);
  //  if (!isLeft) {
  //    scale(1, -1);
  //    rotate(PI);
  //  }
  //  float n = (noise(originalSegment.seedM) * (rotMax-rotMin))+rotMin;
  //  rotate(radians(n));
  //  scale(vScaleG);
  //  translate(-svgShape[shape].width, -(svgShape[shape].height)/9*7);
  //  shape(svgShape[shape], 0, 0);
  //  popMatrix();
  //}
  } else {
    pushMatrix();
    translate(animSegment.start.animated.x, animSegment.start.animated.y);
    // Utilise la direction animée
    PVector animDirection = animSegment.getAnimatedDirection();
    rotate(animDirection.heading());
    translate(animDirection.mag(), 0);
    rotate(HALF_PI);
    if (!isLeft) {
      scale(1, -1);
      rotate(PI);
    }
    float n = (noise(originalSegment.seedM) * (rotMax-rotMin))+rotMin;
    rotate(radians(n));

      // Vérifie si c'est le premier ou dernier segment pour la taille
    boolean isFirstOrLast = false;
    if (currentLine != null && originalSegment == currentLine.segments.get(0)) {
        isFirstOrLast = true;
    } else if (!allLines.isEmpty()) {
        Line currentLineRef = allLines.get(allLines.size()-1);
        isFirstOrLast = (originalSegment == currentLineRef.segments.get(0) || 
                        originalSegment == currentLineRef.segments.get(currentLineRef.segments.size()-1));
    }
    float finalScale = isFirstOrLast ? vScaleG * SCALE_DEBUT_FIN : vScaleG;
      
    scale(finalScale);

    translate(-svgShape[shape].width, -(svgShape[shape].height)/9*7);
    shape(svgShape[shape], 0, 0);
    popMatrix();
}
}


void draw() {
  if (clearScreen) { // écran vide - invite DragnDrop
    background(BACKGROUND);
    textAlign(CENTER, CENTER);
    fill(50);
    text(message, width/2, height/2);
  } else { // avec un tracé
    background(255);
    // nom du fichier svg
    if (recordSVG) {
      beginRecord(SVG, "drawing_" + year() + month() + day() + hour() + minute() + second() + ".svg");
    }
    for (Line line : allLines) {
      drawLine(line);
    }
    if (isDrawing && currentLine != null) {
      drawLine(currentLine);
    }
    // fin enregistrement du svg
    if (recordSVG) {
      endRecord();
      recordSVG = false;
      println("SVG enregistré.");
    }
    if (recordVideo) {
      // Mise à jour du slider
      progressImg.show();
      progressImg.setValue(compteurImg);
      // Mise à jour de la valeur (simulation d'une progression)
      if (compteurImg < MAX_COUNTER_IMG) {
        // Met à jour le label
        progressImg.setLabel(String.format("Enregistrement de l'image "+compteurImg+"/"+MAX_COUNTER_IMG));
        ;
        saveFrame("sequences/drawing_"+ compteurImg +".png");
        //incremente compteur img
        compteurImg += 1; // Vitesse de progression
      } else {
        recordVideo = false;
        compteurImg = 0;
        progressImg.hide();
        println("fin de séquence");
      }
    }
  }
}

/* SOURIS */
void mousePressed() {
  if (mouseY > 32 && mouseY < height-40) {
    isDrawing = true;
    clearScreen = false;
    afficheInterface();
    currentLine = new Line();
    PVector startPoint = new PVector(mouseX, mouseY);
    currentLine.addSegment(startPoint, startPoint.copy());
    currentLine.animatedSegments = new ArrayList<AnimatedSegment>();
    // Utilise la seed du segment pour l'animation
    currentLine.animatedSegments.add(new AnimatedSegment(currentLine.segments.get(0)));
  }
}

void mouseDragged() {
  if (isDrawing && currentLine != null) {
    Segment lastSegment = currentLine.segments.get(currentLine.segments.size() - 1);
    PVector currentPos = new PVector(mouseX, mouseY);
    float distance = PVector.dist(lastSegment.end, currentPos);
    
    if (distance >= minDistance) {
      PVector newStart = lastSegment.end.copy();
      currentLine.addSegment(newStart, currentPos);
      
      // Utilise la seed du nouveau segment pour l'animation
      AnimatedSegment newAnimSegment = new AnimatedSegment(
        currentLine.segments.get(currentLine.segments.size() - 1)
      );
      
      if (currentLine.animatedSegments.size() > 0) {
        AnimatedSegment prevAnimSegment = currentLine.animatedSegments.get(currentLine.animatedSegments.size() - 1);
        newAnimSegment.start = prevAnimSegment.end;
      }
      
      currentLine.animatedSegments.add(newAnimSegment);
      
      //if (currentLine.segments.size() == 2) {
      //  PVector direction = PVector.sub(currentPos, newStart);
        
      //  Segment firstSegment = currentLine.segments.get(0);
      //  firstSegment.direction = direction.copy();
      //  // Déplace le point de départ au lieu du point d'arrivée
      //  firstSegment.start = firstSegment.end.copy().sub(direction.setMag(minDistance));
      //  firstSegment.scale = .15; // La moitié de 0.3
        
      //  AnimatedSegment firstAnimSegment = currentLine.animatedSegments.get(0);
      //  firstAnimSegment.originalSegment.direction = direction.copy();
      //  // Mise à jour correspondante du point animé
      //  firstAnimSegment.start.original = firstAnimSegment.end.original.copy().sub(direction.setMag(minDistance));
      //  firstAnimSegment.start.animated = firstAnimSegment.start.original.copy();
      //}
      if (currentLine.segments.size() == 2) {
        PVector direction = PVector.sub(currentPos, newStart);
        
        Segment firstSegment = currentLine.segments.get(0);
        firstSegment.direction = direction.copy();
        firstSegment.start = firstSegment.end.copy().sub(direction.setMag(minDistance));
        firstSegment.scale = .15; // La moitié de 0.3
        firstSegment.fScale = random(30, 50); // Ajout des propriétés pour les feuilles
        firstSegment.gdFirst = round(random(1));
        firstSegment.nShapeL = int(random(svgShape.length));
        firstSegment.nShapeR = int(random(svgShape.length));
        
        AnimatedSegment firstAnimSegment = currentLine.animatedSegments.get(0);
        firstAnimSegment.originalSegment.direction = direction.copy();
        firstAnimSegment.start.original = firstAnimSegment.end.original.copy().sub(direction.setMag(minDistance));
        firstAnimSegment.start.animated = firstAnimSegment.start.original.copy();
      }
    }
  }
}

void mouseReleased() {
  if (mouseY > 32 && mouseY < height-40) {
    isDrawing = false;
    if (currentLine != null && currentLine.segments.size() > 1) {
      // Assure que le dernier segment a une longueur minimale
      Segment lastSegment = currentLine.segments.get(currentLine.segments.size()-1);
      PVector direction = PVector.sub(lastSegment.end, lastSegment.start);
      if (direction.mag() < minDistance) {
        lastSegment.end = lastSegment.start.copy().add(direction.setMag(minDistance));
        
        // Met à jour le segment animé correspondant
        AnimatedSegment lastAnimSegment = currentLine.animatedSegments.get(currentLine.animatedSegments.size()-1);
        lastAnimSegment.end.original = lastAnimSegment.start.original.copy().add(direction.setMag(minDistance));
        lastAnimSegment.end.animated = lastAnimSegment.end.original.copy();
      }
      
      // modifie le dernier élément
      lastSegment.angle = 45;
      lastSegment.scale /= 1.5;
      
      allLines.add(currentLine);
    }
    
    // reset les valeurs pour nouvelle ligne
    nLines++;
    currentLine = null;
  }
}

void keyPressed() {
  switch(key) {
  case 'N':
  case 'n':
    // efface l'écran
    allLines.clear();
    // reinit messag DRAGnDrop
    message = messageAcc;
    cacheInterface();
    clearScreen = true;
    break;
  case 'S':
  case 's':
    recordSVG = true;
    saveJSONStructure("drawing_" + year() + month() + day() + hour() + minute() + second());
  case 'v':
  case 'V':
    recordVideo = true;
    break;
  case 'e':
  case 'E':
    esquisseToggle.toggle();
    break;
  }
}

/* utilitaires */
void afficheInterface() {
  seedSlider.show();
  saveJ.show();
  saveSeq.show();
  scaleG.show();
  ampAnimPoint.show();
}
void cacheInterface() {
  seedSlider.hide();
  saveJ.hide();
  saveSeq.hide();
  scaleG.hide();
  ampAnimPoint.hide();
}

/* sauvegarde de l'ArrayList en JSON */
void saveJSON() { // pour le bouton ControlP5
  saveJSONStructure("drawing_" + year() + month() + day() + hour() + minute() + second());
}

void saveJSONStructure(String filename) {
  JSONArray json = new JSONArray();

  // Création de l'objet principal qui contiendra settings et lines
  JSONObject mainJson = new JSONObject();

  // Création de l'objet settings
  JSONObject settings = new JSONObject();
  settings.setFloat("seedIncrement", seedIncrement); // Remplacez seedIncrement par votre valeur
  settings.setInt("rotMax", rotMax); // Remplacez rotMax par votre valeur
  settings.setInt("rotMin", rotMin); // Remplacez rotMin par votre valeur
  settings.setFloat("vScaleG", vScaleG); //

  // Ajout des settings dans l'objet principal
  mainJson.setJSONObject("settings", settings);

  // Création du tableau de lignes
  JSONArray linesArray = new JSONArray();
  for (Line line : allLines) {
    JSONObject lineJson = new JSONObject();
    JSONArray segmentsJson = new JSONArray();
    for (Segment segment : line.segments) {
      JSONObject segmentJson = new JSONObject();
      segmentJson.setJSONArray("start", new JSONArray().setFloat(0, segment.start.x).setFloat(1, segment.start.y));
      segmentJson.setJSONArray("end", new JSONArray().setFloat(0, segment.end.x).setFloat(1, segment.end.y));
      segmentJson.setJSONArray("direction", new JSONArray().setFloat(0, segment.direction.x).setFloat(1, segment.direction.y));
      segmentJson.setFloat("angle", segment.angle);
      segmentJson.setFloat("scale", segment.scale);
      segmentJson.setInt("gdFirst", segment.gdFirst);
      segmentJson.setInt("nShapeL", segment.nShapeL);
      segmentJson.setInt("nShapeR", segment.nShapeR);
      segmentJson.setFloat("seed", segment.seed);
      segmentsJson.append(segmentJson);
    }
    lineJson.setJSONArray("segments", segmentsJson);
    linesArray.append(lineJson);
  }

  // Ajout du tableau de lignes dans l'objet principal
  mainJson.setJSONArray("lines", linesArray);

  // Sauvegarde du fichier
  saveJSONObject(mainJson, "data/"+filename+".json");
  if (!saveOnExit) {
    saveFrame("data/"+filename+".png");
  }
  println("Fichier JSON sauvegardé avec succès.");
}

/* CHARGEMENT de l'ArrayList depuis JSON */

ArrayList<Line> loadJSONStructure(String filename) {
  ArrayList<Line> lines = new ArrayList<Line>();

  //si chargement en DRAGNDROP après une erreur
  if (clearScreen) {
    clearScreen = false;
  }
  // Charger le fichier JSON principal
  JSONObject mainJson = loadJSONObject(filename);
  if (mainJson == null) {
    println("Impossible de charger le fichier JSON : " + filename);
    return lines;
  }
  // Récupérer et appliquer les settings
  JSONObject settings = mainJson.getJSONObject("settings");
  seedIncrement = settings.getFloat("seedIncrement");
  seedSlider.setValue(settings.getFloat("seedIncrement"));
  rotMax = settings.getInt("rotMax");
  rotMin = settings.getInt("rotMin");
  println("Settings chargés : seedIncrement = " + seedIncrement +
    ", rotMax = " + rotMax +
    ", rotMin = " + rotMin);
  try { // si pas présent evite le plantage
    scaleG.setValue(settings.getFloat("vScaleG"));
  }
  catch (Exception e) {
  }

  // Récupérer le tableau de lignes
  JSONArray linesArray = mainJson.getJSONArray("lines");

  // Pour chaque ligne dans le JSON
  for (int i = 0; i < linesArray.size(); i++) {
    JSONObject lineJson = linesArray.getJSONObject(i);
    Line line = new Line();

    // Récupérer les segments
    JSONArray segmentsJson = lineJson.getJSONArray("segments");
    for (int j = 0; j < segmentsJson.size(); j++) {
      JSONObject segmentJson = segmentsJson.getJSONObject(j);

      JSONArray startJson = segmentJson.getJSONArray("start");
      PVector start = new PVector(startJson.getFloat(0), startJson.getFloat(1));

      JSONArray endJson = segmentJson.getJSONArray("end");
      PVector end = new PVector(endJson.getFloat(0), endJson.getFloat(1));

      JSONArray directionJson = segmentJson.getJSONArray("direction");
      PVector direction = new PVector(directionJson.getFloat(0), directionJson.getFloat(1));

      Segment segment = new Segment(start, end);
      segment.direction = direction;
      segment.angle = segmentJson.getFloat("angle");
      segment.scale = segmentJson.getFloat("scale");
      segment.gdFirst = segmentJson.getInt("gdFirst");
      segment.nShapeL = segmentJson.getInt("nShapeL");
      segment.nShapeR = segmentJson.getInt("nShapeR");
      segment.seed = segmentJson.getFloat("seed");
      segment.seedM = segmentJson.getFloat("seed");

      line.segments.add(segment);
    }
    lines.add(line);
  }
  println("Fichier JSON chargé avec succès : " + filename);
  return lines;
}

/* sélection du fichier json */
void loadJSON() {
  selectInput("Sélectionnez un fichier JSON", "fileSelected", new File(sketchPath("data")));
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Aucun fichier sélectionné.");
  } else {
    println("Fichier sélectionné : " + selection.getAbsolutePath());
    // apple le chargement du JSON
    allLines = loadJSONStructure(selection.getAbsolutePath());
    // MàJ des Drapos
    fileLoaded = true;
    clearScreen = false;
    // affiche interface
    afficheInterface();
  }
}

/* Mode Esquisse (checkbox) */
void esquisse(boolean value) {
  esquisse = value;
  println("Mode esquisse : " + (esquisse ? "activé" : "désactivé"));
}

/* GESTION du DRAGNDROP */
void handleDropEvent(DropEvent theDropEvent) {
  if (theDropEvent.isFile()) {
    File myFile = theDropEvent.file();
    println("\nisDirectory ? " + myFile.isDirectory() + "  /  isFile ? " + myFile.isFile());
    if (myFile.isFile()) {
      println(" file()\t" + theDropEvent.filePath());
      currentFileName = theDropEvent.filePath();
      // Vérifier si le fichier est un JSON valide
      if (isValidJSON(myFile)) {
        afficheInterface();
        // reset couleur de fond
        BACKGROUND = #F2F2F2;
        // chargement du fichier JSON
        allLines = loadJSONStructure(currentFileName);
        fileLoaded = true;
      }
    } else if (myFile.isDirectory()) {
      BACKGROUND = #FFAAAA; // Rouge si c'est un dossier
    }
  }
}
// vérifie que le fichier JSON est valide
boolean isValidJSON(File file) {
  try {
    JSONObject mainJson = loadJSONObject(file);
    return true;
  }
  catch (Exception e) {
    BACKGROUND = #FFAAAA;
    message = messageNonJSON;
    // Si une exception est levée, le fichier n'est pas un JSON valide
    println("ce n'est pas un fichier JSON valide");
    return false;
  }
}

/*  sauvegarde on exit */
void exit() {
  if (allLines.size()>0) { // seulement si il y a un dessin
    saveOnExit = true;
    println("saveOnExit");
    saveJSONStructure("saveOnExit_" + year() + month() + day() + hour() + minute() + second());
  } else {
    println("exiting without saving");
  }
  super.exit();
}

/* Fonction de callback pour les messages MIDI */
/* à mettre à jour en fonction de l'interface */
//void controllerChange(int channel, int number, int value) {
//  // Si c'est le contrôleur que nous voulons (port 58)
//  if (number == midiPort) {
//    // Conversion de la valeur MIDI (0-127) vers notre plage de valeurs
//    float normalized = value / 127.0; // normalise entre 0 et 1
//    float newValue = map(normalized, 0, 1, midiMin, midiMax);

//    // Met à jour la valeur de seedIncrement
//    seedIncrement = newValue;
//    println(newValue);
//    // Met à jour le slider ControlP5
//    seedSlider.setValue(newValue);
//  }
//}
