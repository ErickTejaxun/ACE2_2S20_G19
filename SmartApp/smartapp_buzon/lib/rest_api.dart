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




}


