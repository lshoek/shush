class Actor
{
	public PVector eyeDir;
	public float eyeAngle;

	public PVector viewBoundRight;
	public PVector viewBoundLeft;

	public float viewBoundRightAngle;
	public float viewBoundLeftAngle;

	Scene scene;

	Serial port = null;
	int data = 0;
	boolean arduinoAvailable = false;

	public Actor(Scene scene)
	{
		this.scene = scene;
		eyeDir = new PVector(mouseX, mouseY);
	}

	void init()
	{
		// serial communication
		String[] ports = Serial.list();
		if (ports.length > 0)
		{
			String portname = "COM6";
			boolean available = false;

			for (int i=0; i < ports.length; i++)
			{
				if (portname.equals(ports[i]))
				{
					port = new Serial(app.applet, portname, 38400);
					println(portname);
					available = true;
				}
			}
			if (!available) println(portname + " busy or unavailable");
		}
	}

	void update()
	{
		// debug: driven by mouse
		eyeDir = PVector.sub(app.mouse, scene.center);	
		eyeDir.setMag(scene.radius);
		eyeAngle = atan2(eyeDir.y, eyeDir.x);

		viewBoundRight = eyeDir.copy().rotate(-PI/4);
		viewBoundLeft = eyeDir.copy().rotate(PI/4);

		viewBoundRightAngle = atan2(viewBoundRight.y, viewBoundRight.x);
		viewBoundLeftAngle = atan2(viewBoundLeft.y, viewBoundLeft.x);
	}

	void draw()
	{
		PVector p = scene.zero;

		stroke(BLACKCORAL);
		strokeWeight(app.defaultLineWeight/4);
		line(p.x, p.y, viewBoundRight.x, viewBoundRight.y);
		line(p.x, p.y, viewBoundLeft.x, viewBoundLeft.y);

		fill(APRICOT);
		strokeWeight(app.defaultLineWeight/2);
		ellipse(p.x, p.y, app.defaultSize, app.defaultSize);

		fill(BLACKCORAL);
		text("id:actor", p.x+app.defaultSize*0.5f, p.y-app.defaultSize*0.5f);  
	}
}
