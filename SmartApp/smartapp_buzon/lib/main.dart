// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:flutter/material.dart';
import 'package:smartapp_buzon/rest_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



var titulos =  ['Estado del vehículo','Peso del objeto','Nivel líquido en el tanque'];
var colores = [Colors.green, Colors.blue, Colors.blue];
var estados_contenedor = ['Bajo: El tanque está casi vacío','Medio: Debajo del 50%','Alto: Mayor del 50%'];
var colores_estado_contendores= [Colors.red, Colors.yellow, Colors.green];
var estados_variables = [0,0,0]; //0: Estado del buzón, 1: Peso del objeto, 2: Estado del tanque
var estado_vehiculo = ['Detenido', 'En movimiento'];
var contador_objetos = 0;
var posicion_actual = [0,1];
var ubicacionAnterior =0;

var titleNotification = 'El vehículo ha salido hacia el buzón';
var payloadNotification = "Hora: "+arregloDeEstado[7].toString() +". Peso: "+arregloDeEstado[8].toString();
int trendingNewsId = 5;

var modoVehiculo = false;
/*Variables globales
    {"ubicacion_actual": "1",
    "estado_actual": "1",
    "paquetes": "3",
    "obstaculos": "7",
    "peso_promedio": "55.5",
    "tiempo_promedio_buz_punto": "125",
    "tiempo_promedio_punto_regreso": "135",
    "hora_evento": "10:32",
    "peso_actual": "10"
    } 
*/
var arregloDeEstado = 
[
  1, //Ubicacion actual 1= Punto de partida, 2=En el recorrdio, 3 = punto de entrega
  1, //Estado actual    1= Reposo, 2= Hacia punto de entrega, 3= De regreso al buzón, 4=Detenido por osbtaculo
  3, //Paquetes entregados No. paquetes entregados
  0, //Obstaculos actuales. No. obstaculos
  0.00, //Peso promedio paquetes en gramos
  1, //Tiempo promedio Buzón-->Punto en s
  1, //Tiempo proemdio Punto-->Buzón en s
  "12:00", //Hora del evento actaul
  0.10 //Peso actual
];




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
  int estadoVehiculo = 0;
  int estadoTanque = 2;

  Icon _iconoEstadoVehiculo = Icon(Icons.directions_car,color: Colors.black,size: 50.0,);
  Icon _iconoPeso = Icon(Icons.assignment_turned_in,color: Colors.green,size: 50.0,);
  Icon _iconoObstaculo = Icon(Icons.stop_screen_share,color: Colors.green,size: 50.0,);
  Icon _iconoTanque = Icon(Icons.local_mall,color: Colors.brown,size: 50.0,);
  Icon iconoSwitch = Icon(Icons.settings_power, color: Colors.black, size: 50.0);

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void actualizarData() 
  {
    setState(() 
    {
      //ApiService.getDataBuzon(); 
      //ApiService.getDataTanque();
      ApiService.setVehiculeMode();
      ApiService.getDataDelivery();            
    });
  }

  void cabiarModoVehiculo() 
  {
    setState(() 
    {
      ApiService.getDataBuzon(); 
      ApiService.getDataTanque();
      _pesoObjeto = estados_variables[1];
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
          title: Text(titleNotification),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(payloadNotification),                
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




  Future _showNotification() async 
  {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'SmartMailBox', 'WebAPIRest', 'Server as a broker',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
            
    await flutterLocalNotificationsPlugin.show(
        0, titleNotification, payloadNotification, platformChannelSpecifics,
        payload: (trendingNewsId++).toString());
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



/*-------------Calcular los datos a mostrar de la Ubicacion */

  Widget obtenerTextoUbicacionVehiculo()
  {
    switch(arregloDeEstado[0])
    {
      case 1:
        return Titulo(texto: "Punto de partida.", tamanioFuente: 2);        
      break;
      case 2:
        return Titulo(texto: "En el recorrido", tamanioFuente: 2);
      break;
      case 3:
        return Titulo(texto: "Punto de entrega", tamanioFuente: 2);
      break;   
      default:
        return Titulo(texto: "Punto de entrega", tamanioFuente: 2);
      break;                       
    } 
  }

  Widget obtenerIconoUbicacionVehiculo()
  {   
    switch(arregloDeEstado[0])
    {
      case 1: 
        return Icon(Icons.markunread_mailbox, color: Colors.black, size: 50.0);
      break;
      case 2:     
        return Icon(Icons.local_shipping, color: Colors.black, size: 50.0);
      break;
      case 3:           
        return Icon(Icons.inbox, color: Colors.black, size: 50.0);
      break;                  
      default:
        return Icon(Icons.inbox, color: Colors.black, size: 50.0);
      break;       
    } 
  }

/*-------------Calcular los datos a mostrar del estado del vehículo */

  Widget obtenerTextoEstadoVehiculo()
  {
    switch(arregloDeEstado[0])
    {
      case 1:
        if(ubicacionAnterior>=4)
        {
          titleNotification ="El vehículo ha regresado al buzón.";
          payloadNotification = "Hora: "+arregloDeEstado[7].toString()+". Obstáculos: "+ arregloDeEstado[3].toString();
          ubicacionAnterior =1;
        }    
        _showNotification();  
        return Titulo(texto: "En reposo", tamanioFuente: 2);        
      break;
      case 2:
        if(ubicacionAnterior==1)
        {
          titleNotification ="El vehículo ha salido del buzón.";
          payloadNotification = "Hora: "+arregloDeEstado[7].toString()+". Peso: "+ arregloDeEstado[8].toString()+". Obstáculos: "+ arregloDeEstado[3].toString();
          ubicacionAnterior =2;
        }       
        _showNotification();
        return Titulo(texto: "Rumbo a entrega", tamanioFuente: 2);
      break;
      case 3:
        ubicacionAnterior =3;
        return Titulo(texto: "De regreso al buzón", tamanioFuente: 2);
      break;   
      case 4:
        if(ubicacionAnterior==3)
        {
          titleNotification ="El vehículo ha llegado al punto de entrega.";
          payloadNotification = "Hora: "+arregloDeEstado[7].toString()+". Obstáculos: "+ arregloDeEstado[3].toString();
          ubicacionAnterior =4;
        }       
        _showNotification();
        return Titulo(texto: "Detenido por obstaculo", tamanioFuente: 2);
      break;                       
    } 
  }

  Widget obtenerIconoEstadoVehiculo()
  {
    switch(arregloDeEstado[0])
    {
      case 1:
        return Icon(Icons.do_not_disturb_off, color: Colors.red, size: 50.0);
      break;
      case 2:
        return Icon(Icons.directions_car, color: Colors.green, size: 50.0);
      break;
      case 3:
        return Icon(Icons.directions_car, color: Colors.orange, size: 50.0);
      break;                  
      default:
        return Icon(Icons.do_not_disturb, color: Colors.yellow, size: 50.0);
      break;       
    } 
  }  

  /*----------------Codigo para generar el reporte de objetos entregados */

  Widget obtenerTextoPaquetesEntregados()
  {
    return Titulo(tamanioFuente: 2, texto: arregloDeEstado[2].toString());
  }

  /*----------------Codigo para generar el reporte de obstaculos */
  Widget obtenerTextoObstaculos()
  {
    return Titulo(tamanioFuente: 2, texto: arregloDeEstado[3].toString());
  }

  /*----------------Codigo para generar el reporte de obstaculos */
  Widget obtenerPesoPromedio()
  {
    return Titulo(tamanioFuente: 2, texto: arregloDeEstado[4].toString() +" g.");
  }  

  /*----------------Codigo para generar el reporte de tiempo promedio de entrega */
  Widget obtenerTiempoPromedioEntrega()
  {
    return Titulo(tamanioFuente: 2, texto: arregloDeEstado[5].toString() +" s.");
  }   

  /*----------------Codigo para generar el reporte de tiempo promedio de regreso */
  Widget obtenerTiempoPromedioRegreso()
  {
    return Titulo(tamanioFuente: 2, texto: arregloDeEstado[6].toString() +" s.");
  }     


  /*----------------Codigo para generar el reporte de tiempo promedio de regreso */
  Widget obtenerModoVehiculo()
  {
    return Titulo(tamanioFuente: 2, texto: modoVehiculo? "Activo":"Inactivo");
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
          fit: FlexFit.loose,
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
                        titulo: Titulo(tamanioFuente: 1, texto:"Ubicación"), 
                        mensaje: obtenerTextoUbicacionVehiculo(),
                        icono: obtenerIconoUbicacionVehiculo(),
                        )
                    ),
                  ),   
                  Flexible
                  (
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Apartado(
                      colorFondo:Colors.white , 
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 1, texto:"Estado"), 
                        mensaje: obtenerTextoEstadoVehiculo(),
                        icono: obtenerIconoEstadoVehiculo(),
                        )
                    ),
                  ),                       
                ],
              ),
        ),
        Flexible(
          fit: FlexFit.loose,
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
                    flex: 3,
                    child: Apartado(
                      colorFondo: Colors.white , 
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 2, texto:"Paquetes\nentregados"), 
                        mensaje: obtenerTextoPaquetesEntregados(),
                        icono: _iconoPeso,                        
                      ) 
                    ),
                  ), 
                  Flexible
                  (
                    fit: FlexFit.tight,
                    flex: 3,
                    child: Apartado(
                      colorFondo: Colors.white , 
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 2, texto:"Obstaculos encontrados"), 
                        mensaje: obtenerTextoObstaculos(),
                        icono: _iconoObstaculo,                        
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
                      colorFondo:Colors.white,  
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 1, texto:"Peso promedio"), 
                        mensaje:obtenerPesoPromedio(),
                        icono: _iconoTanque,
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
                      colorFondo:Colors.white, 
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 2, texto:"Peso promedio\nBuzón a Entrega"), 
                        mensaje: obtenerTiempoPromedioEntrega(),
                        icono:  Icon(Icons.file_download,color: Colors.red,size: 50.0,),
                      ) 
                    ),
                  ), 
                  Flexible
                  (
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Apartado(
                      colorFondo:Colors.white,  
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 2, texto:"Tiempo promedio\nEntrega a Buzón"), 
                        mensaje:obtenerTiempoPromedioRegreso(),
                        icono:  Icon(Icons.file_upload,color: Colors.black,size: 50.0,),
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
                      colorFondo:Colors.white,  
                      widget: Elemento(
                        titulo: Titulo(tamanioFuente: 1, texto:"Modo del vehículo"), 
                        mensaje: obtenerModoVehiculo(),
                        icono:
                          Switch(
                          value: modoVehiculo,
                          onChanged: (value){
                            setState(() 
                            {
                              modoVehiculo=value;
                              actualizarData();
                            });
                          },                                                
                      ),                        
                    ),
                  ),                                             
                  )
                ],
              ),          
        ), 
        Flexible
        (
          fit: FlexFit.tight,
          flex: 1,
          child: FloatingActionButton(
                onPressed: actualizarData,
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
        mensaje_ = Titulo(tamanioFuente: 2, texto: estado_vehiculo[estados_variables[0]]);
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


  void actualizarData() {
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
                onPressed: actualizarData,
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
    1:"Arqui 2 , proyecto 1",
    2:"-----------",
    5:"Grupo 19"
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



