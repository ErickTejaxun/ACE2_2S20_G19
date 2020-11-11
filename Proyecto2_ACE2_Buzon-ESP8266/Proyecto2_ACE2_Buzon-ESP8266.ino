#include "HX711.h"
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

HX711 balanza;

const int BALANZA_DT = 14;
const int BALANZA_SCK = 12;
const int RELE = 13;

boolean ObjetoRociado;

void setup() {
  // put your setup code here, to run once:
  
  pinMode(RELE, OUTPUT); // Configurar relay como salida o OUTPUT
  Serial.begin(115200);
  
  InicializarBalanza();
  InicializarWiFi();

}

void loop() {
  // put your main code here, to run repeatedly:
  if (balanza.is_ready()){
    
    delay(1000);
    
    float peso = balanza.get_units(10);

    if(peso > 10){
      if (ObjetoRociado == false){
        ActivaBomba();
        EnviarValorServer(peso);
      }
    }else{
      if(ObjetoRociado == true){
        EnviarValorServer(peso); //para enviar la hora a la que se retiró el objeto
        ObjetoRociado = false;
      }
    }
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

void ActivaBomba(){
  digitalWrite(RELE, HIGH); // envia señal alta al relay
  delay(1800);
  
  digitalWrite(RELE, LOW);  // envia señal baja al relay
  ObjetoRociado = true;
  //Serial.println("OBJETO ROCIADO");
  //https://www.facebook.com/gerallchavezn/posts/2840919386230832
}


void EnviarValorServer(float peso){
  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status
    
    std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
    client->setInsecure();
        
    HTTPClient http;    //Declare object of class HTTPClient
    
    http.begin(*client, "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/fase1/peso");
    http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
    int httpCode = http.POST("{\"peso\":\"" + String(peso) + "\"}");   //Send the request
    String payload = http.getString();   //Get the response payload
    
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
  }else{
    Serial.println("Error in WiFi connection");   
  }
}
