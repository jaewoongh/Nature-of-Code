ArrayList<Mover> movers;
Mover m;

boolean pressed = false;
PVector pmouse, mouse;

void setup() {
  size(600, 600);
  smooth();
  movers = new ArrayList();
  for(int i = 0; i < 10; i++) {
    PVector p = new PVector(random(width), random(height));
    movers.add(new Mover(p, random(5, 100)));
  }

  pmouse = new PVector(0, 0);
  mouse = new PVector(0, 0);
}


void draw() {
  background(255);

  for(Mover m : movers) {
    m.update();
    m.display();
  }
  
  if(mousePressed) {
    stroke(0, 255, 0);
    line(pmouse.x, pmouse.y, mouseX, mouseY);
  }
}

void mousePressed() {
  if(pressed) return;
  pressed = true;
  pmouse.x = mouseX;
  pmouse.y = mouseY;
}

void mouseReleased() {
  pressed = false;
  mouse.x = mouseX;
  mouse.y = mouseY;
  PVector f = PVector.sub(mouse, pmouse);
  f.mult(2);
  for(Mover m : movers) m.applyForce(f);
}



class Mover {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  float size;
  
  Mover(PVector _pos, float _size) {
    pos = _pos.get();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    size = _size;
    mass = size;
  }
  
  void applyForce(PVector force) {
    PVector f = force.get();
    acc.add(PVector.div(force, mass));
  }
  
  void update() {
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
    vel.mult(0.8);
  }
  
  void display() {
    fill(0); noStroke();
    ellipse(pos.x, pos.y, size, size);
  }
}
