#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

const int RELE = 15;
const int sensor_prox = 2;
boolean mano_no_presente;
boolean debe_rociar;

void setup() {
  // put your setup code here, to run once:
  pinMode(RELE, OUTPUT); // Configurar relay como salida o OUTPUT
  pinMode(sensor_prox, INPUT);
  Serial.begin(115200);

  InicializarWiFi();

}

void loop() {
  // put your main code here, to run repeatedly:
  mano_no_presente = digitalRead(sensor_prox);
  if(mano_no_presente == false){
    debe_rociar = true;
  }

  if (debe_rociar == true){
    mano_no_presente = digitalRead(sensor_prox);
    if (mano_no_presente == true){
      ActivaBomba();
    }
  }
}

void ActivaBomba(){
  delay(3000);
  digitalWrite(RELE, HIGH); // envia señal alta al relay
  delay(1800);
  
  digitalWrite(RELE, LOW);  // envia señal baja al relay
  debe_rociar = false;
  //Serial.println("PERILLA ROCIADA");
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


void EnviarValorServer(int foo){
  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status
    
    std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
    client->setInsecure();
        
    HTTPClient http;    //Declare object of class HTTPClient
    
    http.begin(*client, "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/fase1/peso");
    http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
    int httpCode = http.POST("{\"peso\":\"" + String(foo) + "\"}");   //Send the request
    String payload = http.getString();   //Get the response payload
    
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
  }else{
    Serial.println("Error in WiFi connection");   
  }
}
