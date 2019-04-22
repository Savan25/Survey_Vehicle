#define IN1 8
#define IN2 9
#define IN3 10
#define IN4 11

int Steps = 0;
boolean start = true;

void setup() {
  Serial.begin(9600);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
}

void loop() {
  while(start){
    stepper();
    Serial.print(Steps);
    Serial.print("\n");
    Steps++;
    delayMicroseconds(5000);
    if(Steps == 2048){
      start = false;
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
    }
  }
}

void stepper() {
  switch (Steps%4) {
    case 0:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
      break;

    case 1:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, HIGH);
      digitalWrite(IN4, LOW); // HIGH
      break;
        
    case 2:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH); // LOW
      digitalWrite(IN3, LOW); // HIGH
      digitalWrite(IN4, LOW);
      break;

    case 3:
      digitalWrite(IN1, HIGH); // LOW
      digitalWrite(IN2, LOW); // HIGH
      digitalWrite(IN3, LOW); // HIGH
      digitalWrite(IN4, LOW);
      break;
        
    /*case 4:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      break;
        
    case 5:
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, HIGH);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      break;
      
    case 6:
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      break;
      
    case 7:
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
      break;*/
      
    default:
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, LOW);
      break;
  }
}
