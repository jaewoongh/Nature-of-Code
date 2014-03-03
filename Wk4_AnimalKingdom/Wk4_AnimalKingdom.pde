/*  Animal Kingdom,
 *  as described (mostly) in Dan's video lecture
 *
 *  Press and hold mouse button to see additive kingdom
 *  Jaewoong
 */

ArrayList<Animal> kingdom;
PVector fountain;
PImage imgCat;
PImage imgDog;
PImage imgTurtle;

void setup() {
  size(400, 600, P2D);
  frameRate(30);
  kingdom = new ArrayList();
  fountain = new PVector(width*0.5, height*0.1);
  imgCat = loadImage("cat.png");
  imgDog = loadImage("dog.png");
  imgTurtle = loadImage("turtle.png");
}

void draw() {
  if(mousePressed) {
    background(0);
    blendMode(ADD);
  } else {
    background(255);
    blendMode(NORMAL);
  }

  if(frameCount % 10 == 0) {
    float dice = random(3);
    Animal a;
    if(dice < 1) a = new Cat(fountain, imgCat);
    else if(dice < 2) a = new Dog(fountain, imgDog);
    else a = new Turtle(fountain, imgTurtle);
    kingdom.add(a);
  }
  
  for(int i = 0; i < kingdom.size(); i++) {
    Animal an = kingdom.get(i);
    an.applyForce(new PVector(0, 0.3));
    an.run();
    if(an.pos.y > height+50) {
      kingdom.remove(i);
      i--;
    }
  }
}

class Animal {
  PVector pos;
  PVector vel;
  PVector acc;
  float angle;
  float aVel;
  float aAcc;
  PImage img;
  int life;
  
  Animal(PVector _pos, PImage _img) {
    pos = _pos.get();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    angle = random(TWO_PI);
    aVel = 0;
    aAcc = 0;
    img = _img;
    
    PVector initialForce = PVector.fromAngle(random(TWO_PI));
    applyForce(PVector.mult(initialForce, random(5)));
    applyTorque(random(-0.3, 0.3));
  }
  
  void applyForce(PVector force) {
    acc.add(force.get());
  }
  
  void applyTorque(float torque) {
    aAcc += torque;
  }
  
  void update() {
    vel.add(acc);
    pos.add(vel);
    acc.mult(0);
    vel.mult(0.98);
    
    aVel += aAcc;
    angle += aVel;
    aAcc = 0;
    aVel *= 0.98;
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    if(frameCount % 30 < 20) sleep();
    rotate(angle);
    imageMode(CENTER);
    image(img, 0, 0);
    popMatrix();
  }
  
  void sleep() {
    fill(mousePressed ? 255 : 0);
    textAlign(CENTER);
    textSize(24);
    text("zzzz..", 0, -70);
  }
  
  void run() {
    update();
    display();
  }
}

class Cat extends Animal {
  Cat(PVector p, PImage i) { super(p, i); }

    void sleep() {
    fill(mousePressed ? 255 : 0);
    textAlign(CENTER);
    textSize(24);
    text("purr..", 0, -60);
  }
}

class Dog extends Animal {
  Dog(PVector p, PImage i) { super(p, i); }
}

class Turtle extends Animal {
  Turtle(PVector p, PImage i) { super(p, i); }
  
  void sleep() {
    fill(mousePressed ? 255 : 0);
    textAlign(CENTER);
    textSize(24);
    text("......", 0, -50);
  }
}
