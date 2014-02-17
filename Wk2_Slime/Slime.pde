
class Slime {
  ArrayList<SlimyPoint> points;
  PVector pos;          //position
  PVector vel;          //velocity
  PVector acc;          //acceleration
  float packedDistance; //minimum distance between adjecent points
  float looseDistance;  //maximum distance between adjecent points
  float viscosity;      //willingness to tie together: the bigger the value is, the bouncy it is
  float friction;       //efficiency of sliding
  boolean set;          //there're enough number of points and all set
  
  
  Slime(PVector _pos) {
    points = new ArrayList();
    pos = _pos.get();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    looseDistance = 8;
    packedDistance = 3;
    viscosity = 0.15;
    friction = 0.8;
    set = false;
  }
  
  void addPoint(PVector _pos) {
    SlimyPoint p = new SlimyPoint(this, _pos);
    points.add(p);
    if(points.size() >= 3) set = true;
  }
  
  void removePoint(float nth) {
    points.remove(nth);
    if(points.size() < 3) set = false;
  }
  
  void run() {
    if(!set) return;
    update();
    viscousUpdate();
    display();
  }
  
  void shrinkFrom(PVector v, float range) {
    v.sub(pos);
    for(SlimyPoint p : points) p.escapeFrom(v, range);
  }
  
  void update() {
    vel.add(acc);
    pos.add(vel);
    for(SlimyPoint p : points) p.pos.sub(vel);
    acc.mult(0);
    vel.mult(friction);
  }
  
  void viscousUpdate() {
    for(int i = 0; i < points.size(); i++) {
      SlimyPoint p = points.get(i);
      SlimyPoint prev = points.get((i == 0) ? points.size()-1 : i-1);
      SlimyPoint next = points.get((i == points.size()-1) ? 0 : i+1);
      
      dragOneToOther(p, prev);
      dragOneToOther(p, next);
      
      p.update();
    }
    dragOneToOther(points.get(0), points.get(points.size()-1));
    dragOneToOther(points.get(0), points.get(1));
    
    SlimyPoint oneMoreP = points.get(0);
    oneMoreP.update();
  }
  
  void dragOneToOther(SlimyPoint p, SlimyPoint other) {
    PVector v = p.pos.get();
    PVector u = other.pos.get();
    PVector w = PVector.sub(u, v);
    if(w.mag() > looseDistance) {
      w.setMag(w.mag() - looseDistance);
      p.applyForce(PVector.mult(w, viscosity));
    } else if(w.mag() < packedDistance) {
      w.setMag(packedDistance - w.mag());
      p.applyForce(PVector.mult(w, viscosity));
    }
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    noStroke(); fill(0, 222);
    beginShape();
    for(int i = 0; i < points.size()+3; i++) {
      SlimyPoint p = points.get((i < points.size()) ? i : i-points.size());
      curveVertex(p.pos.x, p.pos.y);
      if(keyPressed && !(key == 'm' || key == 'M')) {
        fill(0); ellipse(p.pos.x, p.pos.y, 5, 5);
        textAlign(CENTER); text(i, p.pos.x, p.pos.y-5);
        fill(0, 111);
        PVector v = p.pos.get();
        v.setMag(v.mag()*1.1);
        stroke(255, 0, 0); line(p.pos.x, p.pos.y, v.x, v.y);
        noStroke();
      } else fill(0, 222);
    }
    endShape(CLOSE);
    fill(255, 0, 255);
    ellipse(0, 0, 10, 10);
    popMatrix();
  }
  
  void applyForce(PVector force) {
    PVector f = force.get();
    acc.add(f);
  }
}
