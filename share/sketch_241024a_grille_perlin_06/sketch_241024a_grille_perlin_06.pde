/*
  v2:
  - ajout d'une image de réference qui se déforme
  - modif des valeur min et max des colonnes/lignes
  v3:
  - bascule image/quadrillage
  v4:
  - augmente le constrate dans le bruit
  v5:
  - sauvegarde des reglages avant de quitter et rechargement au démarrage
  V6:
  - augmentation de la taille du bruit pour avoir + de points contrastés
  - diminution de la vitesse de déplacement dans le bruit
*/
import controlP5.*;
import java.io.File;

ControlP5 cp5;
PImage sourceImage;
float baseSize;
float noiseScale = 0.5; // Valeur de base augmentée pour plus de variations
float timeOffset = 0;
float animationSpeed = 0.002; // Nouvelle variable pour contrôler la vitesse
float minSize = 0.01;
float maxSize = 4.0;
float contrastAmount = 2.0;
boolean showImage = true;
String settingsPath = "settings.json";

float grille = 20;

float[] columnWidths = new float[int(grille)];
float[] rowHeights = new float[int(grille)];

void setup() {
  size(1200, 800);
  noStroke();
  
  sourceImage = loadImage("paysage.jpg");
  //sourceImage.resize(800, 800);
  
  baseSize = width / grille;
  
  cp5 = new ControlP5(this);
  
  cp5.addSlider("minSize")
     .setPosition(10, 10)
     .setSize(200, 20)
     .setRange(0.01, 1.0)
     .setValue(0.5)
     .setLabel("Taille Minimum");
     
  cp5.addSlider("maxSize")
     .setPosition(10, 40)
     .setSize(200, 20)
     .setRange(1.0, 4.0)
     .setValue(1.5)
     .setLabel("Taille Maximum");
     
  cp5.addSlider("noiseScale")
     .setPosition(10, 70)
     .setSize(200, 20)
     .setRange(0.1, 2.0) // Plage modifiée pour permettre plus de variations
     .setValue(0.5)
     .setLabel("Échelle du bruit");
     
  cp5.addSlider("contrastAmount")
     .setPosition(10, 100)
     .setSize(200, 20)
     .setRange(1.0, 5.0)
     .setValue(2.0)
     .setLabel("Contraste du bruit");
     
  cp5.addSlider("animationSpeed")
     .setPosition(10, 130)
     .setSize(200, 20)
     .setRange(0.0, 0.05)
     .setValue(0.002)
     .setLabel("Vitesse d'animation");
     
  cp5.addToggle("showImage")
     .setPosition(10, 160)
     .setSize(50, 20)
     .setValue(true)
     .setLabel("Image / Damier")
     .setMode(ControlP5.SWITCH);
     
  loadSettings();
}

void loadSettings() {
  File f = new File(dataPath(settingsPath));
  if (f.exists()) {
    JSONObject json = loadJSONObject(settingsPath);
    
    cp5.getController("minSize").setValue(json.getFloat("minSize"));
    cp5.getController("maxSize").setValue(json.getFloat("maxSize"));
    cp5.getController("noiseScale").setValue(json.getFloat("noiseScale"));
    cp5.getController("contrastAmount").setValue(json.getFloat("contrastAmount"));
    cp5.getController("animationSpeed").setValue(json.getFloat("animationSpeed"));
    cp5.getController("showImage").setValue(json.getBoolean("showImage") ? 1 : 0);
    
    minSize = json.getFloat("minSize");
    maxSize = json.getFloat("maxSize");
    noiseScale = json.getFloat("noiseScale");
    contrastAmount = json.getFloat("contrastAmount");
    animationSpeed = json.getFloat("animationSpeed");
    showImage = json.getBoolean("showImage");
  }
}

void saveSettings() {
  JSONObject json = new JSONObject();
  
  json.setFloat("minSize", cp5.getController("minSize").getValue());
  json.setFloat("maxSize", cp5.getController("maxSize").getValue());
  json.setFloat("noiseScale", cp5.getController("noiseScale").getValue());
  json.setFloat("contrastAmount", cp5.getController("contrastAmount").getValue());
  json.setFloat("animationSpeed", cp5.getController("animationSpeed").getValue());
  json.setBoolean("showImage", cp5.getController("showImage").getValue() == 1.0);
  
  saveJSONObject(json, "data/" + settingsPath);
}

void exit() {
  println("Sauvegarde des réglages...");
  saveSettings();
  super.exit();
}

float contrastNoise(float x, float y, float z) {
  float val = noise(x, y, z);
  val = val * 2 - 1;
  val = pow(abs(val), 1/contrastAmount) * sign(val);
  return val * 0.5 + 0.5;
}

float sign(float x) {
  return x > 0 ? 1 : (x < 0 ? -1 : 0);
}

void draw() {
  background(255);
  
  float totalWidth = 0;
  float totalHeight = 0;
  
  for (int i = 0; i < int(grille); i++) {
    float noiseValCol = contrastNoise(i * noiseScale * 2, 0, timeOffset);
    float noiseValRow = contrastNoise(0, i * noiseScale * 2, timeOffset);
    
    // Inversez minSize et maxSize dans map() pour un effet correct
    columnWidths[i] = baseSize * map(noiseValCol, 0, 1, maxSize, minSize);
    rowHeights[i] = baseSize * map(noiseValRow, 0, 1, maxSize, minSize);
    
    totalWidth += columnWidths[i];
    totalHeight += rowHeights[i];
}
  
  float scaleX = width / totalWidth;
  float scaleY = height / totalHeight;
  
  float y = 0;
  float sourceY = 0;
  float sourceCellHeight = sourceImage.height / grille;
  
  for (int j = 0; j < int(grille); j++) {
    float x = 0;
    float sourceX = 0;
    float sourceCellWidth = sourceImage.width / grille;
    float scaledRowHeight = rowHeights[j] * scaleY;
    
    for (int i = 0; i < int(grille); i++) {
      float scaledColumnWidth = columnWidths[i] * scaleX;
      
      if (showImage) {
        PImage tile = sourceImage.get(
          int(sourceX), 
          int(sourceY), 
          int(sourceCellWidth), 
          int(sourceCellHeight)
        );
        image(tile, x, y, scaledColumnWidth, scaledRowHeight);
      } else {
        if ((i + j) % 2 == 0) {
          fill(0);
        } else {
          fill(255);
        }
        rectMode(CORNER);
        rect(x, y, scaledColumnWidth, scaledRowHeight, 3);
      }
      
      x += scaledColumnWidth;
      sourceX += sourceCellWidth;
    }
    y += scaledRowHeight;
    sourceY += sourceCellHeight;
  }
  
  timeOffset += animationSpeed; // Utilisation de la vitesse d'animation contrôlable
}

void showImage(boolean value) {
  showImage = value;
}
