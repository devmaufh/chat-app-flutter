import 'package:chat_app/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/messagesPage.dart';

void main() {
 

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat-App',
      theme: ThemeData(fontFamily: 'ComicNeue'),
      routes: {
        'home': (BuildContext context) => HomePage(),
        'messsages' : (BuildContext context) => MessagesPage(),
      },
      initialRoute: 'home',
    );
  }
}
