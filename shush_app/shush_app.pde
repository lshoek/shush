import java.net.InetAddress; 
import java.net.UnknownHostException; 
import processing.serial.*;
import hypermedia.net.*;
import oscP5.*;
import netP5.*;

final color APRICOT = #ffcdbc;
final color BLACKCORAL = #69a197;
final color WHITE = #ffffff;

// number of sound sources
public int MAX_SOURCES = 4;

// debug shush range
public boolean DEBUG_ACTOR = false;

// calibration
public boolean DEBUG_SOUNDSOURCE = false;

String ip;
int clicks = 0;

App app = new App(this);

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
	if (DEBUG_ACTOR)
	{
		clicks++;
		app.scene.handleShush();
	}
	else
	{
		app.scene.actor.recalibrate();
	}
}

void keyPressed() 
{
	// x
	if (key == 120)
	{ 
		DEBUG_SOUNDSOURCE = !DEBUG_SOUNDSOURCE;
		return;
	}

	// 0-9
	int k = key-48;
	if (k<MAX_SOURCES && k>=0) 
		app.scene.sources[k].active = !app.scene.sources[k].active;
}

class App
{
	PApplet applet;

	OscP5 osc;
	NetAddress localhost;
	NetAddress hostaddress;

	Scene scene;

	boolean shush = false;
	public PVector mouse;

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
		try { ip = split(InetAddress.getLocalHost().toString(), '/')[1]; } catch (UnknownHostException e) {} 
	}

	void init()
	{
		scene.init();
	}

	void update()
	{
		mouse = new PVector(mouseX, mouseY);

		// handle shush
		if (shush)
		{
			scene.handleShush();
			shush = false;
		}
		scene.update();

		// send osc
		for (int i=0; i<scene.numSources; i++)
		{
			float normphi = map(scene.sources[i].angle, -PI, PI, 0, 1);
			float normdist = map(scene.sources[i].dist, 0, scene.radius, 0, 1);
			normdist = constrain(normdist, 0, 1);

			int status = -1;
			if (scene.sources[i].active)
			{
				status = (scene.sources[i].shushedAt) ? 1 : 0;
			}
			sendSourceOSC("/" + scene.sources[i].id,  normphi, normdist, status);
			scene.sources[i].shushedAt = false;
		}
	}

	void draw()
	{
		background(APRICOT);
		scene.draw();

		// gui
		fill(BLACKCORAL);
		text("shush v0.9 -- lesley van hoek", 20, 20);
		text("ip: " + ip, 20, 20+txtspacing*1);

		text("debugsound: " + DEBUG_SOUNDSOURCE, 20, 20+txtspacing*2);
		text("debugactor: " + DEBUG_ACTOR, 20, 20+txtspacing*3);
		for (int i=0; i<MAX_SOURCES; i++)
		{
			text(scene.sources[i].id + ": " + scene.sources[i].active, 20, 
				20+txtspacing*4+txtspacing*i);
		}
		text("[x] toggle soundsource debugging", 20, height-txtspacing*2);
		text("[0-9] toggle soundsource activity", 20, height-txtspacing);
	}

	void sendSourceOSC(String id, float angle, float dist, int status)
	{
		OscMessage msg = new OscMessage(id);
		msg.add(angle);
		msg.add(dist);
		msg.add(status);
		osc.send(msg, localhost);
	} 

	// events
	void oscEvent(OscMessage msg) 
	{
		if (!DEBUG_ACTOR)
		{
			if (msg.addrPattern().equals("/shush"))
			{
				int content = msg.get(0).intValue();
				shush = (content == 1);
			}
		}
	}
}
