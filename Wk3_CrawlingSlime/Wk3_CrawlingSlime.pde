/* Crawling Slime
 * by Jaewoong, Feb 2014
 *  - Slime has internal sine wave
 *  - When the wave goes above 0, the slime stretches to reach the destination
 *  - When the wave goes below 0, the slime settles to the new position
 *  - According to which direction the slime wants to go, a few points are selected to be feet
 *  - Heading direction of the slime is randomly decided
 *
 *  Press and hold any key to see more while the sketch is running
 */

ArrayList<Slime> slimes;
Slime slime;
Slime[] slimeCMY = new Slime[3];

void setup() {
  size(600, 600); smooth();
  background(255);

  //make a slime, and points for the slime
  slime = new Slime(new PVector(width*0.5, height*0.5));
  for(float theta = 0; theta < TWO_PI; theta += TWO_PI * 0.05) {
    PVector v = PVector.fromAngle(theta);
    v.mult(120);
    slime.addPoint(v);
  }
  
//  //play with CMY slimes
//  for(int i = 0; i < 3; i++) {
//    slimeCMY[i] = new Slime(new PVector(random(width-200)+100, random(height-200)+100));
//    for(float theta = 0; theta < TWO_PI; theta += TWO_PI * 0.05) {
//      PVector v = PVector.fromAngle(theta);
//      v.mult(100);
//      slimeCMY[i].addPoint(v);
//    }
//    slimeCMY[i].oscFreq = random(0.05, 0.3);
//    slimeCMY[i].oscAmp = random(0.1, 0.6);
//    slimeCMY[i].packedDistance = random(2, 4);
//    slimeCMY[i].looseDistance = slimeCMY[i].packedDistance + random(2, 4);
//  }
//  slimeCMY[0].col = color(0, 255, 255, 222);
//  slimeCMY[1].col = color(255, 0, 255, 222);
//  slimeCMY[2].col = color(255, 255, 0, 222);
}

void draw() {
  background(255);
   
//  //play with CMY slimes
//  for(int i = 0; i < 3; i++) {
//    slimeCMY[i].crawl();
//    slimeCMY[i].run();
//  }

  slime.crawl();
  slime.run();   //not sprinting, just running the procedure
  
  //show sine wave when key is pressed
  if(keyPressed) {
    float freq = slime.oscFreq;
    float fc = frameCount;
    int y;
    beginShape();
    stroke(0, 111); noFill();
    for(int x = 0; x < width; x++) {
      y = height-25;
      vertex(x, y-sin((fc-width*0.5+x)*freq)*10);
    }
    endShape();
    stroke(0, 222); strokeWeight(0.5); line(0, height-25, width, height-25);
    stroke(255, 0, 0, 111); strokeWeight(2); line(width*0.5, height-40, width*0.5, height-10);
    float currentVal = sin((fc)*freq)*10;
    fill((currentVal >= 0) ? 255 : 0, 0, 0, 111);
    noStroke(); ellipse(width*0.5, height-25-currentVal, 8, 8);
  } else {
    fill(0, 111);
    textAlign(LEFT);
    text("Press and hold any key to see more..", 10, 20);
 }
}
