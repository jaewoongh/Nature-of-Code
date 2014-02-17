
/****************
** Slime Class **
****************/
function Slime(pos) {
	if(pos instanceof PVector) this.pos = pos.get();
	else this.pos = new PVector(width*0.5, height*0.5);
	this.points = [];
	this.vel = new PVector(0, 0);
	this.acc = new PVector(0, 0);
	this.col = color(0, 222);
	this.looseDistance = 5;
	this.packedDistance = 2;
	this.viscosity = 0.10;
	this.friction = 0.8;
	this.set = false;
	this.dir = Math.random()*PI*2;
	this.oscillation = 0;
	this.oscFreq = 0.1;
	this.oscAmp = 0.6;
	this.offset = new PVector(0, 0);
	this.wasMoving = false;
	this.firstMove = true;
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

Slime.prototype.crawl = function() {
	this.oscillation = Math.sin(frameCount*this.oscFreq)*this.oscAmp;
	if(this.oscillation >= 0) {
		if(this.firstMove) {
			var nokay = true;
			while(nokay) {
				this.dir = Math.random()*PI*2;
				var posPrediction = this.pos.get();
				var movePrediction = PVector.fromAngle(this.dir);
				movePrediction.mult(100);
				posPrediction.add(movePrediction);
				if(!(posPrediction.x < 0 || posPrediction.x >= width || posPrediction.y < 0 || posPrediction.y >= height)) nokay = false;
			}

			for(var i = 0; i < this.points.length; i++) {
				var diff = Math.abs(Math.atan2(Math.sin(this.dir-this.points[i].theta), cos(this.dir-this.points[i].theta)));
				if(diff < PI*0.2) this.points[i].foot = true;	//0.2(rad) is an arbtrary value
				else this.points[i].foot = false;
			}

			this.firstMove = false;
		} else {
			var v = PVector.fromAngle(this.dir);
			v.mult(this.oscillation);
			this.applyForce(v);
			this.wasMoving = true;
		}
	} else {
		if(this.wasMoving) {
			this.wasMoving = false;
			this.resetOrig();
		}
		this.firstMove = true;
	}
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
	if(this.oscillation >= 0) {
		for(var i = 0; i < this.points.length; i++) {
			if(!this.points[i].foot) {
				this.points[i].orig.sub(this.vel);
				this.points[i].pos.sub(this.vel);
			}
		}
		this.offset.add(this.vel);
	}
	this.acc.mult(0);
	this.vel.mult(this.friction);
}

Slime.prototype.resetOrig = function() {
	for(var i = 0; i < this.points.length; i++) {
		if(!this.points[i].foot) this.points[i].orig.add(this.offset);
	}
	this.offset.mult(0);
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
	noStroke(); fill(this.col);
	pushMatrix(); translate(this.pos.x, this.pos.y);
	beginShape();
	for(var i = 0; i < this.points.length; i++) {
		vertex(this.points[i].pos.x, this.points[i].pos.y);
	}
	endShape(CLOSE);
	popMatrix();
}

Slime.prototype.applyForce = function(force) {
	if(!(force instanceof PVector)) throw("Slime.applyForce needs force as an instance of PVector");
	var f = force.get();
	this.acc.add(f);
}

