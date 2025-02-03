import processing.sound.*;

AudioIn micro;
Amplitude amp;

void setup() {
  size(400, 400);
  
  micro = new AudioIn(this, 0);
  micro.start();
  
  amp = new Amplitude(this);
  amp.input(micro);
}

void draw() {
  background(255);
  fill(0);
  noStroke();
  
  float niveau = amp.analyze();
  float variation = map(niveau, 0, 1, 0, 50); // 50 pixels max de variation
  
  quad(
    200 + random(-variation, variation), 200 + random(-variation, variation),
    250 + random(-variation, variation), 200 + random(-variation, variation), 
    250 + random(-variation, variation), 250 + random(-variation, variation),
    200 + random(-variation, variation), 250 + random(-variation, variation)
  );
}
