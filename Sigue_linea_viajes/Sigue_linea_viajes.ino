#include "HX711.h"

HX711 balanza;

//int velCte = 65;
int velCte = 100;
int velGiro = 120;
//int delayGiro = 1;

//puente H
const int ENA = 10;
const int IN1 = 9;
const int IN2 = 8;
const int IN3 = 7;
const int IN4 = 6;
const int ENB = 11;

//sensores proximidad
const int sensorIzq = A0;
const int sensorDer = A1;
const int sensorIzq_trasero = A2;
const int sensorDer_trasero = A3;

//sensor de distancia
const int Trigger = 5;
const int Echo = 4;
const int Trigger_trasero = 3;
const int Echo_trasero = 2;


//sensor de PESO
const int DOUT=A4;
const int CLK=A5;

int estadoIzq;
int estadoDer;
int estadoIzq_trasero;
int estadoDer_trasero;

boolean punto_partida_sin_peso;
boolean punto_partida_con_peso;
boolean punto_llegada_con_peso;
boolean punto_llegada_sin_peso;


void setup() {
  // put your setup code here, to run once:
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

  calibracion_balanza();

}

void loop() {
  // put your main code here, to run repeatedly:

  if (punto_partida_sin_peso == true){
    lectura_balanza2();
  }

  if (punto_partida_con_peso == true){
    viaje_hacia_adelante();
  }
  
  if (punto_llegada_con_peso == true){
    lectura_balanza3(); 
  }

  if (punto_llegada_sin_peso == true){
    viaje_hacia_atras();
  }

}


void viaje_hacia_adelante(){
  int obs = Detectar_obstaculo();
  
    if (obs == 0){
    
      estadoIzq = analogRead(sensorIzq);
      estadoDer = analogRead(sensorDer);
    
      if(estadoIzq < 500 && estadoDer < 500){
        //se detecta color blanco o cualquier objeto cercano
        //*** AVANZAR ***/
        digitalWrite(IN1, HIGH);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, HIGH);
        digitalWrite(IN4, LOW);
    
        analogWrite(ENA, velCte);
        analogWrite(ENB, velCte);    
    
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
        
      }else if(estadoIzq > 500 && estadoDer < 500){
        //se detecta color negro o no se detecta nada en sensor izquierdo
        //*** CRUZAR IZQUIERDA ***/
    
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, HIGH);
        digitalWrite(IN3, HIGH);
        digitalWrite(IN4, LOW);
    
        analogWrite(ENA, velCte);
        //analogWrite(ENA, 0);
        //analogWrite(ENB, velGiro);
        analogWrite(ENB, velCte);
    
        //delay(delayGiro);
        
      }else if(estadoIzq < 500 && estadoDer > 500){
        //se detecta color negro o no se detecta nada en sensor derecho
        //*** CRUZAR DERECHA ***/
        digitalWrite(IN1, HIGH);
        digitalWrite(IN2, LOW);
        digitalWrite(IN3, LOW);
        digitalWrite(IN4, HIGH);
    
        //analogWrite(ENA, velGiro);
        analogWrite(ENA, velCte);
        analogWrite(ENB, velCte);
        //analogWrite(ENB, 0);
        
        //delay(delayGiro);
      }
      
    }else{
      digitalWrite(IN1, LOW);//
      digitalWrite(IN2, LOW);//
      digitalWrite(IN3, LOW);//
      digitalWrite(IN4, LOW);//
      
      analogWrite(ENA, 0);
      analogWrite(ENB, 0);
    }
}


void viaje_hacia_atras(){
  
  int obs_trasero = Detectar_obstaculo_trasero();
  
  if (obs_trasero == 0){
  
    estadoIzq_trasero = analogRead(sensorIzq_trasero);
    estadoDer_trasero = analogRead(sensorDer_trasero);
  
    if(estadoIzq_trasero < 500 && estadoDer_trasero < 500){
      //se detecta color blanco o cualquier objeto cercano
      //*** AVANZAR en reversa***/
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
  
      analogWrite(ENA, velCte);
      analogWrite(ENB, velCte);    
  
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
      
      
    }else if(estadoIzq_trasero > 500 && estadoDer_trasero < 500){
      //se detecta color negro o no se detecta nada en sensor izquierdo
      //*** CRUZAR IZQUIERDA en reversa ***/
  
      digitalWrite(IN1, HIGH);
      digitalWrite(IN2, LOW);
      digitalWrite(IN3, LOW);
      digitalWrite(IN4, HIGH);
  
      analogWrite(ENA, velCte);
      //analogWrite(ENA, 0);
      //analogWrite(ENB, velGiro);
      analogWrite(ENB, velCte);
  
      //delay(delayGiro);
      
    }else if(estadoIzq_trasero < 500 && estadoDer_trasero > 500){
      //se detecta color negro o no se detecta nada en sensor derecho
      //*** CRUZAR DERECHA en reversa ***/
      digitalWrite(IN1, LOW);
      digitalWrite(IN2, HIGH);
      digitalWrite(IN3, HIGH);
      digitalWrite(IN4, LOW);
  
      //analogWrite(ENA, velGiro);
      analogWrite(ENA, velCte);
      analogWrite(ENB, velCte);
      //analogWrite(ENB, 0);
      
      //delay(delayGiro);
    }
    
  }else{
    digitalWrite(IN1, LOW);//
    digitalWrite(IN2, LOW);//
    digitalWrite(IN3, LOW);//
    digitalWrite(IN4, LOW);//
    
    analogWrite(ENA, 0);
    analogWrite(ENB, 0);
  }
}


int Detectar_obstaculo(){
  //lectura de distancia de algun obstaculo en el camino, al llegar a menos de 15cm del obstaculo se detiene
  float duration, distance;
  digitalWrite(Trigger, LOW);
  delayMicroseconds(2);

  digitalWrite(Trigger, HIGH);
  delayMicroseconds(10);
  digitalWrite(Trigger, LOW);

  duration = pulseIn(Echo, HIGH);
  distance = (duration / 58.2);


  if(distance > 0 && distance <= 20){
    //si la distancia al obstaculo es menor de 20cm devuelve 0
    return 1;
  }else if (distance > 20){
    //si la distancia al obstaculo es mayor de 20.cm (o si no hay obstaculo), devuelve 1
    return 0;
  }else {
    return 1;
  }
}


int Detectar_obstaculo_trasero(){
  //lectura de distancia de algun obstaculo en el camino, al llegar a menos de 15cm del obstaculo se detiene
  float duration, distance;
  digitalWrite(Trigger_trasero, LOW);
  delayMicroseconds(2);

  digitalWrite(Trigger_trasero, HIGH);
  delayMicroseconds(10);
  digitalWrite(Trigger_trasero, LOW);

  duration = pulseIn(Echo_trasero, HIGH);
  distance = (duration / 58.2);


  if(distance > 0 && distance <= 20){
    //si la distancia al obstaculo es menor de 20cm devuelve 0
    return 1;
  }else if (distance > 20){
    //si la distancia al obstaculo es mayor de 20.cm (o si no hay obstaculo), devuelve 1
    return 0;
  }else {
    return 1;
  }
}


void calibracion_balanza(){
  balanza.begin(DOUT, CLK);
  Serial.print("Lectura del valor del ADC:  ");
  Serial.println(balanza.read());
  Serial.println("No ponga ningun  objeto sobre la balanza");
  Serial.println("Destarando...");
  Serial.println("...");
  balanza.set_scale(987); // Establecemos la escala
  balanza.tare(20);  //El peso actual es considerado Tara.  
}


float lectura_balanza(){
  return balanza.get_units(20);
}


void lectura_balanza2(){
    if (balanza.get_units(20) >= 20){
      punto_partida_sin_peso = false;
      punto_partida_con_peso = true;
      punto_llegada_con_peso = false;
      punto_llegada_sin_peso = false;
    }
}

void lectura_balanza3(){
  float peso = balanza.get_units(20);
  
  if (peso > -2 && peso < 19 ){      
    punto_partida_sin_peso = false;
    punto_partida_con_peso = false;
    punto_llegada_con_peso = false;
    punto_llegada_sin_peso = true;
  }
}
