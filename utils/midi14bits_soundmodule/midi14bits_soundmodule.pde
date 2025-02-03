import themidibus.*;

MidiBus myBus;
int lastMSB = 0;
int lastLSB = 0;
float mappedValue = 0;
boolean isFreqMode = false;  // Mode actuel

void setup() {
  size(400, 800);
  MidiBus.list();
  myBus = new MidiBus(this, 1, 2);
  noStroke();
}

void draw() {
  background(220);
  float normalizedValue = constrain(mappedValue / 16383.0, 0, 1.0);
  float rectHeight = width * (isFreqMode ? normalizedValue : normalizedValue * 0.9); // Sensibilité réduite en mode volume
  fill(isFreqMode ? color(255,0,0) : color(0,255,0));  // Rouge pour freq, vert pour volume
  circle(width/2,height/2, rectHeight);
  //rect(0, height - rectHeight, width, rectHeight);
}

void controllerChange(int channel, int number, int value) {
  if (number == 19) {  // CC_MODE
    isFreqMode = (value == 127);
    println("changeMode =",value);
  } else if (number == 0 || number == 1) {  // MSB pour freq ou volume
    lastMSB = value;
  } else if (number == 32 || number == 33) {  // LSB pour freq ou volume
    lastLSB = value;
    mappedValue = (lastMSB << 7) | lastLSB;
  }
}
