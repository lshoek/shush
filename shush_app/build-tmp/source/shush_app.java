import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class shush_app extends PApplet {





int APRICOT = 0xffffcdbc;
int BLACKCORAL = 0xff69a197;

int lineWeight = 8;
int numCircles = 16;
int numPoints = 8;
float radius = 50;
float pointerSize = 50;

Serial port = null;
int data = 0;
boolean arduinoAvailable = false;

OscP5 osc;
NetAddress localhost;

PVector center;
PVector mouse;

public void setup()
{
    
    background(APRICOT);
    rectMode(CENTER);
    strokeWeight(lineWeight);
    noCursor();

    String[] ports = Serial.list();
    if (ports.length > 0)
    {
        String portname = Serial.list()[0];
        port = new Serial(this, portname, 9600);
        println(portname);
    }
    osc = new OscP5(this, 12000);
    localhost = new NetAddress("127.0.0.1", 8000);

    mouse = new PVector(mouseX, mouseY);
    center = new PVector(width/2, height/2);
}

public void draw()
{ 
    background(APRICOT);

    // update
    arduinoAvailable = (port != null) && (port.available() > 0);
    if (arduinoAvailable)
    {
        data = port.read();
    }

    center = new PVector(width/2, height/2);
    mouse = new PVector(mouseX, mouseY);

    float maxMag = sqrt(width*width + height*height)/2;
    float minMag = maxMag/8;

    mouse.sub(center);
    if (mouse.mag() < minMag) mouse.setMag(minMag);
    mouse.add(center);

    float dist = dist(mouse.x, mouse.y, center.x, center.y);
    dist = map(dist, 0, maxMag, 0, 1);

    float angle = atan2(mouse.y-center.y, mouse.x-center.x);
    angle = map(angle, -PI, PI, 0, 1);

    // draw scene
    pushMatrix();

    strokeWeight((lineWeight/2)*(1-dist));
    line(center.x, center.y, mouse.x, mouse.y);

    //drawPoint(center, minMag*2, lineWeight/8, BLACKCORAL, false, null);

    drawPoint(center, pointerSize, lineWeight, BLACKCORAL, true, "participant");
    drawPoint(mouse, (pointerSize/2) * (1-dist), lineWeight * (1-dist), BLACKCORAL, false, "sound source");
    popMatrix();

    // draw gui
    fill(255, 255, 255);
    text("data: " + data, 20, 20);
    text("dist: " + dist, 20, 40);
    text("angle: " + angle, 20, 60);

    // osc
    sendOSC("/dist", dist);
    sendOSC("/angle", angle);
}

public void sendOSC(String oscMsg, float oscData)
{
    OscMessage msg = new OscMessage(oscMsg);
    msg.add(oscData);
    osc.send(msg, localhost);
} 

public void drawPoint(PVector p, float diam, float weight, int col, boolean stroke, String id)
{
    if (stroke)
    {
        noStroke();
        fill(col);
    } 
    else
    {
        noFill();
        stroke(col);
        strokeWeight(weight);
    }
    ellipse(p.x, p.y, diam, diam);

    if (id != null) text(id, p.x+diam*0.67f, p.y-diam*0.67f);    
}
  public void settings() {  size(720, 720); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "shush_app" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
