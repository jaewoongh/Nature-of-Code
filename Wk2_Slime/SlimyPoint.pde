
class SlimyPoint {
  Slime mother;
  PVector orig;    //original position
  PVector pos;
  PVector vel;
  PVector acc;
  float theta;     //relative angle from mother's center
  
  SlimyPoint(Slime _mother, PVector _orig) {
    mother = _mother;
    orig = _orig.get();
    pos = orig.get();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    theta = pos.heading();
  }
  
  void update() {
    returnToOrig();
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
    wallBounce();
    vel.mult(0.8);
  }
  
  void wallBounce() {
    PVector p = PVector.add(pos, mother.pos);
    
    if(p.x < 0) {
      applyForce(new PVector(-p.x, 0));
      p.x = 0;
    } else if(p.x >= width) {
      applyForce(new PVector(-(p.x-width), 0));
      p.x = width;
    }

    if(p.y < 0) {
      applyForce(new PVector(0, -p.y));
      p.y = 0;
    } else if(p.y >= height) {
      applyForce(new PVector(0, -(p.y-height)));
      p.y = height;
    }
    
    pos = PVector.sub(p, mother.pos);
  }
  
  void escapeFrom(PVector v, float range) {
    PVector escape = PVector.sub(v, pos);
    if(escape.mag() > range) return;
    escape.setMag(map(escape.mag(), 0, range, 1, 0));  //arbitrary value
    escape.mult(-1);
    applyForce(escape);
  }
  
  void returnToOrig() {
    PVector goback = PVector.sub(orig, pos);
    goback.setMag(map(goback.mag(), 0, 400, 0, 8));    //arbitrary values
    applyForce(goback);
  }
  
  void applyForce(PVector force) {
    PVector f = force.get();
    acc.add(f);
  }
}
