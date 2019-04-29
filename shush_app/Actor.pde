public class Actor
{
	public PVector eyeDir;
	public float eyeAngle;

	public PVector viewBoundRight;
	public PVector viewBoundLeft;

	public float viewBoundRightAngle;
	public float viewBoundLeftAngle;

	public float[] rawgyro;
	public float[] rawacc;

	public float pitch, roll, yaw;
	float dt;

	Scene scene;

	public UDP udp;
	String receivedFromUDP;
	boolean firstPacket = true;

	public Actor(Scene scene)
	{
		this.scene = scene;
		eyeDir = new PVector(mouseX, mouseY);
	}

	void init()
	{
		rawgyro = new float[3];
		rawacc = new float[3];

		udp = new UDP(this, 5555); 
		udp.listen(true);
		dt = 1/60f;
	}

	void update()
	{
		if (DEBUG_ACTOR)
		{
			eyeDir = PVector.sub(app.mouse, scene.center);	
			eyeDir.setMag(scene.radius);
			eyeAngle = atan2(eyeDir.y, eyeDir.x);
		}
		else
		{
			eyeAngle = roll;
			eyeDir = new PVector(scene.radius*cos(eyeAngle), scene.radius*sin(eyeAngle));
		}
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

	//udp receive handling
	void receive(byte[] data, String ip, int portRX)
	{
		// discard buffer the first time
		if (firstPacket)
		{
			firstPacket = false;
			return;
		}

		// udp packet: [timestamp, 3, x, y, z, 4, x, y, z]
		// 3=accelerometer(m/s^2), 4=gyroscope(rad/s)
		String[] s = split(new String(data), ',');
		try 
		{
			if (trim(s[1]).equals("3") && trim(s[5]).equals("4"))
			{
				for (int i=0; i<3; i++) rawacc[i] = float(s[i+2]);
				for (int i=0; i<3; i++) rawgyro[i] = float(s[i+6]);

				pitch += rawgyro[0] * dt;	// around x
				roll += rawgyro[1] * dt;	// around y
				yaw += rawgyro[2] * dt;		// around z
			}
		} 
		catch (ArrayIndexOutOfBoundsException e) {}
	}

	public void recalibrate()
	{
		roll = 0f;
	}
}
