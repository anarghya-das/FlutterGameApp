import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audio_cache.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MyApp(),
      ),
    ));

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Color bcolor=Colors.blue;
  Timer timer;
  var r = new math.Random();
  static AudioCache player = new AudioCache();

  @override
  void initState() {
    super.initState();
    player.loop('kahoot.mp3');
    timer = new Timer.periodic(new Duration(seconds: 2), (Timer timer) {
      setState(() {
        bcolor =
            Color.fromRGBO(r.nextInt(255), r.nextInt(255), r.nextInt(255), 1);
      });
    });
  }

  static var selectedItem;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      color: bcolor,
      child: Center(
          child: DropdownButton<String>(
        items: <String>['50', '100', '200', '500', '1000'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        hint: Text("Select a Game Mode"),
        onChanged: (value) {
          selectedItem = value;
          print("You selected $value");
          Scaffold.of(context).showSnackBar( SnackBar(content: Text("You selected $selectedItem")));
        },
        value: selectedItem,
        style: TextStyle(
          color: Colors.black,
        ),
      )),
    );
  }
}
