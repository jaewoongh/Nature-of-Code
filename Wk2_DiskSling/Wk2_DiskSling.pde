SlingGround field;
int numDisks = 5;


void setup() {
  size(600, 600);
  field = new SlingGround();
  for(int i = 0; i < numDisks; i++) {
    field.addDisk(new PVector(random(width), random(height)), random(100));
  }
}


void draw() {
  background(255);
  field.run();
}


class SlingGround {
  ArrayList<Disk> disks;
  float collisionEfficiency = 0.8;
  
  SlingGround() {
    disks = new ArrayList();
  }
  
  void addDisk(PVector _pos, float _mass) {
    Disk d = new Disk(_pos, _mass);
    disks.add(d);
  }
  
  void removeDisk(int nth) {
    disks.remove(nth);
  }
  
  void run() {
    checkCollision();
    for(Disk d : disks) {
      d.update();
      d.render();
    }
  }
  
  void checkCollision() {
    for(int i = 0; i < disks.size() - 1; i++) {
      Disk d1 = disks.get(i);
      for(int j = i; j < disks.size(); j++) {
        Disk d2 = disks.get(j);
//        PVector bVect = PVector.sub(d2.pos, d1.pos);
//        if(bVect.mag() <= (d1.size + d2.size)*0.5) {  //collided!
        if(PVector.dist(d1.pos, d2.pos) <= (d1.size + d2.size)*0.5) {
          d1.col = color(255, 0, 0);
          d2.col = color(0, 0, 255);
        
          float v1 = d1.vel.mag();
          float v2 = d2.vel.mag();
          float m1 = d1.mass;
          float m2 = d2.mass;
          float theta1 = d1.vel.heading();
          float theta2 = d2.vel.heading();
          float phi = PVector.angleBetween(d2.pos, d1.pos);

          //calculate & apply force that should be applied to d1
          float fX1 = (v1*cos(theta1-phi)*(m1-m2)+2*m2*v2*cos(theta2-phi))/(m1+m2)*cos(phi)+v1*sin(theta1-phi)*cos(phi+HALF_PI);
          float fY1 = (v1*cos(theta1-phi)*(m1-m2)+2*m2*v2*cos(theta2-phi))/(m1+m2)*sin(phi)+v1*sin(theta1-phi)*sin(phi+HALF_PI);
          d1.applyForce(new PVector(fX1, fY1));

          //calculate & apply force that should be applied to d1
          float fX2 = (v2*cos(theta2-phi)*(m2-m1)+2*m1*v1*cos(theta1-phi))/(m2+m1)*cos(phi)+v2*sin(theta2-phi)*cos(phi+HALF_PI);
          float fY2 = (v2*cos(theta2-phi)*(m2-m1)+2*m1*v1*cos(theta1-phi))/(m2+m1)*sin(phi)+v2*sin(theta2-phi)*sin(phi+HALF_PI);
          d2.applyForce(new PVector(fX2, fY2));
        }
      }
    }
  }
}


class Disk {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  float size;
    final float massMin = 1;
    final float massMax = 20;
    final float sizeMin = 5;
    final float sizeMax = 50;
  float friction = 0.9;
  float bounceEfficiency = 0.9;
  boolean picked = false;
  color col;
  
  Disk(PVector _pos, float _mass) {
    pos = _pos.get();
    vel = new PVector(random(-50, 50), random(-50, 50));
    acc = new PVector(0, 0);
    mass = constrain(_mass, massMin, massMax);
    size = map(mass, massMin, massMax, sizeMin, sizeMax);
    col = color(31);
  }
  
  void render() {
    noStroke(); fill(col);
    ellipse(pos.x, pos.y, size, size);
  }
  
  void update() {
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
    vel.mult(friction);
    
    if(pos.x < 0) {
      pos.x = -pos.x * bounceEfficiency;
      vel.x *= -1;
    } else if(pos.x >= width) {
      pos.x = (width - (pos.x - width)) * bounceEfficiency;
      vel.x *= -1;
    }
    if(pos.y < 0) {
      pos.y = -pos.y * bounceEfficiency;
      vel.y *= -1;
    } else if(pos.y >= height) {
      pos.y = (height - (pos.y - height)) * bounceEfficiency;
      vel.y *= -1;
    }
  }
  
  void applyForce(PVector force) {
    PVector f = force.get();
    acc.add(PVector.div(force, mass));
  }
  
  boolean isPicked(PVector pick) {
    picked = (PVector.dist(pos, pick) <= size * 0.5);
    return picked;
  }
}
