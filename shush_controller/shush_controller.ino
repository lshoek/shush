const int trigPin = 4;
const int echoPin = 5;

long duration;
int dist;

int frameIndex = 0;

const int MAX_DIST = 255;
const int NUM_DISTREADS = 8;
uint8_t distreads[NUM_DISTREADS];

void setup() 
{
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);
    Serial.begin(9600);

    for (int i=0; i<NUM_DISTREADS; i++) distreads[i] = MAX_DIST+1;
}

void loop() 
{
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);

    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);

    digitalWrite(trigPin, LOW);

    duration = pulseIn(echoPin, HIGH);
    dist = duration * 0.034/2;
    dist = min(dist, 255);

    int totaldist = 0;
    for (int i=0; i<NUM_DISTREADS; i++) totaldist += distreads[i];
    totaldist = totaldist / NUM_DISTREADS;

    if (dist == MAX_DIST && totaldist < MAX_DIST/2)
    {
        dist = distreads[NUM_DISTREADS-1];
    }
    distreads[frameIndex] = dist;

    frameIndex++;
    frameIndex%=NUM_DISTREADS;

    delay(25);

    Serial.write(dist);
}
