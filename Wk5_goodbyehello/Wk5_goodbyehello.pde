// MERE COMBINATION OF TWO EXAMPLES OF GEOMERATIVE LIBRARY AND BOX2D FOR PROCESSING
// Click screen to break the greetings

import geomerative.*;

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

// Declare the objects we are going to use, so that they are accesible from setup() and from draw()
RFont f;
RShape grp;
RPoint[] points;

// A reference to our box2d world
Box2DProcessing box2d;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our rectangles
ArrayList<Box> boxes;

boolean triggered = false;


void setup(){
  // Initilaize the sketch
  size(600,400);
  frameRate(24);

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // We are setting a custom gravity
  box2d.setGravity(0, -10);

  // Create ArrayLists  
  boxes = new ArrayList<Box>();
  boundaries = new ArrayList<Boundary>();

  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(width/4,height-5,width/2-50,10));
  boundaries.add(new Boundary(3*width/4,height-50,width/2-50,10));

  // Choice of colors
  background(255);
  fill(255,102,0);
  stroke(0);
  
  // VERY IMPORTANT: Allways initialize the library in the setup
  RG.init(this);
  
  //  Load the font file we want to use (the file must be in the data folder in the sketch floder), with the size 60 and the alignment CENTER
  grp = RG.getText("Hello world!", "FreeSans.ttf", 72, CENTER);

  // Enable smoothing
  smooth();

  // Clean frame
  background(255);
  
  // // Set the origin to draw in the middle of the sketch
  // translate(width/2, 3*height/4);
  
  // // Draw the group of shapes
  // noFill();
  // stroke(0,0,200,150);
  // RG.setPolygonizer(RG.ADAPTATIVE);
  // grp.draw();
  
  // Get the points on the curve's shape
  //RG.setPolygonizer(RG.UNIFORMSTEP);
  //RG.setPolygonizerStep(map(float(mouseY), 0.0, float(height), 0.0, 1.0));
  
  RG.setPolygonizer(RG.UNIFORMLENGTH);
  RG.setPolygonizerLength(5);
  points = grp.getPoints();
  
  // If there are any points
  if(points != null){
    for(int i=0; i<points.length; i++){
      Box p = new Box(points[i].x+width*0.5, points[i].y+height*0.2);
      boxes.add(p);
    }
  }
}

void draw(){
  background(255);

  // We must always step through time!
  if(triggered) box2d.step();

  // Display all the boundaries
  for (Boundary wall: boundaries) {
    wall.display();
  }

  // Display all the boxes
  for (Box b: boxes) {
    b.display();
  }

  // Boxes that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = boxes.size()-1; i >= 0; i--) {
    Box b = boxes.get(i);
    if (b.done()) {
      boxes.remove(i);
    }
  }
}

void mousePressed() {
  triggered = true;
}
