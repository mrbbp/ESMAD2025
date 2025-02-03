import controlP5.*;

PImage img;
PGraphics buffer;
ControlP5 cp5;
int bandWidth = 50;  // Largeur initiale de chaque bande
int step = 10;       // Déplacement initial entre chaque bande dans l'image source
float bandGrowth = 0;  // Facteur d'augmentation de la taille des bandes
boolean needsUpdate = true;

void setup() {
  size(800, 600);
  img = loadImage("vsassen.jpg");
  img.resize(width, 0);  // Redimensionne l'image à la largeur de l'écran
  buffer = createGraphics(width, height);
  
  cp5 = new ControlP5(this);
  
  cp5.addSlider("bandWidth")
     .setPosition(10, 10)
     .setRange(1, 100)
     .setValue(bandWidth)
     .setSize(200, 20)
     .addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent event) {
         if (event.getAction() == ControlP5.ACTION_BROADCAST) needsUpdate = true;
       }
     });
     
  cp5.addSlider("step")
     .setPosition(10, 40)
     .setRange(1, 50)
     .setValue(step)
     .setSize(200, 20)
     .addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent event) {
         if (event.getAction() == ControlP5.ACTION_BROADCAST) needsUpdate = true;
       }
     });
     
  cp5.addSlider("bandGrowth")
     .setPosition(10, 70)
     .setRange(0, 6)
     .setValue(0)
     .setSize(200, 20)
     .setNumberOfTickMarks(7)
     .setLabel("Band Growth")
     .addCallback(new CallbackListener() {
       public void controlEvent(CallbackEvent event) {
         if (event.getAction() == ControlP5.ACTION_BROADCAST) {
           updateBandGrowth();
           needsUpdate = true;
         }
       }
     });
     
  cp5.addButton("saveImage")
     .setPosition(10, 100)
     .setSize(100, 20)
     .setLabel("Sauvegarder");
}

void draw() {
  if (needsUpdate) {
    updateBuffer();
    needsUpdate = false;
  }
  
  image(buffer, 0, 0);
  
  // Dessiner l'interface par-dessus
  cp5.draw();
}

void updateBuffer() {
  buffer.beginDraw();
  buffer.background(0);
  
  int sourceX = 0;  // Position de départ dans l'image source
  float currentBandWidth = bandWidth;
  float lastBandWidth = bandWidth;
  
  for (int x = 0; x < width; x += int(lastBandWidth)) {
    buffer.copy(img, sourceX, 0, int(currentBandWidth), img.height, x, 0, int(currentBandWidth), height);
    sourceX += step;
    lastBandWidth = currentBandWidth;
    currentBandWidth += bandWidth * bandGrowth;
    
    if (sourceX + int(currentBandWidth) > img.width) {
      sourceX = 0;
    }
  }
  
  buffer.endDraw();
}

void updateBandGrowth() {
  float[] growthValues = {0, 1/20.0, 1/10.0, 1/8.0, 1/5.0, 1/4.0, 1/3.0, 1/2.0};
  bandGrowth = growthValues[int(cp5.getController("bandGrowth").getValue())];
}

void saveImage() {
  PGraphics saveBuffer = createGraphics(width, height);
  saveBuffer.beginDraw();
  saveBuffer.image(buffer, 0, 0);
  saveBuffer.endDraw();
  saveBuffer.save("sliced_image_" + year() + month() + day() + "_" + hour() + minute() + second() + ".png");
}
