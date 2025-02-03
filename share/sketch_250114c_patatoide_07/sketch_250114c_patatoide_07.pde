/*
  - animation des points par timer + click ecran (regen anim)
 - declalage animation des points
 - anim ordre des points sens horaire
 - dessin des poignées + couleurs
 - gestion des angles des points pour le sens des poignées
 - les points opposés se répondent
 - calcule d'une surface constante entre chaque regeneration de points et ajustement des points
 -  calcule du barycentre du point (cercle jaune)
 */
import de.looksgood.ani.*;

int numPoints = 5;
float radius = 160;
float variation = 60;
float roundness = 15;
float animDuration = 2.0;
Boolean show = true;
float targetArea;

PVector[] points;
PVector[] controls1;
PVector[] controls2;
float[] targetRadii;
float nextClickTime;

void setup() {
  size(600, 600);
  fullScreen(2);
  Ani.init(this);
  points = new PVector[numPoints];
  controls1 = new PVector[numPoints];
  controls2 = new PVector[numPoints];
  targetRadii = new float[numPoints];

  for (int i = 0; i < numPoints; i++) {
    float angle = TWO_PI * i / numPoints;
    float r = radius + random(-variation, variation);
    points[i] = new PVector(r * cos(angle), r * sin(angle));
    controls1[i] = new PVector(r * cos(angle), r * sin(angle));
    controls2[i] = new PVector(r * cos(angle), r * sin(angle));
  }

  targetArea = calculateArea();
  generateShape();
  nextClickTime = millis() + random(3000, 8000);
}

float calculateArea() {
  float area = 0;
  for (int i = 0; i < numPoints; i++) {
    PVector p1 = points[i];
    PVector p2 = points[(i+1) % numPoints];
    area += (p1.x * p2.y - p2.x * p1.y);
  }
  return abs(area/2);
}

PVector calculateBarycenter() {
  PVector barycenter = new PVector(0, 0);
  for (int i = 0; i < numPoints; i++) {
    int nextI = (i + 1) % numPoints;
    float area = (points[i].x * points[nextI].y - points[nextI].x * points[i].y) / 2;
    PVector triangleCenter = new PVector(
      (points[i].x + points[nextI].x) / 3,
      (points[i].y + points[nextI].y) / 3
      );
    barycenter.add(PVector.mult(triangleCenter, area));
  }
  barycenter.div(calculateArea());
  return barycenter;
}

void adjustPointsForArea(PVector[] points, float targetArea) {
  float currentArea = 0;
  for (int i = 0; i < points.length; i++) {
    PVector p1 = points[i];
    PVector p2 = points[(i+1) % points.length];
    currentArea += (p1.x * p2.y - p2.x * p1.y);
  }
  currentArea = abs(currentArea/2);

  float scaleFactor = sqrt(targetArea / currentArea);
  for (int i = 0; i < points.length; i++) {
    points[i].mult(scaleFactor);
  }
}

void generateShape() {
  PVector[] newPoints = new PVector[numPoints];
  PVector[] newControls1 = new PVector[numPoints];
  PVector[] newControls2 = new PVector[numPoints];

  int midPoint = floor(numPoints/2.0);
  for (int i = 0; i < numPoints; i++) {
    if (i <= midPoint) {
      targetRadii[i] = radius + random(-variation, variation);
      if (i < midPoint) {
        int oppositeIdx = (i + midPoint + 1) % numPoints;
        targetRadii[oppositeIdx] = 2 * radius - targetRadii[i];
      }
    }
  }

  for (int i = 0; i < numPoints; i++) {
    float angle = TWO_PI * i / numPoints;
    newPoints[i] = new PVector(targetRadii[i] * cos(angle), targetRadii[i] * sin(angle));
  }

  adjustPointsForArea(newPoints, targetArea);

  for (int i = 0; i < numPoints; i++) {
    int nextI = (i + 1) % numPoints;
    int prevI = (i - 1 + numPoints) % numPoints;

    PVector toPrev = PVector.sub(newPoints[prevI], newPoints[i]);
    PVector toNext = PVector.sub(newPoints[nextI], newPoints[i]);

    toPrev.normalize();
    toNext.normalize();

    float area = ((newPoints[nextI].x - newPoints[i].x) * (newPoints[prevI].y - newPoints[i].y) -
      (newPoints[prevI].x - newPoints[i].x) * (newPoints[nextI].y - newPoints[i].y)) / 2;

    PVector tangent = new PVector(-(toNext.y + toPrev.y), (toNext.x + toPrev.x));
    tangent.normalize().mult(roundness);
    if (area < 0) tangent.mult(-1);

    newControls1[i] = PVector.add(newPoints[i], tangent);
    newControls2[i] = PVector.sub(newPoints[i], tangent);
  }

  int startIndex = int(random(numPoints));
  float delayBetweenPoints = 0.1;

  for (int i = 0; i < numPoints; i++) {
    int idx = (startIndex + i) % numPoints;
    float delay = i * delayBetweenPoints;

    Ani.to(points[idx], animDuration, delay, "x", newPoints[idx].x, Ani.ELASTIC_OUT);
    Ani.to(points[idx], animDuration, delay, "y", newPoints[idx].y, Ani.ELASTIC_OUT);
    Ani.to(controls1[idx], animDuration, delay, "x", newControls1[idx].x, Ani.ELASTIC_OUT);
    Ani.to(controls1[idx], animDuration, delay, "y", newControls1[idx].y, Ani.ELASTIC_OUT);
    Ani.to(controls2[idx], animDuration, delay, "x", newControls2[idx].x, Ani.ELASTIC_OUT);
    Ani.to(controls2[idx], animDuration, delay, "y", newControls2[idx].y, Ani.ELASTIC_OUT);
  }
}

void draw() {
  background(255);
  translate(width/2, height/2);

  if (millis() > nextClickTime) {
    generateShape();
    nextClickTime = millis() + random(1000, 3000);
  }

  fill(0);
  noStroke();
  beginShape();
  vertex(points[0].x, points[0].y);
  for (int i = 1; i <= numPoints; i++) {
    int idx = i % numPoints;
    int prevIdx = (i - 1) % numPoints;
    bezierVertex(
      controls2[prevIdx].x, controls2[prevIdx].y,
      controls1[idx].x, controls1[idx].y,
      points[idx].x, points[idx].y
      );
  }
  endShape(CLOSE);

  if (show) {
    for (int i = 0; i < numPoints; i++) {
      int prevI = (i-1+numPoints) % numPoints;
      int nextI = (i+1) % numPoints;

      float area = ((points[nextI].x - points[i].x) * (points[prevI].y - points[i].y) -
        (points[prevI].x - points[i].x) * (points[nextI].y - points[i].y)) / 2;

      stroke(area < 0 ? color(255, 0, 0, 100) : color(0, 255, 0, 100));
      line(points[i].x, points[i].y, controls1[i].x, controls1[i].y);
      line(points[i].x, points[i].y, controls2[i].x, controls2[i].y);
      fill(area < 0 ? color(255, 0, 0, 100) : color(0, 255, 0, 100));
      circle(controls1[i].x, controls1[i].y, 5);
      circle(controls2[i].x, controls2[i].y, 5);

      // Affichage des indices vers l'extérieur
      PVector center = new PVector(0, 0);
      PVector toPoint = PVector.sub(points[i], center);
      toPoint.normalize();
      float textOffset = 25;
      float textX = points[i].x + toPoint.x * textOffset;
      float textY = points[i].y + toPoint.y * textOffset;
      fill(0);
      textSize(12);
      textAlign(CENTER, CENTER);
      text(i, textX, textY);
    }

    // Affichage barycentre et surfaces
    PVector center = calculateBarycenter();
    noStroke();
    fill(255, 255, 0);
    circle(center.x, center.y, 12);

    fill(0);
    textAlign(LEFT, TOP);
    text("Surface: " + nf(calculateArea(), 0, 2), -width/2 + 10, -height/2 + 10);
    text("Surface cible: " + nf(targetArea, 0, 2), -width/2 + 10, -height/2 + 30);
  }
}

void mousePressed() {
  generateShape();
  nextClickTime = millis() + random(3000, 8000);
}

void keyPressed() {
  if (key == ' ') {
    show = !show;
    println("show:", show);
  }
}
