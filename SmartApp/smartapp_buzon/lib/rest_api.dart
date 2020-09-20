import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:smartapp_buzon/main.dart';
import 'package:smartapp_buzon/main2.dart';

/*------------------------------Parte de manejo de la comunicación */

class URLS 
{
  static const String BASE_URL = 'https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/fase1/';
  //static const String BASE_URL_TANQUE = 'https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/fase1/tanque';
  //static const String BASE_URL_BUZON = 'https://v4cr3oicvj.execute-api.us-east-2.amazonaws.com/fase1/peso';
}


class ApiService 
{
  static Future<bool> getDataTanque() async 
  {
   // RESPONSE JSON :
  /*{
    "error":false,
    "message":"lista de llenado",
    "data":
    {
        "Items":[
            {"llenado":"2"},
            {"llenado":"1"},
            {},
            {},
            {}],
        "Count":5,
        "ScannedCount":5
    },
    "code":200
  }*/
    final response = await http.get('${URLS.BASE_URL}/tanque');
    if (response.statusCode == 200) 
    {
      //return json.decode(response.body);      
      //return json.decode(response.body);
      var respuesta = json.decode(response.body);
      print(respuesta);
      var mensaje = respuesta['message'];      
      var data = respuesta['Items'];
      var peso = data[0]['llenado'];   
      if(peso!=null)
      {        
        estados_variables[2] = int.parse(peso);        
      }

      /*Generar el código para la notificación */
      if(estados_variables[2]==0)
      {        
      }

      print('Estado del tanque\t' +estados_variables[2].toString() );
      
      return true;
    } 
    else 
    {
      return false;
    }
  }


  static Future<int> getDataBuzon() async 
  {
   // RESPONSE JSON :
  /*{{
    "error":false,
    "message":"lista de pesos",
    "data":
    {
        "Items":
        [
            {},
            {"peso":"20"},
            {"peso":"10"},
            {},
            {},
            {},
            {"peso":"20"},
            {"peso":32},
            {"peso":"14"}
        ],
        "Count":9,
        "ScannedCount":9
    },
    "code":200
}*/

    final response = await http.get('${URLS.BASE_URL}/peso');
    if (response.statusCode == 200) 
    {
      //return json.decode(response.body);
      var respuesta = json.decode(response.body);
      print(respuesta);
      var mensaje = respuesta['message'];
      var data = respuesta['Items'];
      var peso = data[0]['peso'];
      if(peso!=null)
      {        
        estados_variables[1] = int.parse(peso);
        estados_variables[0] = 1;                
      }            
      print('Peso del objeto\t'+estados_variables[1].toString());            
    }     
    return estados_variables[1];
  }






  static Future<int> getDataDelivery() async 
  {
  /*
    {
      "ubicacion_actual": "1",
      "estado_actual": "1",
      "paquetes": "3",
      "obstaculos": "7",
      "peso_promedio": "55.5",
      "tiempo_promedio_buz_punto": "125",
      "tiempo_promedio_punto_regreso": "135",
      "hora_evento": "10:32",
      "peso_actual": "10"
    }  


      var arregloDeEstado = 
      [
        1, //Ubicacion actual 1= punto de partida, 2= en recorrido, 3= punto entrga
        1, //Estado actual    1= Reposo, 2= Hacia punto de entrega, 3= De regreso al buzón, 4=Detenido por osbtaculo
        1, //Paquetes entregados No. paquetes entregados
        0, //Obstaculos actuales. No. obstaculos
        0.00, //Peso promedio paquetes en gramos
        1, //Tiempo promedio Buzón-->Punto en s
        1, //Tiempo proemdio Punto-->Buzón en s
        "12:00", //Hora del evento actaul
        0.10 //Peso actual
      ];     
   */

    final response = await http.get('${URLS.BASE_URL}/data');
    if (response.statusCode == 200) 
    {      
      var respuesta = json.decode(response.body);
      arregloDeEstado[0] = respuesta['ubicacion_actual'];
      arregloDeEstado[1] = respuesta['estado_actual'];
      arregloDeEstado[2] = respuesta['paquetes'];
      arregloDeEstado[3] = respuesta['obstaculos'];
      arregloDeEstado[4] = respuesta['peso_promedio'];
      arregloDeEstado[5] = respuesta['tiempo_promedio_buz_punto'];
      arregloDeEstado[6] = respuesta['tiempo_promedio_punto_regreso'];
      arregloDeEstado[7] = respuesta['hora_evento'];
      arregloDeEstado[8] = respuesta['peso_actual'];     
    }  
    else
    {
      /*
        Imprimir el error. 
      */
    }   
    return arregloDeEstado[1];
  }


}


