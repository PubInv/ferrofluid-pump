const int NUM_MAGNETS = 2;

const int PIN_MAG_0 = 3;
const int PIN_MAG_1 = 4;
const int MAG_PINS[NUM_MAGNETS] = {3,4};
// 200 ms with magnets in series seems pretty good, with 0.4 time.
const unsigned int PERIOD_MS = 350;
const float timings[NUM_MAGNETS][2] = { {0.0, 0.4}, {0.0, 0.4} };


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(PIN_MAG_0,OUTPUT);
  pinMode(PIN_MAG_1,OUTPUT);
}

unsigned int time_within_period = 0;
long last_period_start = 0;
long period_number = 0;

int DEBUG_LEVEL = 1;
void loop() {
  // put your main code here, to run repeatedly:
  delay(5);
  unsigned long ms = millis();
  time_within_period = ms - last_period_start;
  Serial.print("time ");
  Serial.println(time_within_period);
  for(int i = 0; i < NUM_MAGNETS; i++) {
    bool MAG_ON = (time_within_period > (((float) PERIOD_MS) * timings[i][0]))
          && (time_within_period < ((float) PERIOD_MS)* timings[i][1]);
    if (DEBUG_LEVEL > 0) {
            Serial.print("mag: ");
            Serial.print(i);
            Serial.print(" ");
            Serial.print((time_within_period > (((float) PERIOD_MS) * timings[i][0])));
            Serial.print(" ");
            Serial.print((time_within_period < ((float) PERIOD_MS)* timings[i][1]));
            Serial.print(" ");
            Serial.println(MAG_ON);
    }
    digitalWrite(MAG_PINS[i],MAG_ON);
  }

  // now check if we are outside of a period
  if (time_within_period > PERIOD_MS) {
    Serial.print("Period: ");
    Serial.println(period_number++);
    digitalWrite(LED_BUILTIN, (period_number % 2));
    last_period_start = ms;
    time_within_period = 0;
  }
}
