#include "HX711.h"
#include <SoftwareSerial.h>

HX711 balanza;
SoftwareSerial mySerial(12, 13); // RX, TX

//sensores proximidad
const int sensorIzq = A0;
const int sensorDer = A1;
const int sensorIzq_trasero = A2;
const int sensorDer_trasero = A3;

//sensor de PESO
const int DOUT = A4;
const int CLK = A5;

//puente H
const int ENA = 10;
const int IN1 = 9;
const int IN2 = 8;
const int IN3 = 7;
const int IN4 = 6;
const int ENB = 11; //el pin 5 es PWN de 980Hz mientras que el 10 y 11 son de 490Hz por lo tanto no se usa

//sensor de distancia
const int Trigger = 5;
const int Echo = 4;
const int Trigger_trasero = 3;
const int Echo_trasero = 2;


//estados que se manejaran
boolean punto_partida_sin_peso;
boolean punto_partida_con_peso;
boolean punto_llegada_con_peso;
boolean punto_llegada_sin_peso;

//valores de los 4 sensores de proximidad
int estadoIzq;
int estadoDer;
int estadoIzq_trasero;
int estadoDer_trasero;

int vel_IA = 175; //El motor izquierdo necesita un poco mas de voltaje para que ambos giren a la misma velocidad
int vel_DA = 169;

int vel_IR = 175; //El motor izquierdo necesita un poco mas de voltaje para que ambos giren a la misma velocidad
int vel_DR = 169;

int obs_A;
int obs_R;

unsigned long previousMillis = 0;
const long interval = 1500;

void setup() {
  // put your setup code here, to run once:
  
  Serial.begin(9600);
  mySerial.begin(115200);
  
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  pinMode(ENB, OUTPUT);

  pinMode(Trigger, OUTPUT);
  pinMode(Echo, INPUT);

  pinMode(Trigger_trasero, OUTPUT);
  pinMode(Echo_trasero, INPUT);

  punto_partida_sin_peso=true;
  punto_partida_con_peso=false;
  punto_llegada_con_peso=false;
  punto_llegada_sin_peso=false;

  obs_A = 0;
  obs_R = 0;
  
  calibracion_balanza(); //se calibra y destara el sensor de peso al iniciar
}


void loop() {
  // put your main code here, to run repeatedly:
  if (punto_partida_sin_peso == true){
    GetPeso_puntoPartida();
    
  }else if (punto_partida_con_peso == true){
    viaje_hacia_adelante();
    
  }else if (punto_llegada_con_peso == true){
    GetPeso_puntoLlegada();
    
  }else if (punto_llegada_sin_peso == true){
    viaje_hacia_atras();
  }
  //delay(20);
}


/********************************* HACIA ADELANTE ************************************/
void viaje_hacia_adelante(){    
  Serial.println("entra viaje adelante");
  int obs = Detectar_obstaculo();  
  
  if (obs == 0){    
    
    unsigned long currentMillis = millis();

    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;  // save the last time you blinked the LED
      Enviar_ubicacionEstado(2,2);
    }
    
    estadoIzq = analogRead(sensorIzq);
    estadoDer = analogRead(sensorDer);
  
    if(estadoIzq < 500 && estadoDer < 500){
      //se detecta color blanco o cualquier objeto cercano
      //*** AVANZAR ***/
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, HIGH);
      digitalWrite(IN4, LOW);
 
      analogWrite(ENA, vel_IA);
      analogWrite(ENB, vel_DA);
  
    }else if(estadoIzq > 500 && estadoDer > 500){
      //se detecta color negro o no se detecta nada
      //*** PARAR ***/      
      digitalWrite(IN1, LOW);//
      digitalWrite(IN2, LOW);//
      digitalWrite(IN3, LOW);//
      digitalWrite(IN4, LOW);//
      
      analogWrite(ENA, 0);
      analogWrite(ENB, 0);

      punto_partida_sin_peso = false;
      punto_partida_con_peso = false;
      punto_llegada_con_peso = true;
      punto_llegada_sin_peso = false;

      //paquete entregado: obstaculos?
      //Enviar_infoPaqueteEntregado(GetPeso(), obs_A);
      
    }else if(estadoIzq > 500 && estadoDer < 500){
      //se detecta color negro o no se detecta nada en sensor izquierdo
      //*** CRUZAR IZQUIERDA ***/
      digitalWrite(IN1, LOW);//
      digitalWrite(IN2, LOW);//
      digitalWrite(IN3, HIGH);
      digitalWrite(IN4, LOW);
  
      //analogWrite(ENA, 60);//
      //analogWrite(ENA, 1);      
      analogWrite(ENB, vel_DA);
      
    }else if(estadoIzq < 500 && estadoDer > 500){
      //se detecta color negro o no se detecta nada en sensor derecho
      //*** CRUZAR DERECHA ***/
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);//
      digitalWrite(IN4, LOW);//
  
      analogWrite(ENA, vel_IA);
      //analogWrite(ENB, 58);//
      //analogWrite(ENB, 1);      
    }    
    
  }else{
    digitalWrite(IN1, LOW);//
    digitalWrite(IN2, LOW);//
    digitalWrite(IN3, LOW);//
    digitalWrite(IN4, LOW);//
    
    analogWrite(ENA, 0);
    analogWrite(ENB, 0);


    //estado: detenido por obstaculo?
    unsigned long currentMillis = millis();

    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;  // save the last time you blinked the LED
      Enviar_ubicacionEstado(2,4);
    }

    //obs_A = obs_A + 1;
  }
}


/********************************* HACIA ATRAS ************************************/

void viaje_hacia_atras(){  
  int obs_trasero = Detectar_obstaculo_trasero();
  
  if (obs_trasero == 0){
    unsigned long currentMillis = millis();

    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;  // save the last time you blinked the LED
      Enviar_ubicacionEstado(2,3);
    }
    
  
    estadoIzq_trasero = analogRead(sensorIzq_trasero);
    estadoDer_trasero = analogRead(sensorDer_trasero);
  
    if(estadoIzq_trasero < 500 && estadoDer_trasero < 500){
      //se detecta color blanco o cualquier objeto cercano
      //*** AVANZAR en reversa***/
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
  
      analogWrite(ENA, vel_IR);
      analogWrite(ENB, vel_DR);    
  
    }else if(estadoIzq_trasero > 500 && estadoDer_trasero > 500){
      //se detecta color negro o no se detecta nada
      //*** PARAR ***/
      
      digitalWrite(IN1, LOW);//
      digitalWrite(IN2, LOW);//
      digitalWrite(IN3, LOW);//
      digitalWrite(IN4, LOW);//
      
      analogWrite(ENA, 0);
      analogWrite(ENB, 0);

      punto_partida_sin_peso = true;
      punto_partida_con_peso = false;
      punto_llegada_con_peso = false;
      punto_llegada_sin_peso = false;

      //regreso al buzon: obstaculos?////
      Enviar_infoRegresoBuzon(obs_R);
      
    }else if(estadoIzq_trasero > 500 && estadoDer_trasero < 500){
      //se detecta color negro o no se detecta nada en sensor izquierdo trasero
      //*** CRUZAR IZQUIERDA en reversa ***/
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
  
      //analogWrite(ENA, velIAT);
      //analogWrite(ENA, 0);      
      analogWrite(ENB, vel_DR);
      
    }else if(estadoIzq_trasero < 500 && estadoDer_trasero > 500){
      //se detecta color negro o no se detecta nada en sensor derecho trasero
      //*** CRUZAR DERECHA en reversa ***/
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      digitalWrite(IN3, HIGH);
      digitalWrite(IN4, LOW);
        
      analogWrite(ENA, vel_IR);
      //analogWrite(ENB, velDAT);
      //analogWrite(ENB, 0);
    }
    
  }else{
    digitalWrite(IN1, LOW);//
    digitalWrite(IN2, LOW);//
    digitalWrite(IN3, LOW);//
    digitalWrite(IN4, LOW);//
    
    analogWrite(ENA, 0);
    analogWrite(ENB, 0);

    //estado: detenido por obstaculo
    
    unsigned long currentMillis = millis();

    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;  // save the last time you blinked the LED
      Enviar_ubicacionEstado(2,4);
    }

    //obs_R = obs_R + 1;
    
  }
}


int Detectar_obstaculo(){
  //lectura de distancia de algun obstaculo en el camino, si el obstaculo esta a 20cm o menos envia una señal indicando el obstaculo
  float duration, distance;
  digitalWrite(Trigger, LOW);
  delayMicroseconds(2);

  digitalWrite(Trigger, HIGH);
  delayMicroseconds(10);
  digitalWrite(Trigger, LOW);

  duration = pulseIn(Echo, HIGH);
  distance = (duration / 58.2);

  if(distance > 0 && distance <= 20){
    //si la distancia al obstaculo es menor de 20cm devuelve verdadero (1)
    //Enviar_ubicacionEstado(2,4);
    return 1;
  }else if (distance > 20){
    //si la distancia al obstaculo es mayor de 20.cm (o si no hay obstaculo), devuelve falso (0)
    return 0;
  }else {
    return 1;
  }
}

int Detectar_obstaculo_trasero(){
  //lectura de distancia de algun obstaculo en el camino, si el obstaculo esta a 20cm o menos envia una señal indicando el obstaculo
  float duration, distance;
  digitalWrite(Trigger_trasero, LOW);
  delayMicroseconds(2);

  digitalWrite(Trigger_trasero, HIGH);
  delayMicroseconds(10);
  digitalWrite(Trigger_trasero, LOW);

  duration = pulseIn(Echo_trasero, HIGH);
  distance = (duration / 58.2);

  if(distance > 0 && distance <= 20){
    //si la distancia al obstaculo es menor de 20cm devuelve verdadero (1)
    return 1;
  }else if (distance > 20){
    //si la distancia al obstaculo es mayor de 20.cm (o si no hay obstaculo), devuelve falso (0)
    return 0;
  }else {
    return 1;
  }
}

float GetPeso(){
  return balanza.get_units(20);
}

void GetPeso_puntoPartida(){
  float peso = balanza.get_units(20);
  Serial.print("peso punto partida");
  Serial.println(peso);
  
  if(peso >= 20){
    Enviar_infoSalidaBuzon(peso);
    punto_partida_sin_peso = false;
    punto_partida_con_peso = true;
    punto_llegada_con_peso = false;
    punto_llegada_sin_peso = false;
  }else{
    Enviar_ubicacionEstado(1,1);
  }
}

void GetPeso_puntoLlegada(){
  float peso = balanza.get_units(20);
  
  if(peso > -2 && peso < 20){
    punto_partida_sin_peso = false;
    punto_partida_con_peso = false;
    punto_llegada_con_peso = false;
    punto_llegada_sin_peso = true;
  }else{
    Enviar_ubicacionEstado(3,1);
  }
}

void calibracion_balanza(){
  balanza.begin(DOUT, CLK);
  //Serial.print("Lectura del valor del ADC:  ");
  Serial.println(balanza.read());
  //Serial.println("No ponga ningun  objeto sobre la balanza");
  //Serial.println("Destarando...");
  //Serial.println("...");
  balanza.set_scale(987); // Establecemos la escala
  balanza.tare(20);  //El peso actual es considerado Tara.  
}


void Enviar_ubicacionEstado(int u, int e){
  mySerial.print("U:(" + String(u) + "," + String(e) + ")");
  Serial.print("enviar ubicacioEstado");
  Serial.println("U:(" + String(u) + "," + String(e) + ")");
}

void Enviar_infoSalidaBuzon(float p){
  mySerial.print("S:(" + String(p) + ")");
  Serial.print("enviar info salida buzon");
  Serial.println("S:(" + String(p) + ")");
}

void Enviar_infoPaqueteEntregado(float p, int o){
  mySerial.print("P:(" + String(p) + "," + String(o) + ")");
  
}

void Enviar_infoRegresoBuzon(int o){
  mySerial.print("R:(" + String(o) + ")");  
  Serial.print("enviar info regreso buzon");
  Serial.println("R:(" + String(o) + ")");
}
