#include "HX711.h"
#include <WiFi.h>
#include <HTTPClient.h>

HX711 balanza;

const int RELE = 23;
const int RELE_buzon = 15;
const int BALANZA_DT = 4;
const int BALANZA_SCK = 2;
const int echoPin = 19;
const int trigPin = 18;

boolean ObjetoRociado;
boolean mano_rociada;


void setup() {
  // put your setup code here, to run once:
  pinMode(RELE, OUTPUT); // Configurar relay como salida o OUTPUT
  pinMode(RELE_buzon, OUTPUT);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  Serial.begin(115200);

  InicializarBalanza();
  InicializarWiFi();
}

void loop() {
  // put your main code here, to run repeatedly:
  if (balanza.is_ready()){
    delay(400);
    float peso = balanza.get_units(10);
    delay(400);
    Serial.println(peso);
    if(peso > 10){
      if (ObjetoRociado == false){
        ActivaBomba_buzon();
        EnviarValorServer("buzon", 1);
      }
    }else{
      ObjetoRociado = false;
    }
  }


  float dist = Distancia_mano();
  Serial.println(dist);
  delay(500);
  
  if (dist <= 16){
    //mano presente
    if (mano_rociada == false){
      ActivaBomba_dispensador();
      //EnviarValorServer("dispensador", 1);
    }
  }else{
    //mano no presente
    Serial.println("no se detecta nada");
    mano_rociada = false;
  }

}


void InicializarBalanza(){
  balanza.begin(BALANZA_DT, BALANZA_SCK);
  delay(250);
  balanza.set_scale(896.9);
  balanza.tare(10);  // Hacer 10 lecturas, el promedio es la tara
}


void InicializarWiFi(){
  WiFi.begin("TURBONETT_F9AC27", "15D9352E14");   //WiFi connection
  while (WiFi.status() != WL_CONNECTED)
  {   
    delay(500);
    Serial.print(".");
  }
    
  Serial.println("WiFi connected..!");
  Serial.print("Got IP: ");  Serial.println(WiFi.localIP());
}


float Distancia_mano(){
  //lectura de distancia del sensor las manos de la persona
  float duration, distance;
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);
  distance = (duration / 58.2);

  return distance;
}


void ActivaBomba_dispensador(){
  digitalWrite(RELE, HIGH); // envia señal alta al relay
  delay(300);  
  digitalWrite(RELE, LOW);  // envia señal baja al relay
  mano_rociada = true;
  Serial.println("MANOS ROCIADAS");
}


void ActivaBomba_buzon(){
  digitalWrite(RELE_buzon, HIGH); // envia señal alta al relay
  delay(1300);
  
  digitalWrite(RELE_buzon, LOW);  // envia señal baja al relay
  ObjetoRociado = true;
  Serial.println("OBJETO ROCIADO");  
}


void EnviarValorServer(String tipo, float valor){
  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status

    String url_buzon = "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/ace2-proy-2/paquete";
    String url_dispensador = "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/fase1/peso";
    HTTPClient http;    //Declare object of class HTTPClient
    int httpCode;

    if(tipo == "buzon"){
      http.begin(url_buzon);
      http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
       httpCode = http.POST("{\"paquete\":\"" + String(valor) + "\"}");   //Send the request
      
    }else if(tipo == "dispensador"){
      http.begin(url_dispensador);
      http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
      httpCode = http.POST("{\"peso\":\"" + String(valor) + "\"}");   //Send the request
    }
    
    String payload = http.getString();   //Get the response payload
    
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
  }else{
    Serial.println("Error in WiFi connection");
  }
}
