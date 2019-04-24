import processing.serial.*;
import oscP5.*;
import netP5.*;

class Scene
{
	public Actor actor;
	public SoundSource[] sources;

	public int numSources;
	float maxMagnitude;

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
		// vectors
		zero = new PVector(0, 0);
		center = new PVector(width/2, height/2);

		// sources
		for (int i=0; i<numSources; i++) 
			sources[i] = new SoundSource(random(0, 1)*10.0f, app.defaultSize/8, i, this);
	}

	void update()
	{
		center = new PVector(width/2, height/2);
		maxMagnitude = sqrt(width*width + height*height)/2;
		actor.update();

		for (int i=0; i<numSources; i++) 
			sources[i].update();
	}

	void draw()
	{
		pushMatrix();
		translate(center.x, center.y);

		for (int i=0; i<numSources; i++) 
			sources[i].draw((sources[i].betweenBounds) ? WHITE : BLACKCORAL);

		actor.draw();
		popMatrix();
	}

	void handleShush()
	{
		for (int i=0; i<numSources; i++)
			if (sources[i].betweenBounds) sources[i].relocate();
	}
}
