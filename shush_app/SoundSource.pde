class SoundSource
{
	public PVector location;
	public float range;
	public float size;
	public int id;

	public float dist = 1.0f;
	public float angle = 1.0f;

	public boolean betweenBounds = false;
	public boolean relocated = true;

	Scene scene;

	SoundSource(float range, float size, int id, Scene scene)
	{
		this.range = range;
		this.size = size;
		this.id = id;
		this.scene = scene;
		relocate();
	}

	void update()
	{
		dist = dist(location.x, location.y, 0, 0);
		dist = map(dist, 0, scene.maxMagnitude, 0, 1);

		angle = atan2(location.y, location.x);
		angle = map(angle, -PI, PI, 0, 1);

		betweenBounds = isBetweenBounds(scene.actor.viewBoundRightAngle, scene.actor.viewBoundLeftAngle);
	}

	void draw(color col)
	{
		noFill();
		stroke(col);
		strokeWeight(app.defaultLineWeight);

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
		location = new PVector(random(-1, 1)*(width/2), random(-1, 1)*(height/2));
		relocated = true;
	}
}
