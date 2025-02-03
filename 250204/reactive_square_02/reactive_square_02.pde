import processing.sound.*;

AudioIn micro;
Amplitude amp;
float taille = 200; // taille du carré

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
 float variation = map(niveau, 0, 1, 0, 50);
 
 quad(
   width/2 - taille/2 + random(-variation, variation), height/2 - taille/2 + random(-variation, variation),
   width/2 + taille/2 + random(-variation, variation), height/2 - taille/2 + random(-variation, variation), 
   width/2 + taille/2 + random(-variation, variation), height/2 + taille/2 + random(-variation, variation),
   width/2 - taille/2 + random(-variation, variation), height/2 + taille/2 + random(-variation, variation)
 );
}
