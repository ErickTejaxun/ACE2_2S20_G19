 #include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  
  while(!Serial){
    Serial.println("."); //wait for serial port to connect
  }
  
  WiFi.begin("TURBONETT_F9AC27", "15D9352E14");   //WiFi connection
 
  while (WiFi.status() != WL_CONNECTED) {  //Wait for the WiFI connection completion
    delay(500);
    Serial.println("Waiting for connection");
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  char caracter;
  String contenido="";

  if(Serial.available()){
    
    while(Serial.available()){
      caracter = Serial.read();
      contenido.concat(caracter);
      delay(10);//si no se incluye la cadena se lee muy rapido
    }
    
    int dosPuntos = contenido.indexOf(':');    
    String tipo = contenido.substring(0, dosPuntos);

    if(tipo == "U"){
      u(contenido);
    }else if(tipo == "S"){
      s(contenido);
    }else if(tipo == "P"){
      p(contenido);
    }else if(tipo == "R"){
      r(contenido);
    }
  }
}


void u(String contenido){
  int par_a = contenido.indexOf('(');
  int coma = contenido.indexOf(',');
  int par_c = contenido.indexOf(')');
  String ubicacion = contenido.substring(par_a + 1, coma);
  String estado = contenido.substring(coma + 1, par_c);

  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status
    std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
    client->setInsecure();
    
    HTTPClient http;    //Declare object of class HTTPClient

    http.begin(*client, "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/ace2-proy/ubicacion");
    http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
    int httpCode = http.POST("{\"ubicacion\":\"" + ubicacion + "\", \"estado\":\"" + estado + "\"}");   //Send the request
    String payload = http.getString();   //Get the response payload
  
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
    
  }else{
    Serial.println("Error in WiFi connection");   
  }   
}


void s(String contenido){
  int par_a = contenido.indexOf('(');  
  int par_c = contenido.indexOf(')');
  String peso = contenido.substring(par_a + 1, par_c);

  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status
    std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
    client->setInsecure();
    
    HTTPClient http;    //Declare object of class HTTPClient
  
    http.begin(*client, "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/ace2-proy/salida-buzon");
    http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
    int httpCode = http.POST("{\"peso\":\"" + peso + "\"}");   //Send the request
    String payload = http.getString();   //Get the response payload
    
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
  }else{
    Serial.println("Error in WiFi connection");   
  }   
}


void p(String contenido){
  int par_a = contenido.indexOf('(');
  int coma = contenido.indexOf(',');
  int par_c = contenido.indexOf(')');
  String peso = contenido.substring(par_a + 1, coma);
  String obstaculos = contenido.substring(coma + 1, par_c);

  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status
    std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
    client->setInsecure();
    
    HTTPClient http;    //Declare object of class HTTPClient

    http.begin(*client, "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/ace2-proy/paquete");
    http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
    int httpCode = http.POST("{\"peso\":\"" + peso + "\", \"obstaculos\":\"" + obstaculos + "\"}");   //Send the request
    String payload = http.getString();   //Get the response payload
  
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
    
  }else{
    Serial.println("Error in WiFi connection");   
  }   
}


void r(String contenido){
  int par_a = contenido.indexOf('(');  
  int par_c = contenido.indexOf(')');
  String obstaculos = contenido.substring(par_a + 1, par_c);

  if(WiFi.status()== WL_CONNECTED){   //Check WiFi connection status
    std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
    client->setInsecure();
    
    HTTPClient http;    //Declare object of class HTTPClient
  
    http.begin(*client, "https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/ace2-proy/regreso-buzon");
    http.addHeader("Content-Type", "application/json");  //Specify content-type header
    
    int httpCode = http.POST("{\"obstaculos\":\"" + obstaculos + "\"}");   //Send the request
    String payload = http.getString();   //Get the response payload
    
    Serial.println(httpCode);   //Print HTTP return code
    Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
  }else{
    Serial.println("Error in WiFi connection");   
  }   
}
