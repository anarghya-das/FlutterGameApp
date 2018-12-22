import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audio_cache.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MyApp(),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Color bcolor = Colors.blue;
  Timer timer;
  var r = new math.Random();
  static AudioCache player = new AudioCache();
  Future<AudioPlayer> audioPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    audioPlayer = player.loop('kahoot.mp3');
    timer = new Timer.periodic(new Duration(seconds: 2), (Timer timer) {
      setState(() {
        bcolor =
            Color.fromRGBO(r.nextInt(255), r.nextInt(255), r.nextInt(255), 1);
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        audioPlayer.then((AudioPlayer val) => val.pause());
        break;
      case AppLifecycleState.resumed:
        audioPlayer.then((AudioPlayer val) => val.resume());
        break;
      case AppLifecycleState.inactive:
        audioPlayer.then((AudioPlayer val) => val.pause());
        break;
      case AppLifecycleState.suspending:
        audioPlayer.then((AudioPlayer val) => val.pause());
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static var selectedItem;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      color: bcolor,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset("images/ask.png"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Choose a Game Mode to Start!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.black),
              child: DropdownButton<String>(
                items: <String>['50', '100', '200', '500', '1000']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text("Select a Game Mode"),
                onChanged: (value) {
                  selectedItem = value;
                  audioPlayer.then((AudioPlayer val) => val.pause());
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(value, audioPlayer),
                      ));
                },
                value: selectedItem,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String _gameValue;
  final Future<AudioPlayer> ap;
  GameScreen(this._gameValue, this.ap);
  @override
  State<StatefulWidget> createState() {
    return GameScreenState(_gameValue, ap);
  }
}

class GameScreenState extends State<GameScreen> {
  String _gameValue;
  Future<AudioPlayer> ap;
  GameScreenState(this._gameValue, this.ap);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text("Welcome to the Game Mode: $_gameValue")),
            RaisedButton(
              child: Text("Back"),
              onPressed: () {
                ap.then((AudioPlayer val) => val.resume());
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
