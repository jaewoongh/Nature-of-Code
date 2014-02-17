var slime;
var mode;	//"m" for moving mode, "s" for shaping mode

function setup() {
	createGraphics(window.innerWidth, window.innerHeight);
	background(255);
	mode = "s";

	slime = new Slime();
	for(var theta = 0; theta < PI * 2; theta += PI * 0.1) {
		var v = PVector.fromAngle(theta);
		v.mult(width*0.15);
		slime.addPoint(v);
	}
}

function draw() {
	background(55);
	textAlign(LEFT); textSize(14); fill(255); stroke(255); strokeWeight(0);
	text(mode == "s" ? "JIGGLE MODE" : "MOVE MODE", 12, 24);
	text("Hit [m] to change mode", 12, 42);

	switch(mode) {
		case "m":
			var move = PVector.sub(new PVector(constrain(mouseX, 0, width-1), constrain(mouseY, 0, height-1)), slime.pos);
			move.mult(0.1);
			move.limit(2);
			slime.applyForce(move);
			slime.run();
			break;
		case "s":
			slime.shrinkFrom(new PVector(mouseX, mouseY), width*0.15);
			slime.run();
			break;
		default:
			throw("Unexpected mode value: " + mode);
	}
}

function keyPressed() {
	if(key == "M" || key == "m") mode = mode == "m" ? "s" : "m";
}

