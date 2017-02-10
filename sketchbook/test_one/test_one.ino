// This program is to change the angle of one motor. Some values are not very suitable
// which I have labeled below. 
#define motor_index 10
int in;
int out;
int reading;
//int parameter1;
//int parameter2;
void setup() {
  // put your setup code here, to run once:
  pinMode(motor_index,OUTPUT);
reading = 0;
Serial.begin(9600);
relax();
delay(500);
}

void loop() {
  // put your main code here, to run repeatedly:
if(Serial.available())
{
  reading = Serial.read();
  Serial.print("Action mode rcvd:");
  Serial.println(reading);
  if(reading > 60) //This value(60) could be changed to adjust 
  {
    Serial.print("relax:");
    relax();
    Serial.println(out);
    }
   if(reading <= 60)// So as this one.
   {
    Serial.print("flexion:");
    flexion();
    Serial.println(in);
    }
    Serial.println("Next...");
  }
}

void relax()
{ out = 200 + reading; // These two commonds are to change the angle by input different numbers
  analogWrite(motor_index,out);}
void flexion()
{ in = 80 + reading; // The numbers are adjustable.
  analogWrite(motor_index,in);}

