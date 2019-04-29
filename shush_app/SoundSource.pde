class SoundSource
{
	public float dist = 1.0f;
	public float angle = 1.0f;

	public int id;

	public boolean active = true;
	public boolean betweenBounds = false;
	boolean shushedAt = false;

	float approachTime;
	float speed;
	float oscillation;
	float offset;
	boolean clockwise;

	float absoluteDist = 1.0f;
	float size = 8.0f;

	boolean recovering = false;
	float recoveryTime = 2000.0f;
	float lastShushedAt;
	float lastRelocated;

	Scene scene;
	Behavior behavior;

	SoundSource(int id, Scene scene)
	{
		this.id = id;
		this.scene = scene;
		relocate();
	}

	void update()
	{
		if (recovering)
		{
			if (millis() > lastShushedAt + recoveryTime)
			{
				recovering = false;
				relocate();
			}
		}

		float oscillateDist = sin(millis()/2000f + offset) * oscillation;
		if (behavior == Behavior.OSCILLATE)
		{
			dist = absoluteDist + oscillateDist;
		}
		else if (behavior == Behavior.APPROACH) 
		{
			float mapping = map(millis(), lastRelocated, lastRelocated + approachTime, 0, 1);
			mapping = constrain(mapping, 0f, 1f);
			dist = map(sqrt(abs(sin(PI*(mapping)/2f))), 0, 1, scene.radius, oscillation+10);
		} 
		else if (behavior == Behavior.TRAVEL)
		{
			dist = absoluteDist + oscillateDist;
			float pct = (millis()/40000f*speed)%1f;
			angle = clockwise ? map(pct, 0, 1, -PI, PI) : map(pct, 0, 1, PI, -PI);
		}
		if (DEBUG_SOUNDSOURCE)
		{
			PVector mouseDir = PVector.sub(app.mouse, scene.center);
			mouseDir.setMag(scene.radius);
			dist = PVector.sub(app.mouse, scene.center).mag();
			angle = atan2(mouseDir.y, mouseDir.x);
		}
		betweenBounds = isBetweenBounds(scene.actor.viewBoundRightAngle, scene.actor.viewBoundLeftAngle);
	}

	void draw(color col)
	{
		if (active)
		{
			noFill();
			stroke(col);
			strokeWeight(app.defaultLineWeight);

			float rec = (recovering) ? 0.5f : 1.0f;
			PVector location = new PVector(dist*cos(angle), dist*sin(angle));
			ellipse(location.x, location.y, size*rec, size*rec);

			text("id:source" + id, location.x+size*3.0f, location.y-size);
			text("angle:" + angle, location.x+size*3.0f, location.y-size+app.txtspacing);
			text("dist:" + dist, location.x+size*3.0f, location.y-size+app.txtspacing*2);
			text("behavior:" + behavior, location.x+size*3.0f, location.y-size+app.txtspacing*3);
		}
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

	void relocate()
	{
		lastRelocated = millis();

		absoluteDist = random(scene.radius/16, scene.radius);
		dist = absoluteDist;

		approachTime = random(10000, 30000);
		angle = random(-PI, PI);
		speed = random(1, 2);
		offset = random(0, 1);
		clockwise = (random(0, 1) > 0.5f) ? true : false;

		oscillation = random(15, 30);
		behavior = Behavior.values()[int(random(0, Behavior.values().length))];
	}

	public void handleShush()
	{
		lastShushedAt = millis();
		shushedAt = true;
		recovering = true;
	}
}

public static enum Behavior 
{
	OSCILLATE,
	APPROACH,
	TRAVEL
}
