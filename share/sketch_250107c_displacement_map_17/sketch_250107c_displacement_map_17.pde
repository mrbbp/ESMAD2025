/*   enregistrement en x2
 ajout d'un offset du motif
 sauvegarde du dernier reglage et chargement au lancement
 */

import controlP5.*;
import drop.*;

ControlP5 cp5;
float angleDeg = 50;
float spacing = 25;
float amplitude = 50;
boolean showPattern = false;
float rotationSpeed = 0;
float hyperParam = 1;
boolean useDoubleAxis = false;
boolean useHyperbolic = true;
boolean isSaving = false;
int saveTimeout = 0;
int SAVE_DELAY = 1000; // 1 seconde
float offset = 0;
boolean isResizing = false;

// Ajouter au début du fichier
JSONObject settings;
String settingsPath = "data/settings.json";

PImage img;
PGraphics displacementMap;
float imgX, imgY, imgW, imgH;
int sketchWidth, sketchHeight;
String originalFileName = "";
boolean imageLoaded = false;
SDrop drop;

void settings() {
  sketchWidth = 1000;
  sketchHeight = 1000;
  size(sketchWidth, sketchHeight);
}

//void setup() {
//  drop = new SDrop(this);
//  displacementMap = createGraphics(width, height);
//  setupControlP5();

//  imgW = width;
//  imgH = height;
//  imgX = 0;
//  imgY = 0;

//  displacementMap = createGraphics(width, height);

//  cp5 = new ControlP5(this);
//  cp5.addSlider("currentAngle")
//    .setPosition(20, 20)
//    .setRange(0, 180)
//    .setSize(200, 20)
//    .setValue(angleDeg)
//    .setLabel("Angle");

//  cp5.addSlider("spacing")
//    .setPosition(20, 50)
//    .setRange(5, 100)
//    .setSize(200, 20)
//    .setValue(spacing);

//  cp5.addSlider("amplitude")
//    .setPosition(20, 80)
//    .setRange(0, 100)
//    .setSize(200, 20)
//    .setValue(amplitude);

//  cp5.addToggle("showPattern")
//    .setPosition(20, 110)
//    .setSize(50, 20)
//    .setValue(false);

//  cp5.addBang("saveImage")
//    .setPosition(20, 180)
//    .setSize(50, 20)
//    .setLabel("Save");

//  cp5.addSlider("hyperParam")
//    .setPosition(20, 150)
//    .setRange(0.1, 10)
//    .setSize(200, 20)
//    .setValue(1)
//    .setLabel("Hyperbole k");

//  cp5.addToggle("useDoubleAxis")
//    .setPosition(90, 110)
//    .setSize(50, 20)
//    .setLabel("Double Axis")
//    .setValue(false);

//  cp5.addToggle("useHyperbolic")
//    .setPosition(160, 110)
//    .setSize(50, 20)
//    .setLabel("Hyperbolic");

//  cp5.addSlider("offset")
//    .setPosition(20, 220)
//    .setRange(0, 1)
//    .setSize(200, 20)
//    .setValue(0)
//    .setLabel("Pattern Offset");

//  loadSettings();
//  setupControlP5();
//  updateControlsFromSettings();
//}

void setup() {
  drop = new SDrop(this);
  displacementMap = createGraphics(width, height);
  
  imgW = width;
  imgH = height;
  imgX = 0;
  imgY = 0;
  
  displacementMap = createGraphics(width, height);
  
  setupControlP5();
  loadSettings();
  updateControlsFromSettings();
}

float currentAngle = 0;

void draw() {
  if (!imageLoaded) {
    background(0);
    fill(255);
    textAlign(CENTER, CENTER);
    text("Drop an image file (jpg, png, gif)", width/2, height/2);
    return;
  }
  if (isSaving && millis() > saveTimeout) {
    isSaving = false;
  }

  currentAngle = (currentAngle + rotationSpeed) % 360;
  angleDeg = currentAngle;

  background(0);
  displacementMap.beginDraw();
  displacementMap.loadPixels();
  float angle = radians(angleDeg);
  float bandWidth = (spacing * 2) / abs(cos(angle));
  float offsetAmount = (offset * bandWidth) % bandWidth;

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float value = ((y - height/2.0) * cos(angle) - ((x + offsetAmount) - width/2.0) * sin(angle)) / spacing;
      float value2 = ((y - height/2.0) * cos(angle + PI/2) - ((x + offsetAmount) - width/2.0) * sin(angle + PI/2)) / spacing;

      value = (value + (width + height)/spacing) % 2.0;
      value2 = (value2 + (width + height)/spacing) % 2.0;
      if (value > 1.0) value = 2.0 - value;
      if (value2 > 1.0) value2 = 2.0 - value2;

      float finalValue = useDoubleAxis ? value * value2 : value;

      if (useHyperbolic) {
        finalValue = 1.0 / (1.0 + hyperParam * finalValue);
      } else {
        finalValue = pow(finalValue, hyperParam);
      }

      displacementMap.pixels[y * width + x] = color(finalValue * 255);
    }
  }
  displacementMap.updatePixels();
  displacementMap.endDraw();

  if (showPattern) {
    image(displacementMap, 0, 0);
  } else {
    image(img, imgX, imgY);
    loadPixels();
    img.loadPixels();

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        if (x >= imgX && x < imgX + imgW && y >= imgY && y < imgY + imgH) {
          float displaceAmount = brightness(displacementMap.get(x, y)) / 255.0 * amplitude;
          int sourceX = constrain(int(x - imgX + displaceAmount), 0, (int)imgW-1);
          int sourceY = int(y - imgY);
          pixels[y * width + x] = img.pixels[sourceY * (int)imgW + sourceX];
        }
      }
    }
    updatePixels();
  }
}



void dropEvent(DropEvent theDropEvent) {
  if (theDropEvent.isFile() &&
    (theDropEvent.file().getName().toLowerCase().endsWith(".jpg") ||
    theDropEvent.file().getName().toLowerCase().endsWith(".jpeg") ||
    theDropEvent.file().getName().toLowerCase().endsWith(".png") ||
    theDropEvent.file().getName().toLowerCase().endsWith(".gif"))) {

    img = loadImage(theDropEvent.filePath());
    originalFileName = theDropEvent.file().getName();
    originalFileName = originalFileName.substring(0, originalFileName.lastIndexOf('.'));

    float ratio = (float)img.width / img.height;
    surface.setSize((int)sketchWidth, (int)(sketchWidth/ratio));

    imgW = width;
    imgH = height;
    imgX = 0;
    imgY = 0;

    img.resize(width, height);
    displacementMap = createGraphics(width, height);
    imageLoaded = true;
  }
}

void setupControlP5() {
  cp5 = new ControlP5(this);
  cp5.addSlider("currentAngle")
    .setPosition(20, 20)
    .setRange(0, 180)
    .setSize(200, 20)
    .setValue(angleDeg)
    .setLabel("Angle");

  cp5.addSlider("spacing")
    .setPosition(20, 50)
    .setRange(5, 100)
    .setSize(200, 20)
    .setValue(spacing);

  cp5.addSlider("amplitude")
    .setPosition(20, 80)
    .setRange(0, 100)
    .setSize(200, 20)
    .setValue(amplitude);

  cp5.addToggle("showPattern")
    .setPosition(20, 110)
    .setSize(50, 20)
    .setValue(false);

  cp5.addBang("saveImage")
    .setPosition(20, 210)
    .setSize(50, 20)
    .setLabel("Save");

  cp5.addSlider("hyperParam")
    .setPosition(20, 150)
    .setRange(0.1, 10)
    .setSize(200, 20)
    .setValue(1)
    .setLabel("Hyperbole k");

  cp5.addToggle("useDoubleAxis")
    .setPosition(95, 110)
    .setSize(50, 20)
    .setLabel("Double Axis");

  cp5.addToggle("useHyperbolic")
    .setPosition(170, 110)
    .setSize(50, 20)
    .setLabel("Hyperbolic");

  cp5.addSlider("offset")
    .setPosition(20, 180)
    .setRange(0, 1)
    .setSize(200, 20)
    .setValue(0)
    .setLabel("Pattern Offset");
}


void keyPressed() {
  if (key == 's' || key == 'S') {
    saveImage();
  }
}
void generateDisplacementMap(PGraphics dm, int w, int h) {
  float scaleW = (float)w / width;
  dm.beginDraw();
  dm.loadPixels();
  float angle = radians(angleDeg);
  float bandWidth = (spacing * 2 * scaleW) / abs(cos(angle));
  float offsetAmount = (offset * bandWidth) % bandWidth;

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      float value = ((y - h/2.0) * cos(angle) - ((x + offsetAmount) - w/2.0) * sin(angle)) / (spacing * 2);
      float value2 = ((y - h/2.0) * cos(angle + PI/2) - ((x + offsetAmount) - w/2.0) * sin(angle + PI/2)) / (spacing * 2);
      
      value = (value + (w + h)/(spacing * 2)) % 2.0;
      value2 = (value2 + (w + h)/(spacing * 2)) % 2.0;
      if (value > 1.0) value = 2.0 - value;
      if (value2 > 1.0) value2 = 2.0 - value2;

      float finalValue = useDoubleAxis ? value * value2 : value;
      
      if (useHyperbolic) {
        finalValue = 1.0 / (1.0 + hyperParam * finalValue);
      } else {
        finalValue = pow(finalValue, hyperParam);
      }
      
      dm.pixels[y * w + x] = color(finalValue * 255);
    }
  }
  dm.updatePixels();
  dm.endDraw();
}

void applyDisplacementAndSave(PGraphics output, PImage source, PGraphics dm) {
  output.beginDraw();
  output.loadPixels();
  output.colorMode(ARGB, 255);
  source.loadPixels();
  float scaleW = (float)output.width / width;
  
  for (int x = 0; x < output.width; x++) {
    for (int y = 0; y < output.height; y++) {
      float displaceAmount = brightness(dm.get(x, y)) / 255.0 * amplitude * scaleW;
      int sourceX = constrain(int(x + displaceAmount), 0, output.width-1);
      output.pixels[y * output.width + x] = source.pixels[y * output.width + sourceX];
    }
  }
  
  output.updatePixels();
  output.endDraw();
  
  String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  output.save("displacement_" + originalFileName + "_" + timestamp + "_HD.png");
}

void saveImage() {
  if (isSaving) return;
  isSaving = true;
  saveTimeout = millis() + SAVE_DELAY;
  
  int hdWidth = width * 2;
  int hdHeight = height * 2;
  
  PGraphics hdDisplacementMap = createGraphics(hdWidth, hdHeight);
  PGraphics hdOutput = createGraphics(hdWidth, hdHeight);
  PImage hdImg = img.copy();
  hdImg.resize(hdWidth, hdHeight);
  
  generateDisplacementMap(hdDisplacementMap, hdWidth, hdHeight);
  applyDisplacementAndSave(hdOutput, hdImg, hdDisplacementMap);
}

void loadSettings() {
  try {
    settings = loadJSONObject(settingsPath);
    angleDeg = settings.getFloat("angle", 50);
    spacing = settings.getFloat("spacing", 25);
    amplitude = settings.getFloat("amplitude", 50);
    showPattern = settings.getBoolean("showPattern", false);
    hyperParam = settings.getFloat("hyperParam", 1);
    useDoubleAxis = settings.getBoolean("useDoubleAxis", false);
    useHyperbolic = settings.getBoolean("useHyperbolic", true);
    offset = settings.getFloat("offset", 0);
  }
  catch (Exception e) {
    println("Pas de fichier de configuration trouvé, utilisation des valeurs par défaut");
  }
}

void saveSettings() {
  settings = new JSONObject();
  settings.setFloat("angle", angleDeg);
  settings.setFloat("spacing", spacing);
  settings.setFloat("amplitude", amplitude);
  settings.setBoolean("showPattern", showPattern);
  settings.setFloat("hyperParam", hyperParam);
  settings.setBoolean("useDoubleAxis", useDoubleAxis);
  settings.setBoolean("useHyperbolic", useHyperbolic);
  settings.setFloat("offset", offset);
  saveJSONObject(settings, settingsPath);
}

void updateControlsFromSettings() {
  cp5.getController("currentAngle").setValue(angleDeg);
  cp5.getController("spacing").setValue(spacing);
  cp5.getController("amplitude").setValue(amplitude);
  cp5.getController("showPattern").setValue(showPattern ? 1 : 0);
  cp5.getController("hyperParam").setValue(hyperParam);
  cp5.getController("useDoubleAxis").setValue(useDoubleAxis ? 1 : 0);
  cp5.getController("useHyperbolic").setValue(useHyperbolic ? 1 : 0);
  cp5.getController("offset").setValue(offset);
}

void exit() {
  saveSettings();
  super.exit();
}
