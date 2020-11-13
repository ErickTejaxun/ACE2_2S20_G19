#include <WiFi.h>
#include <HTTPClient.h>

const int RELE = 23;
boolean mano_rociada;

const int echoPin = 19;
const int trigPin = 18;

void setup() {
  // put your setup code here, to run once:
  pinMode(RELE, OUTPUT); // Configurar relay como salida o OUTPUT
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
  float dist = Distancia_mano();
  Serial.println(dist);
  delay(1000);
  
  if (dist <= 16){
    //mano presente
    if (mano_rociada == false){
      ActivaBomba();  
    }
  }else{
    //mano no presente
    Serial.println("no se detecta nada");
    mano_rociada = false;
  }
}

void ActivaBomba(){
  digitalWrite(RELE, HIGH); // envia señal alta al relay
  delay(350);  
  digitalWrite(RELE, LOW);  // envia señal baja al relay
  mano_rociada = true;
  Serial.println("OBJETO ROCIADO");
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


void EnviarValorServer(int valor){
  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status

    String url_api = "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/fase1/peso";
    HTTPClient http;    //Declare object of class HTTPClient
    
    http.begin(url_api);
    http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
    int httpCode = http.POST("{\"peso\":\"" + String(valor) + "\"}");   //Send the request
    String payload = http.getString();   //Get the response payload
    
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
  }else{
    Serial.println("Error in WiFi connection");   
  }
}
