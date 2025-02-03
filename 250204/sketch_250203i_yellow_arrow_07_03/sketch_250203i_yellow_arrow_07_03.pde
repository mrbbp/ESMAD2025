/*
  save an image in png ('p'), sequence of 100 images ('s') or one svg ('v')
*/
import processing.svg.*;

PShape arrow;
float smallCircleSize;
boolean recordSVG = false;
boolean isRecording = false;
int sequenceCounter = 0;
int singleCounter = 0;
int svgCounter = 0;

void setup() {
  size(800, 800);
  arrow = loadShape("../medias/yellow_arrow.svg");
  smallCircleSize = width * 0.05;
}

void draw() {
  if(recordSVG) {
    beginRecord(SVG, "svg/export-" + nf(svgCounter, 4) + ".svg");
  }
  
  background(220);
  
  stroke(180);
  for(int i = 0; i <= 800; i += 80) {
    line(i, 0, i, height);
    line(0, i, width, i);
  }
  
  float w = width/10 * 0.5;
  float h = height/10 * 0.5;
  
  float angle = atan2(mouseY - height/2, mouseX - width/2);
  float circleX = width/2 + cos(angle) * width/2;
  float circleY = height/2 + sin(angle) * height/2;
  
  for(int y = 0; y < 10; y++) {
    for(int x = 0; x < 10; x++) {
      float centerX = x*(width/10) + width/20;
      float centerY = y*(height/10) + height/20;
      float arrowAngle = atan2(circleY - centerY, circleX - centerX);
      
      pushMatrix();
      translate(centerX, centerY);
      rotate(arrowAngle + radians(-45));
      shape(arrow, -w/2, -h/2, w, h);
      popMatrix();
    }
  }
  
  noFill();
  stroke(0);
  ellipse(width/2, height/2, width, height);
  ellipse(circleX, circleY, smallCircleSize, smallCircleSize);
  
  if(recordSVG) {
    endRecord();
    recordSVG = false;
    svgCounter++;
    println("SVG " + (svgCounter-1) + " saved");
  }
  
  if(isRecording && sequenceCounter < 100) {
    saveFrame("sequence/frame-" + nf(sequenceCounter, 4) + ".png");
    sequenceCounter++;
    if(sequenceCounter >= 100) {
      isRecording = false;
      println("Sequence recording complete");
    }
  }
}

void keyPressed() {
  if(key == 'p') {
    saveFrame("single/image-" + nf(singleCounter, 4) + ".png");
    println("Image " + singleCounter + " saved");
    singleCounter++;
  }
  else if(key == 's' && !isRecording) {
    isRecording = true;
    sequenceCounter = 0;
    println("Starting sequence recording");
  }
  else if(key == 'v') {
    recordSVG = true;
  }
}
