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
  static List<Color> _backColors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red
  ];
  static List<String> _gameModes = ['50', '100', '200', '500'];
  int idx = 0;
  Color bcolor = _backColors[0];
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
        idx++;
        if (idx >= _backColors.length) {
          idx = 0;
        }
        // Color.fromRGBO(r.nextInt(255), r.nextInt(255), r.nextInt(255), 1);
        bcolor = _backColors[idx];
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

  static String _selectedItem;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      color: bcolor,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset("images/ask2.png"),
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
              data: Theme.of(context).copyWith(canvasColor: Colors.white),
              child: DropdownButton<String>(
                items: _gameModes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text("Select a Game Mode"),
                onChanged: (value) {
                  _selectedItem = value;
                  audioPlayer.then((AudioPlayer val) => val.pause());
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(value, audioPlayer,
                            _backColors[_gameModes.indexOf(_selectedItem)]),
                      ));
                },
                value: _selectedItem,
                style: TextStyle(
                  color: Colors.black,
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
  final Color bgcol;
  GameScreen(this._gameValue, this.ap, this.bgcol);
  @override
  State<StatefulWidget> createState() {
    return GameScreenState(_gameValue, ap, bgcol);
  }
}

class GameScreenState extends State<GameScreen> {
  String _gameValue;
  Future<AudioPlayer> ap;
  Color bgcol;
  GlobalKey<FormState> _formKey = new GlobalKey();
  GameScreenState(this._gameValue, this.ap, this.bgcol);
  String _result = "";
  int _numberToGuess;
  int _guessFreq = 0;
  bool _gameOver = false;

  void generateNumbertoGuess() {
    var rnd = new math.Random();
    _numberToGuess = rnd.nextInt(int.parse(_gameValue));
  }

  void buttonPress() {
    if (_gameOver) {
      return null;
    } else {
      var st = _formKey.currentState;
      st.validate();
    }
  }

  @override
  void initState() {
    super.initState();
    generateNumbertoGuess();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ap.then((AudioPlayer val) => val.resume());
        Navigator.pop(context);
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: bgcol,
          body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Text(
                  "Welcome to the Game Mode: $_gameValue",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                )),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _result,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    maxLength: 3,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Can't process blank guess.";
                      } else if (double.tryParse(value) == null) {
                        return "Enter proper Number for guess.";
                      } else {
                        var userGuess = int.parse(value);
                        if (userGuess < _numberToGuess) {
                          setState(() {
                            _guessFreq++;
                            _result =
                                "Number to Guess is higher than Current Guess\nGuesses used: $_guessFreq";
                          });
                        } else if (userGuess > _numberToGuess) {
                          setState(() {
                            _guessFreq++;
                            _result =
                                "Number to Guess is lower than Current Guess\nGuesses used: $_guessFreq";
                          });
                        } else {
                          setState(() {
                            _result =
                                "You guessed it correctly! You used $_guessFreq Guesses!";
                            _gameOver = true;
                          });
                        }
                      }
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Enter the number to guess",
                        labelStyle: TextStyle(color: Colors.black)),
                  ),
                ),
                RaisedButton(
                  child: Text("Submit"),
                  onPressed: () {
                    buttonPress();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
