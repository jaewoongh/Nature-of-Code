
class Slime {
  ArrayList<SlimyPoint> points;
  PVector pos;          //position
  PVector vel;          //velocity
  PVector acc;          //acceleration
  color col;            //color of the slime
  float packedDistance; //minimum distance between adjecent points
  float looseDistance;  //maximum distance between adjecent points
  float viscosity;      //willingness to tie together: the bigger the value is, the bouncy it is
  float friction;       //efficiency of sliding
  boolean set;          //true if there're enough number of points and all set
  float dir;            //direction that the slime will be heading
  float oscillation;    //sine wave oscillator: if the value is 0 or greater than 0, apply force to the slime with acorrding value
  float oscFreq = 0.1;  //frequency of the wave
  float oscAmp = 0.5;   //amplitude of the wave
  PVector offset;       //stores a sum of vectors from slime's one move
  boolean wasMoving;    //true while the slime is moving
  boolean firstMove;    //true at the moment that the slime starts to move
  
  Slime(PVector _pos) {
    points = new ArrayList();
    pos = _pos.get();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    col = color(0, 222);
    looseDistance = 8;            //arbitrary value
    packedDistance = 5;           //arbitrary value
    viscosity = 0.14;             //arbitrary value
    friction = 0.8;               //arbitrary value
    set = false;                  //false at first, go true if all set
    dir = random(TWO_PI);
    oscillation = 0;              //arbitrary value
    offset = new PVector(0, 0);
    wasMoving = false;
    firstMove = true;
  }
  
  void addPoint(PVector _pos) {
    //add a slimy point to this slime
    SlimyPoint p = new SlimyPoint(this, _pos);
    points.add(p);
    if(points.size() >= 3) set = true;  //if there're more than 2 points, it's good to go
  }
  
  void removePoint(float nth) {
    //remove nth slimy point from this slime
    points.remove(nth);
    if(points.size() < 3) set = false;
  }
  
  void crawl() {
    //do oscillation
    oscillation = sin(frameCount*oscFreq)*oscAmp;
    
    //crawl only if sine wave is not smaller than 0
    if(oscillation >= 0) {
      if(firstMove) {
        //if the slime just started to move, 
        //set new direction that will not let the slime go outside of the screen
        boolean nokay = true;
        while(nokay) {
          dir = random(TWO_PI);      //get new direction
          PVector posPrediction = pos.get();
          PVector movePrediction = PVector.fromAngle(dir);
          movePrediction.mult(100);  //let's say that the slime moves around 100 pixels for one move
          posPrediction.add(movePrediction);
          if(keyPressed) {
            //draw one-frame visual presentation of predicted-destination
            noStroke(); fill(0, 255, 255);
            ellipse(posPrediction.x, posPrediction.y, 50, 50);
          }
          //if predicted position is inside the boundary, stop looping
          if(!(posPrediction.x < 0 || posPrediction.x >= width || posPrediction.y < 0 || posPrediction.y >= height)) nokay = false;
        }
    
        //pick feet according to the direction
        for(SlimyPoint p : points) {
          float diff = abs(atan2(sin(dir - p.theta), cos(dir - p.theta)));
          if(diff < PI*0.2) p.foot = true;    //0.2(rad) is an arbitrary number
          else p.foot = false;
        }
        
        firstMove = false;  //flag down
      } else {
        //(oscillation value >= 0) && (direction and feet are all set) => just crawl
        PVector v = PVector.fromAngle(dir);
        v.mult(oscillation);    //force that moves the slime is a result of oscillation
        applyForce(v);
        wasMoving = true;
      }
    } else {        //if oscillation value is less than 0, do not move
      if(wasMoving) {
        //if the slime just stopped, reset the original position of slimy points, so that the points can settle into normal positions
        wasMoving = false;
        resetOrig();
      }
      firstMove = true;
    }
  }
  
  void run() {
    if(!set) return;    //if there're not enough points, do nothing because the code will not run as intended
    update();           //update the position of this slime itself
    viscousUpdate();    //update the position of slimy points that consist this slime
    display();          //draw the slime on the screen
  }
  
  void shrinkFrom(PVector v, float range) {
    v.sub(pos);
    for(SlimyPoint p : points) p.escapeFrom(v, range);
  }
  
  void update() {
    vel.add(acc);
    pos.add(vel);
    if(oscillation >= 0) {          //if the slime is moving now,
      for(SlimyPoint p : points) {  //look up for every points,
        if(!p.foot) {               //and if the point is not a foot,
          p.orig.sub(vel);          //force hold back the original position to the position before a move 
          p.pos.sub(vel);           //force hold back the position to the position before a move
        }
      }
      offset.add(vel);              //store all vectors that were forced points back, so that they can be restored afterward
    }
    acc.mult(0);                    //every force is for just a moment; nullify acceleration every after applying to the velocity
    vel.mult(friction);
  }
  
  void resetOrig() {
    //reset original points to normal position
    //note that position of points as well as original position was held back, but only original position is being resotred
    for(SlimyPoint p : points) {
      if(!p.foot) p.orig.add(offset);
    }
    offset.mult(0);  //flush the offset vector
  }
  
  void viscousUpdate() {
    //simulate bouncy slimy motion dealing with slimy points
    for(int i = 0; i < points.size(); i++) {
      //for every slimy points, get its two adjacent points
      SlimyPoint p = points.get(i);
      SlimyPoint prev = points.get((i == 0) ? points.size()-1 : i-1);
      SlimyPoint next = points.get((i == points.size()-1) ? 0 : i+1);
      
      //if the point is too far or too close to any of adjacent points, it gets some force
      dragOneToOther(p, prev);
      dragOneToOther(p, next);
      
      p.update();
    }
    //do one last calculation
    dragOneToOther(points.get(0), points.get(points.size()-1));
    dragOneToOther(points.get(0), points.get(1));
    
    SlimyPoint oneMoreP = points.get(0);
    oneMoreP.update();
  }
  
  void dragOneToOther(SlimyPoint p, SlimyPoint other) {
    //if 'p' goes too far from 'other', apply force to 'p' to go back to near 'other'
    //if 'p' goes too cose to 'other', apply force to 'p' to go further from 'other'

    //foot points are able to go more from adjacent points than non-foot points
    float lD = (p.foot && oscillation >= 0) ? looseDistance*2 : looseDistance;
    
    PVector v = p.pos.get();
    PVector u = other.pos.get();
    PVector w = PVector.sub(u, v);
    if(w.mag() > lD) {
      w.setMag(w.mag() - lD);
      p.applyForce(PVector.mult(w, viscosity));
    } else if(w.mag() < packedDistance) {
      w.setMag(packedDistance - w.mag());
      p.applyForce(PVector.mult(w, viscosity));
    }
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    noStroke(); strokeWeight(1);
    beginShape();
    for(int i = 0; i < points.size()+3; i++) {
      SlimyPoint p = points.get((i < points.size()) ? i : i-points.size());
      fill(col);
      curveVertex(p.pos.x, p.pos.y);  //curve-connect each point
      if(keyPressed) {
        //show slimy points and original position for the points
        noStroke();
        fill((p.foot)?255:0, 0, 0); ellipse(p.pos.x, p.pos.y, (p.foot)?10:5, (p.foot)?10:5);
        fill(0, 255, 0); ellipse(p.orig.x, p.orig.y, 5, 5);

        //show relative direction of points to position of the slime
        PVector v = p.pos.get();
        v.setMag(v.mag()*1.2);
        stroke(255, 0, 0); line(p.pos.x, p.pos.y, v.x, v.y);
        noStroke();

        fill(0, 111);
      }
    }
    endShape(CLOSE);

    if(keyPressed) {
      //show slime's position
      fill(255, 0, 255); ellipse(0, 0, 10, 10);
      
      //show slime's velocity vector
      stroke(255, 0, 255);
      line(0, 0, vel.x*15, vel.y*15);
      line(vel.x*15, vel.y*15, cos(dir+PI*0.1)*vel.mag()*10, sin(dir+PI*0.1)*vel.mag()*10);
      line(vel.x*15, vel.y*15, cos(dir-PI*0.1)*vel.mag()*10, sin(dir-PI*0.1)*vel.mag()*10);
    }
    popMatrix();
  }
  
  void applyForce(PVector force) {
    //assume that the slime has a mass of 1
    PVector f = force.get();
    acc.add(f);
  }
}
