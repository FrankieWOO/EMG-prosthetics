#define motor_thumb 10
#define motor_index 3
#define motor_middle 9

int pos1;
int pos2;
int reading;
void setup() {
  //
  pinMode(motor_thumb,OUTPUT);
  pinMode(motor_index,OUTPUT);
  pinMode(motor_middle,OUTPUT);
  reading = 0;
  Serial.begin(9600);
  palm_relax();
  delay(500);
}


void loop() {
  //

  //pos1 = 180;
  //pos2 = 180;
  //180-230 for index-pinky fingers
  //analogWrite(motor_index,pos1);
  //analogWrite(motor_middle,pos1);
  //180-240 for thumb
  //analogWrite(motor_thumb,pos2);

  //fist_flexion();
  //palm_relax();
  if(Serial.available()){
    reading = Serial.read();
    Serial.print('Action mode received:');
    Serial.println(reading);
  }
}

//---------define gestures------------//
// natural palm gesture, code 0
void palm_relax(){
  analogWrite(motor_index,180);
  analogWrite(motor_middle,180);
  analogWrite(motor_thumb,180);
}
// fist contraction, code 1
void fist_flexion(){
  analogWrite(motor_index,220);
  analogWrite(motor_middle,220);
  analogWrite(motor_thumb,220);
}
// use index to point, code 2
void index_pointing(){
  analogWrite(motor_index,180);
  analogWrite(motor_middle,220);
  analogWrite(motor_thumb,220);
}
// wrist extension, code 3
void wrist_extension(){
  analogWrite(motor_index,220);
  analogWrite(motor_middle,180);
  analogWrite(motor_thumb,180);
}
// wrist flexion, code 4
void wrist_flexion(){
  analogWrite(motor_index,180);
  analogWrite(motor_middle,220);
  analogWrite(motor_thumb,180);
}
// index and thumb grip, code 5
void grip_it(){
  analogWrite(motor_index,220);
  analogWrite(motor_middle,180);
  analogWrite(motor_thumb,220);
}

