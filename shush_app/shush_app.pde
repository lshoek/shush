import java.net.InetAddress; 
import java.net.UnknownHostException; 
import processing.serial.*;
import hypermedia.net.*;
import oscP5.*;
import netP5.*;

final color APRICOT = #ffcdbc;
final color BLACKCORAL = #69a197;
final color WHITE = #ffffff;

public int MAX_SOURCES = 4;
public final boolean DEBUG = false;
public final boolean DEBUG_SOUNDSOURCE = false;

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
	if (DEBUG)
	{
		clicks++;
		app.scene.handleShush();
	}
	else
	{
		app.scene.actor.recalibrate();
	}
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

			int status = (scene.sources[i].shushedAt) ? 1 : 0;

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
		text("ip: " + ip, 20, 20);
		text("angle: " + scene.actor.eyeAngle, 20, 20+txtspacing);
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
		if (!DEBUG)
		{
			if (msg.addrPattern().equals("/shush"))
			{
				int content = msg.get(0).intValue();
				shush = (content == 1);
			}
		}
	}
}
