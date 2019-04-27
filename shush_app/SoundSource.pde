class SoundSource
{
	public float dist = 1.0f;
	public float angle = 1.0f;

	public int id;

	public boolean betweenBounds = false;
	public boolean relocated = true;

	float oscillation;
	float offset;

	float absoluteDist = 1.0f;
	float size = 8.0f;

	Scene scene;

	SoundSource(int id, Scene scene)
	{
		this.id = id;
		this.scene = scene;
		relocate();
	}

	void update()
	{
		float oscillateDist = sin(millis()/2000.0f + offset) * oscillation;
		dist = absoluteDist + oscillateDist;

		// debug soundsource
		//dist = PVector.sub(app.mouse, scene.center).mag();
		//angle = scene.actor.eyeAngle;

		betweenBounds = isBetweenBounds(scene.actor.viewBoundRightAngle, scene.actor.viewBoundLeftAngle);
	}

	void draw(color col)
	{
		noFill();
		stroke(col);
		strokeWeight(app.defaultLineWeight);

		PVector location = new PVector(dist*cos(angle), dist*sin(angle));
		ellipse(location.x, location.y, size, size);

		fill(col);
		text("id:source" + id, location.x+size*3.0f, location.y-size);
		text("angle:" + angle, location.x+size*3.0f, location.y-size+app.txtspacing);
		text("dist:" + dist, location.x+size*3.0f, location.y-size+app.txtspacing*2); 
	}

	boolean isBetweenBounds(float left, float right)
	{
		if (left < right)
		{
			if (left < angle && angle < right)
			{
				return true;
			}
		}
		else if (angle > left && angle > right)
		{
			return true;
		}
		else if (angle < left && angle < right)
		{
			return true;
		}
		return false;
	}

	public void relocate()
	{
		absoluteDist = random(scene.radius/16, scene.radius);
		dist = absoluteDist;
		angle = random(-PI, PI);

		offset = random(0, 1);
		oscillation = random(15, 30);

		relocated = true;
	}
}
