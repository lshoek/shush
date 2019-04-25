import processing.serial.*;
import oscP5.*;
import netP5.*;

final color APRICOT = #ffcdbc;
final color BLACKCORAL = #69a197;
final color WHITE = #ffffff;

public final int MAX_SOURCES = 4;

App app = new App(this);

int clicks = 0;

void setup()
{
	// settings
	size(720, 720);
	rectMode(CENTER);

	app.init();
}

void draw()
{
	app.update();
	app.draw();
}

void mouseClicked()
{
	clicks++;
	app.scene.handleShush();
}

class App
{
	PApplet applet;

	OscP5 osc;
	NetAddress localhost;

	Scene scene;

	boolean shush = false;
	public PVector mouse;

	int data = 0;
	int shushcount = 0;

	int txtspacing = 16;
	int defaultLineWeight = 8;
	float defaultSize = 32.0f;

	public App(PApplet applet)
	{
		this.applet = applet;

		// osc communication
		osc = new OscP5(this, 12000);
		localhost = new NetAddress("localhost", 8000);

		mouse = new PVector(mouseX, mouseY);
		scene = new Scene(MAX_SOURCES);
	}

	void init()
	{
		scene.init();
	}

	void update()
	{
		mouse = new PVector(mouseX, mouseY);
		scene.update();

		// handle shush
		if (shush)
		{
			scene.handleShush();
			shushcount++;
			shush = false;
		}

		// send osc
		for (int i=0; i<scene.numSources; i++)
		{
			float normphi = map(scene.sources[i].angle, -PI, PI, 0, 1);
			sendSourceOSC("/" + scene.sources[i].id,  scene.sources[i].dist, normphi);
			scene.sources[i].relocated = false;
		}
		OscMessage msg = new OscMessage("/actor");
		float normphi = map(scene.actor.eyeAngle, -PI, PI, 0, 1);
		msg.add(normphi);
		osc.send(msg, localhost);
	}

	void draw()
	{
		background(APRICOT);
		scene.draw();

		// gui
		fill(BLACKCORAL);
		text("shushes: " + shushcount, 20, 20);
		text("angle: " + scene.actor.eyeAngle, 20, 20+txtspacing);
	}

	void sendSourceOSC(String id, float angle, float dist)
	{
		OscMessage msg = new OscMessage(id);
		msg.add(angle);
		msg.add(dist);
		osc.send(msg, localhost);
	} 

	// events
	void oscEvent(OscMessage msg) 
	{
		if (msg.addrPattern().equals("/shush"))
		{
			int content = msg.get(0).intValue();
			shush = (content == 1);
		}
	}

	void serialEvent(Serial p) 
	{ 
		data = (int)p.read();
		println(data);
	} 
}