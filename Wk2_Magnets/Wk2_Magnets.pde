/* Magnets (Spring 2014, Nature of Code, Wk2 Assignment)
 *
 *
 *
 * Jaewoong Hwang
 */


MagneticField field;

int pickedOne = -1;
PVector preMouse;


void setup() {
  size(400, 400);
  field = new MagneticField();
  field.addMagnet(new PVector(random(width), random(height)), 'N', random(10, 100));
  field.addMagnet(new PVector(random(width), random(height)), 'S', random(10, 100));
  field.addMagnet(new PVector(random(width), random(height)), 'N', random(10, 100));
  field.addMagnet(new PVector(random(width), random(height)), 'S', random(10, 100));
}


void draw() {
  background(255);
  field.run();
}


void mousePressed() {
  pickedOne = field.pickedOne(mouseX, mouseY);
  preMouse = new PVector(mouseX, mouseY);
}

void mouseReleased() {
  if(pickedOne == -1) return;
  PVector force = PVector.sub(new PVector(mouseX, mouseY), preMouse);
  force.mult(11);
  field.applyForceTo(pickedOne, force);
}


class MagneticField {
  ArrayList<Magnet> magnets;
  
  MagneticField() {
    magnets = new ArrayList();
  }
  
  void addMagnet(PVector _pos, char _pol, float _str) {
    Magnet m = new Magnet(_pos, _pol, _str);
    magnets.add(m);
  }
  
  void removeMagnet(int nth) {
    magnets.remove(nth);
  }
  
  void run() {
    int i;
    for(i = 0; i < magnets.size() - 1; i++) {
      Magnet m1 = magnets.get(i);
      for(int j = i+1; j < magnets.size(); j++) {
        Magnet m2 = magnets.get(j);
        if(PVector.dist(m1.pos, m2.pos) <= (m1.d + m2.d) * 0.5) {  //collide!
        }
      }
      m1.update();
      m1.render();
    }
    Magnet m1 = magnets.get(i);
    m1.update();
    m1.render();
  }
  
  void applyForceTo(int n, PVector force) {
    if(n < 0 || n >= magnets.size()) return;
    Magnet m = magnets.get(n);
    m.applyForce(force);
  }
  
  int pickedOne(float x, float y) {
    for(int i = magnets.size() - 1; i >= 0; i--) {
      Magnet m = magnets.get(i);
      if(m.isPicked(x, y)) return i;
    }
    return -1;
  }
}


class Magnet {
  PVector pos;
  PVector vel;
  PVector acc;
  char polarity;  //either 'N' or 'S'
  float strength; //how strong the magnet is
  float d;        //diameter; proportional to the strength of magnet
  float mass;
    final float strMin = 0;
    final float strMax = 50;
    final float diaMin = 10;
    final float diaMax = 50;
    final float massMin = 10;
    final float massMax = 100;
  color col;
  float friction;  //friction to the floor
  float bounceEff; //ammount of velocity that reserves after bounce
  
  Magnet(PVector _pos, char _pol, float _str) {
    pos = _pos.get();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    polarity = _pol;
    strength = constrain(_str, strMin, strMax);
    d = map(pow(strength, 0.5), pow(strMin, 0.5), pow(strMax, 0.5), diaMin, diaMax);
    col = color(255-(polarity=='N'?map(strength,strMin,strMax,0,255):0), 255-(polarity=='N'?map(strength,strMin,strMax,0,255):0)-(polarity=='S'?map(strength,strMin,strMax,0,255):0), 255-(polarity=='S'?map(strength,strMin,strMax,0,255):0));
    friction = 0.9;
    bounceEff = 0.8;
    mass = map(d, diaMin, diaMax, massMin, massMax);
  }
  
  void render() {
    stroke(map(strength,strMin,strMax,255,0)); strokeWeight(2); fill(col);
    ellipse(pos.x, pos.y, d, d);
  }
  
  void update() {
    vel.add(acc);
    pos.add(vel);
    checkBoundaryCollision();
    acc.mult(0);
    vel.mult(friction);
  }
  
  void checkBoundaryCollision() {
    if(pos.x < 0) {
      pos.x *= -1;
      vel.x *= -1;
    } else if(pos.x >= width) {
      pos.x = width - (pos.x - width);
      vel.x *= -1;
    }
    if(pos.y < 0) {
      pos.y *= -1;
      vel.y *= -1;
    } else if(pos.y >= height) {
      pos.y = height - (pos.y - height);
      vel.y *= -1;
    }
  }
  
  boolean isPicked(float x, float y) {
    return PVector.dist(pos, new PVector(x, y)) < d*0.5;
  }
  
  void applyForce(PVector force) {
    PVector f = force.get();
    acc.add(PVector.div(f, mass));
  }
}
