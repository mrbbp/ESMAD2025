import themidibus.*;

MidiBus bus;

void setup() {
  MidiBus.list();
  // 1 -> numero dans liste des input
  //MidiBus(java.lang.Object parent, int in_device_num, int out_device_num)
  bus = new MidiBus(this, 1,2);
  bus.sendNoteOff(new Note(0,64,127));
}

void draw() {
  
}

void noteOn(int canal, int pitch, int velocite) {
  println("noteOn: "+canal+" , "+pitch+" , "+velocite);
}

void noteOff(int canal, int pitch, int velocite) {
  println("noteOn: "+canal+" , "+pitch+" , "+velocite);
}

void controllerChange(int channel, int number, int value) {
    switch(number) {
      default:
        println(number,value,"générique");
    }
    //resetMotif();
}
