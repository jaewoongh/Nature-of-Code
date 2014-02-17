
/****************
** Slime Class **
****************/
function Slime(pos) {
	if(pos instanceof PVector) this.pos = pos.get();
	else this.pos = new PVector(width*0.5, height*0.5);
	this.points = [];
	this.vel = new PVector(0, 0);
	this.acc = new PVector(0, 0);
	this.looseDistance = width*0.1*0.17;
	this.packedDistance = width*0.1*0.13;
	this.viscosity = 0.15;
	this.friction = 0.8;
	this.set = false;
}

Slime.prototype.addPoint = function(pos) {
	if(!(pos instanceof PVector)) throw("Slime.addPoint needs position as an instance of PVector");
	var p = new SlimyPoint(this, pos);
	this.points.push(p);
	if(this.points.length >= 3) this.set = true;
}

Slime.prototype.removePoint = function(nth) {
	this.points.slice(nth, 1);
}

Slime.prototype.run = function() {
	if(!this.set) return;
	this.update();
	this.viscousUpdate();
	this.display();
}

Slime.prototype.shrinkFrom = function(v, range) {
	if(!(v instanceof PVector)) throw("Slime.shrinkFrom needs position as an instance of PVector");
	v.sub(this.pos);
	for(var i = 0; i < this.points.length; i++) this.points[i].escapeFrom(v, range);
}

Slime.prototype.update = function() {
	this.vel.add(this.acc);
	this.pos.add(this.vel);
	for(var i = 0; i < this.points.length; i++) this.points[i].pos.sub(this.vel);
	this.acc.mult(0);
	this.vel.mult(this.friction);
}

Slime.prototype.viscousUpdate = function() {
	for(var i = 0; i < this.points.length; i++) {
		var prev = i == 0 ? this.points.length-1 : i-1;
		var next = i == this.points.length-1 ? 0 : i+1;
		this.dragOneToOther(this.points[i], this.points[prev]);
		this.dragOneToOther(this.points[i], this.points[next]);
		this.points[i].update();
	}
	this.dragOneToOther(this.points[0], this.points[this.points.length-1]);
	this.dragOneToOther(this.points[0], this.points[1]);
	this.points[0].update();
}

Slime.prototype.dragOneToOther = function(p, other) {
	if(!(p instanceof SlimyPoint) || !(other instanceof SlimyPoint)) throw("Slime.dragOneToOther needs two instances of SlimyPoint");

	var v = p.pos.get();
	var u = other.pos.get();
	var w = PVector.sub(u, v);
	if(w.mag() > this.looseDistance) p.applyForce((w.setMag(w.mag()-this.looseDistance), PVector.mult(w, this.viscosity)));
	else if(w.mag() < this.packedDistance) p.applyForce((w.setMag(this.packedDistance-w.mag()), PVector.mult(w, this.viscosity)));
}

Slime.prototype.display = function() {
	noStroke(); fill(255, 222);
	pushMatrix(); translate(this.pos.x, this.pos.y);
	beginShape();
	for(var i = 0; i < this.points.length; i++) {
		/*NOT WORKING*/ vertex(this.points[i].pos.x, this.points[i].pos.y);
		//ellipse(this.points[i].pos.x, this.points[i].pos.y, 5, 5);
	}
	endShape(CLOSE);
	popMatrix();
}

Slime.prototype.applyForce = function(force) {
	if(!(force instanceof PVector)) throw("Slime.applyForce needs force as an instance of PVector");
	var f = force.get();
	this.acc.add(f);
}

