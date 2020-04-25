import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:chat_app/models/route_arguments.dart';
import 'package:chat_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:chat_app/utils/connectionStatus.dart';
import 'package:chat_app/models/user_model.dart';

import 'package:adhara_socket_io/adhara_socket_io.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String URI = "";

  bool _isConnected = false;
  StreamSubscription _connectionChangeStream;

  List<String> toPrint = ["trying to connect"];
  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  SocketIO socket;

  List<UserModel> usersConnected;

  @override
  void initState() {
    usersConnected = List<UserModel>();
    //Internet listeners
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();

    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    //Sockets config
    manager = SocketIOManager();
    if (connectionStatus.hasConnection) {
      print("Si hay conexión");
      initSocket();
    } else {
      print("Sin conexión");
    }

    super.initState();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      _isConnected = hasConnection;
      print("INTERNET STATUS = $_isConnected");
      if (!_isConnected) {
        if (socket != null) {
          print("Desconectando socket...");
          manager.clearInstance(socket);
          setState(() {
            usersConnected = List<UserModel>();
          });
        }
      } else {
        initSocket();
      }
    });
  }

  initSocket() async {
    print("Configurando el socket");
    socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        URI,
        query: {
          "id": "2",
        },
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET /*, Transports.POLLING*/
        ] //Enable required transport
        ));
    socket.onConnect((data) {
      print("connected...");
    });

    socket.emit('chatList', ["2"]);
    socket.on('chatListRes', (data) {
      Map<String, dynamic> datos = data;
      print("CHAT EVENT");
      if (datos.containsKey('chatList')) {
        print("LISTA DE DATOS");
        print(datos['chatList']);
        setState(() => usersConnected = (datos['chatList'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList());
      }
      if (datos.containsKey('userConnected')) {
        print("USER CONECTADO");

        setState(() {
          usersConnected.add(UserModel.fromJson(datos['userData']));
        });
      }
      if (datos.containsKey('userDisconnected')) {
        print("User desconectado");
        setState(() {
          usersConnected
              .removeWhere((user) => user.socketId == datos['socket_id']);
        });
      }
    });
    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorTheme.backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.clear_all,
                      textDirection: TextDirection.rtl,
                      color: Colors.white,
                      size: 35,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Status",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor:
                          _isConnected ? ColorTheme.green : Colors.red,
                      child: Icon(
                        _isConnected ? Icons.check : Icons.priority_high,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(child: Container()),
                    Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 35,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                child: Text(
                  "Messages",
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: usersConnected != null && usersConnected.length > 0
                    ? usersConnected.length
                    : 0,
                itemBuilder: (BuildContext context, int index) {
                  return FadeIn(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        print(usersConnected[index].toJson());
                        Navigator.pushNamed(context, 'messsages',
                            arguments: RouteArguments(usersConnected[index], socket));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Hero(
                                tag: usersConnected[index].id,
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.orangeAccent,
                                  child: Text(
                                    "${usersConnected[index].name[0]}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 25,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "${usersConnected[index].name}",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "${usersConnected[index].email}",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
