// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:flutter/material.dart';
import 'package:smartapp_buzon/rest_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



var titulos =  ['Estado del buzón','Peso del objeto','Nivel líquido en el tanque'];
var colores = [Colors.green, Colors.blue, Colors.blue];
var estados_contenedor = ['Bajo: El tanque está casi vacío','Medio: Debajo del 50%','Alto: Mayor del 50%'];
var colores_estado_contendores= [Colors.red, Colors.yellow, Colors.green];
var estados_variables = [0,0,0]; //0: Estado del buzón, 1: Peso del objeto, 2: Estado del tanque
var estado_buzon = ['Vacío', 'Hay objetos dentro del buzón.'];
var contador_objetos = 0;
var posicion_actual = [0,1];


  List<List<String>> gridState = 
  [
    ['E',"C","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","V"],
    ['V',"V","V","V","V","V","V","V","V","V","V","S"],    
  ];



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  //ApiService.getDataTanque();    
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Smart MailBox Grupo 19 Delivery Car',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Smart MailBox Grupo 19 Delivery Car'),
        ),
        body: Center(
          //child: RandomWords(),
          child: BuzonBodyWidget(),    
        ),
      ),
    );
  }
}

class BuzonBodyWidget extends StatefulWidget
{
  @override
  _BuzonBodyStateWidget createState() => _BuzonBodyStateWidget();  
}


class _BuzonBodyStateWidget extends State<BuzonBodyWidget>
{
  int _pesoObjeto =0;
  int _estado_buzon = 0;
  int _estado_tanque = 2;

  Icon _iconoEstadoBuzon = Icon(Icons.delete,color: Colors.green,size: 50.0,);
  Icon _iconoPeso = Icon(Icons.local_mall,color: Colors.green,size: 50.0,);
  Icon _iconoTanque = Icon(Icons.local_car_wash,color: Colors.black,size: 50.0,);

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void _actualizar() 
  {
    setState(() 
    {
      ApiService.getDataBuzon(); 
      ApiService.getDataTanque();
      _pesoObjeto = estados_variables[1];
      _estado_buzon = _pesoObjeto==0? 0:1;
      print('-----------Peso objeto\t'+_pesoObjeto.toString());
      print('-----------Estado del buzón\t'+_estado_buzon.toString());
      _estado_tanque = estados_variables[2];
      if(_iconoEstadoBuzon==0)
      {
        _iconoEstadoBuzon = Icon(Icons.delete_outline,color: Colors.green,size: 50.0,);   
        contador_objetos=0;     
      }
      else
      {
        _iconoEstadoBuzon = Icon(Icons.delete,color: Colors.green,size: 50.0,);  
        if(contador_objetos<1)
        {
          _showMyDialog();
        }             
        contador_objetos++;
      }

      if(_estado_tanque==0)
      {
        _showNotification();      
      }
    });
  }


  @override
  initState() {
    super.initState();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }


  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('Notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen(payload)),
    );
  }  


  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nuevo paquete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Hay un nuevo paquete en el buzón'),                
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  Future _showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'SmartMailBox', 'WebAPIRest', 'Server as a broker',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);


    String trendingNewsId = '5';
    await flutterLocalNotificationsPlugin.show(
        0, 'SmartMailBox', 'El tanque del desinfectante está en un nivel muy bajo.', platformChannelSpecifics,
        payload: trendingNewsId);
  } 

  

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("ok"),
      onPressed: () { },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alerta"),
      content: Text("Hay un nuevo paquete en el buzón."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }  

  
  @override 
  Widget build(BuildContext context)
  {
    return Column
    (
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,    
      //crossAxisAlignment: CrossAxisAlignment.start,  
      children:
      [      
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: 
          Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,      
                children: [
                  Flexible
                  (
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Apartado(
                      colorFondo:Colors.black12 , 
                      widget: ElementoMapa(x: 1,y: 2),
                      /*
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 1, texto:"Posición actual"), 
                        mensaje: Titulo(tamanioFuente: 2, texto: estado_buzon[_estado_buzon]),
                        icono: _iconoEstadoBuzon,
                        )
                        */
                    ),
                  ),        
                ],
              ),
        ),        
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: 
          Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,      
                children: [
                  Flexible
                  (
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Apartado(
                      colorFondo:Colors.white , 
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 1, texto:titulos[0]), 
                        mensaje: Titulo(tamanioFuente: 2, texto: estado_buzon[_estado_buzon]),
                        icono: _iconoEstadoBuzon,
                        )
                    ),
                  ),        
                ],
              ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: 
          Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,      
                children: [
                  Flexible
                  (
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Apartado(
                      colorFondo: Colors.white , 
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 1, texto:titulos[1]), 
                        mensaje: Titulo(tamanioFuente: 2, texto: '$_pesoObjeto g'),
                        icono: _iconoPeso,                        
                      ) 
                    ),
                  ),        
                ],
              ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: 
          Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,      
                children: [
                  Flexible
                  (
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Apartado(
                      colorFondo:colores_estado_contendores[_estado_tanque] , 
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 1, texto:titulos[2]), 
                        mensaje: Titulo(tamanioFuente: 2, texto: estados_contenedor[estados_variables[2]]),
                        icono: _iconoTanque,
                      ) 
                    ),
                  ),        
                ],
              ),          
        ),   
        Flexible
        (
          fit: FlexFit.tight,
          flex: 1,
          child: FloatingActionButton(
                onPressed: _actualizar,
                tooltip: 'UpdateData',
                child: Icon(Icons.update),
              ),          
        ),                     
      ]
    );
  }
}


class BuzonWidget extends StatelessWidget 
{
  BuzonWidget({this.indiceElemento});
  final int indiceElemento;

  
  @override
  Widget build(BuildContext context) {
    Color colorFondo = Colors.white;      
    Titulo mensaje_= Titulo(tamanioFuente: 2, texto:titulos[indiceElemento]); 
    ApiService.getDataBuzon();   
    ApiService.getDataTanque();
    switch(indiceElemento)
    {
      case 0:
        //colorFondo = colores_estado_contendores[estados_variables[2]];    
        mensaje_ = Titulo(tamanioFuente: 2, texto: estado_buzon[estados_variables[0]]);
      break;
      case 1:
        //colorFondo = colores_estado_contendores[estados_variables[0]];    
        mensaje_ = Titulo(tamanioFuente: 2, texto: estados_variables[1].toString() + ' Kg.');
      break;            
      case 2:/**Evaluación del estado del tanque */
        colorFondo = colores_estado_contendores[estados_variables[0]];    
        mensaje_ = Titulo(tamanioFuente: 2, texto: estados_contenedor[estados_variables[0]]);

        /*Aquí desplegamos la notificación de ser necesario */
      break;
    }



    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,      
      children: [
        Flexible
        (
          fit: FlexFit.tight,
          flex: 1,
          child: Apartado(colorFondo:colorFondo , widget: Elemento(titulo: Titulo(tamanioFuente: 1, texto:titulos[indiceElemento]), mensaje: mensaje_) ),
        ),        
      ],
    );
  }
}

class Apartado extends StatelessWidget {
  Apartado({this.widget, this.colorFondo});
  final Widget widget;  
  final Color colorFondo;

  @override
  Widget build(BuildContext context) {    
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: colorFondo,
        border: Border.all(),
      ),
      child: widget,      
    );
  }
}

class Titulo extends StatelessWidget
{
    Titulo({this.texto, this.tamanioFuente});
    final String texto;
    final int tamanioFuente;
    @override 
    Widget build(BuildContext context)
    {
      if(tamanioFuente==2)
      {
        return 
          Text(texto,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.black));  
      }else
      {
        return 
        Text(texto,
        style: Theme.of(context)
            .textTheme
            .headline4
            .copyWith(color: Colors.black));            
      }
      
    }
}


class Elemento extends StatelessWidget
{
  Elemento({this.titulo,this.mensaje, this.icono});
  final Widget titulo;
  final Widget mensaje;
  final Widget icono;  

  @override
  Widget build(BuildContext context) 
  {
    return Column
    (
      children: [ titulo,mensaje, icono]      
    );
  }
}


class ElementoMapa extends StatelessWidget
{
  ElementoMapa({this.x, this.y});
  final int x,y;


  @override
  Widget build(BuildContext context) 
  {
    int gridStateLength = gridState.length;
    int tmpx = posicion_actual[0];
    int tmpy = posicion_actual[1];      
    gridState[tmpx][tmpy] = 'V';
    gridState[x][y] = 'C';

    return Column(
      children: <Widget>[
      AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.0)
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridStateLength,
            ),
            itemBuilder: _buildGridItems,
            itemCount: gridStateLength * gridStateLength,
          ),
        ),
      ),
    ]);

    /*
    return Column
    (
      children: 
      [
        new Titulo(texto:"Posición ($x , $y)",tamanioFuente: 1)
      ],
    );
    */    
  }
  
}



Widget _buildGridItems(BuildContext context, int index) {
  int gridStateLength = gridState.length;
  int x, y = 0;
  x = (index / gridStateLength).floor();
  y = (index % gridStateLength);
  return GestureDetector(    
    child: GridTile(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.5)
        ),
        child: Center(
          child: _buildGridItem(x, y),
        ),
      ),
    ),
  );
}



Widget _buildGridItem(int x, int y) {
  switch (gridState[x][y]) {
    case '':
      return Text('');
      break;
    case 'E':
      return Icon(
        Icons.inbox,
        size: 20.0,
        color: Colors.black,
      );
      break;
    case 'S':
      return Icon(
        Icons.exit_to_app,
        size: 20.0,
        color: Colors.black,
      );
      break;
    case 'C':
      return Icon
      (
        Icons.directions_car,
        size: 20.0,
        color: Colors.black,
      );
      break;
    case 'V':
      return Text('');
      break;      
    default:
      return Text('');
  }
}



class BuzonInformeWidget extends StatefulWidget
{
  BuzonInformeWidget({this.titulo});

  final String titulo;
  

  @override
  _BuzonInformerWidgetState createState() => _BuzonInformerWidgetState(); 
}

class _BuzonInformerWidgetState extends State<BuzonInformeWidget>
{
  int _nivelLiquiedo = estados_variables[0];


  void _actualizar() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      ApiService.getDataBuzon();
    });


  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,      
      children: [
        Flexible
        (
          fit: FlexFit.tight,
          flex: 1,
          child: 
              Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,      
                    children: [
                      Flexible
                      (
                        fit: FlexFit.tight,
                        flex: 1,
                        child: Apartado(colorFondo:Colors.white , widget: Elemento(titulo: Titulo(tamanioFuente: 1, texto:titulos[0]), mensaje: Titulo(tamanioFuente: 2, texto:titulos[0]))),
                      ),        
                    ],
                  ),          
        ),    
        Flexible
        (
          fit: FlexFit.tight,
          flex: 1,
          child: FloatingActionButton(
                onPressed: _actualizar,
                tooltip: 'Update Data',
                child: Icon(Icons.update),
              ),          
        ),             
      ],
    );

  }
}


class SecondScreen extends StatefulWidget {
  final String payload;
  SecondScreen(this.payload);
  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  var newsList = {
    1:"Anand Mahindra gets note from 11 year girl to curb noise pollution",
    2:"26 yr old engineer brings 10 pons back to life",
    5:"Donald trump says windmill cause cancer."
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen with payload"),
      ),
      body: Center(
        child: Center(
          child: Text(
            newsList[int.parse(_payload)],
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

