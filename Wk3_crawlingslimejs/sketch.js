var slimes = [];

var newSlime = function(customValues) {
	var slime = new Slime;
	for(var theta = 0; theta < PI * 2; theta += PI * 0.1) {
		var v = PVector.fromAngle(theta);
		v.mult(80);
		slime.addPoint(v);
	}
	
	if(customValues != undefined) {
		if(customValues.pos instanceof PVector) slime.pos = customValues.pos.get();
		if(customValues.vel instanceof PVector) slime.vel = customValues.vel.get();
		if(customValues.acc instanceof PVector) slime.acc = customValues.acc.get();
		if(customValues.col instanceof Array) slime.col = color.apply(undefined, customValues.col);
		if(IsNumeric(customValues.looseDistance)) slime.looseDistance = customValues.looseDistance;
		if(IsNumeric(customValues.packedDistance)) slime.packedDistance = customValues.packedDistance;
		if(IsNumeric(customValues.viscosity)) slime.viscosity = customValues.viscosity;
		if(IsNumeric(customValues.friction)) slime.friction = customValues.friction;
		if(IsNumeric(customValues.dir)) slime.dir = customValues.dir;
		if(IsNumeric(customValues.oscFreq)) slime.oscFreq = customValues.oscFreq;
		if(IsNumeric(customValues.oscAmp)) slime.oscAmp = customValues.oscAmp;
	}

	return slime;
}

function setup() {
	createGraphics(window.innerWidth, window.innerHeight);
	background(255);

	slimes.push(newSlime());
}

function draw() {
	background(255);
	textAlign(LEFT); textSize(14); fill(0); stroke(0); strokeWeight(0);
	text("Hit [a] to add a slime, [r] to remove a slime into a slimy slime stack", 12, 21);

	for(var i = 0; i < slimes.length; i++) {
		slimes[i].crawl();
		slimes[i].run();
	}
}

function keyPressed() {
	if(key == 'a' || key == 'A') {
		slimes.push(newSlime({
			pos: 		new PVector(random(width-200)+100, random(height-200)+100),
			oscFreq: 	random(0.05, 0.15),
			oscAmp: 	random(0.2, 0.7),
			col:  		[random(255), random(255), random(255), 222]
		}));
	} else if(key == 'r' || key == 'R') {
		slimes.pop();
	}
}

function IsNumeric(input) {
    return (input - 0) == input && (''+input).replace(/^\s+|\s+$/g, "").length > 0;
}