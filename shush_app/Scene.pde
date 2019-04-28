import processing.serial.*;
import oscP5.*;
import netP5.*;

class Scene
{
	public Actor actor;
	public SoundSource[] sources;

	public int numSources;
	float maxMagnitude;
	float radius;

	PVector zero;
	PVector center;

	Scene(int numSources) 
	{
		this.numSources = numSources;

		actor = new Actor(this);
		sources = new SoundSource[numSources];
	}

	void init()
	{
		refreshScreenDimensions();
		zero = new PVector(0, 0);
		actor.init();
		
		for (int i=0; i<numSources; i++) 
			sources[i] = new SoundSource(i, this);
	}

	void update()
	{	
		actor.update();

		for (int i=0; i<numSources; i++) 
			sources[i].update();
	}

	void draw()
	{
		pushMatrix();
		translate(center.x, center.y);

		noFill();
		strokeWeight(app.defaultLineWeight/8);
		ellipse(zero.x, zero.y, radius*2, radius*2);

		for (int i=0; i<numSources; i++) 
			sources[i].draw((sources[i].betweenBounds) ? WHITE : BLACKCORAL);

		actor.draw();
		popMatrix();
	}

	void handleShush()
	{
		for (int i=0; i<numSources; i++)
			if (sources[i].betweenBounds) sources[i].handleShush();
	}

	void refreshScreenDimensions()
	{
		center = new PVector(width/2, height/2);
		radius = (width/2)*(15/16.0f);
		maxMagnitude = sqrt(width*width + height*height)/2;
	}
}
