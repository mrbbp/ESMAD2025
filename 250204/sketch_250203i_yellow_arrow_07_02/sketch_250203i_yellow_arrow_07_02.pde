import processing.svg.*;

PShape arrow;
float smallCircleSize;
boolean recordSVG = false;

void setup() {
  size(800, 800);
  arrow = loadShape("../medias/yellow_arrow.svg");
  smallCircleSize = width * 0.05;
}

void draw() {
  if(recordSVG) {
    beginRecord(SVG, "export.svg");
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
    println("SVG saved");
  }
}

void keyPressed() {
  if(key == 'v') {
    recordSVG = true;
  }
}
