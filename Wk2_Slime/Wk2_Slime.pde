/* Slime
 * by Jaewoong, Feb 2014
 *  Change mode by hitting [m]
 */

Slime slime;
char mode;    //'m' for moving mode, 's' for shaping mode
int shotNum = 6;

void setup() {
  size(600, 600); smooth();

  //set initial mode
  mode = 's';

  //make a slime, and points for the slime
  slime = new Slime(new PVector(width*0.5, height*0.5));
  for(float theta = 0; theta < TWO_PI; theta += TWO_PI * 0.05) {
    PVector v = PVector.fromAngle(theta);
    v.mult(120);
    slime.addPoint(v);
  }
}

void draw() {
  background(255);

  switch(mode) {
    case 'm':  //move mode
      PVector move = PVector.sub(new PVector(mouseX, mouseY), slime.pos);
      move.mult(0.1);
      move.limit(2);
      slime.applyForce(move);    //move toward the mouse position
      slime.run();
      textAlign(LEFT); fill(0, 127);
      text("MOVE MODE: Slime follows mouse pointer" + '\r' + '\n' + "Hit [m] to change the mode", 10, 20);
      break;
    case 's':  //shape mode
      slime.shrinkFrom(new PVector(mouseX, mouseY), 80);  //avoid the mouse position
      slime.run();
      textAlign(LEFT); fill(0, 127);
      text("SHAPE MODE: Slimy points escape from mouse pointer" + '\r' + '\n' + "Hit [m] to change the mode", 10, 20);
      break;
    default:   //this should not happen
      println("MODE EXCEPTION: UNKOWN MODE \'" + mode + "\' TRIGGERED");
      break;
  }
}

void keyPressed() {
  if(key == 'm' || key == 'M') { if(mode == 'm') mode = 's'; else if(mode == 's') mode = 'm'; }
}
