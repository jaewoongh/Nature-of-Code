
/*********************
** SlimyPoint Class **
*********************/
function SlimyPoint(mother, orig) {
	// inspect arguments
	if(!(mother instanceof Slime)) throw("SlimyPoint needs mother as an instance of Slime");
	if(!(orig instanceof PVector)) throw("SlimyPoint needs origin position in a form of PVector");

	// assign initial values
	this.mother = mother;
	this.orig = orig.get();
	this.pos = orig.get();
	this.vel = new PVector(0, 0);
	this.acc = new PVector(0, 0);
	this.theta = this.pos.heading();
	this.foot = false;
}

SlimyPoint.prototype.update = function() {
	this.returnToOrig();
	this.vel.add(this.acc);
	this.pos.add(this.vel);
	this.acc.mult(0);
	this.wallBounce();
	this.vel.mult(0.8);
}

SlimyPoint.prototype.wallBounce = function() {
	var p = PVector.add(this.pos, this.mother.pos);		// get actual position on screen

	if(p.x < 0) p.x = this.applyForce(new PVector(-p.x, 0)), 0;
	else if(p.x >= width) p.x = this.applyForce(new PVector(-(p.x-width), 0)), width-1;

	if(p.y < 0) p.y = this.applyForce(new PVector(0, -p.y), 0);
	else if(p.y >= height) p.y = this.applyForce(new PVector(0, -(p.y-height))), height-1;

	//** I DON'T KNOW WHY THE CODE BELOW CAUSES MALFUNCTION
	//this.pos = PVector.sub(p, this.mother.pos);
}

SlimyPoint.prototype.escapeFrom = function(v, range) {	//v is a PVector that should be escaped, range is range
	// inspect argument
	if(!(v instanceof PVector)) throw("SlimyPoint.escapeFrom needs position as an instance of PVector");

	var escape = PVector.sub(v, this.pos);
	if(escape.mag() > range) return;
	escape.setMag(map(escape.mag(), 0, range, 1, 0));	//arbitrary value
	escape.mult(-1);
	this.applyForce(escape);
}

SlimyPoint.prototype.returnToOrig = function() {
	var goback = PVector.sub(this.orig, this.pos);
	goback.setMag(map(goback.mag(), 0, 400, 0, 8));		//arbitrary value
	this.applyForce(goback);
}

SlimyPoint.prototype.applyForce = function(force) {
	if(!(force instanceof PVector)) throw("SlimyPoint.applyForce needs force as an instance of PVector");
	var f = force.get();
	this.acc.add(f);
}