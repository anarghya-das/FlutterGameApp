import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:swipedetector/swipedetector.dart';


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
  static List<Color> _backColors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red
  ];
  int idx = 0;
  Color _inVal = Colors.white;
  String _gameValue;
  Future<AudioPlayer> ap;
  Color bgcol;
  GlobalKey<FormState> _formKey = new GlobalKey();
  GameScreenState(this._gameValue, this.ap, this.bgcol);
  String _result =
      "Can you guess the number that I am thinking?\nGuess the number quickly and win the Game!";
  int _numberToGuess;
  int _guessFreq = 0;
  bool _gameOver = false;
  var rnd = new math.Random();
  AudioCache credits = new AudioCache();

  void generateNumbertoGuess() {
    _numberToGuess = rnd.nextInt(int.parse(_gameValue));
  }

  void _buttonPress() {
    if (_gameOver) {
      return null;
    } else {
      var st = _formKey.currentState;
      st.validate();
    }
  }

  String _validate(String value) {
    if (value.isEmpty) {
      return "Can't process blank guess.";
    } else if (int.tryParse(value) == null) {
      return "Enter proper INTEGER number for your guess.";
    } else {
      setState(() {
        if (idx >= _backColors.length) {
          idx = 0;
        }
        if (_backColors[idx] == bgcol) {
          idx++;
        }
        if (idx >= _backColors.length) {
          idx = 0;
        }
        _inVal = _backColors[idx];
        idx++;
      });
      var userGuess = int.parse(value);
      if (userGuess < _numberToGuess) {
        setState(() {
          _guessFreq++;
          _result =
              "Number to Guess is HIGHER than Current Guess\nGuesses used: $_guessFreq";
        });
      } else if (userGuess > _numberToGuess) {
        setState(() {
          _guessFreq++;
          _result =
              "Number to Guess is LOWER than Current Guess\nGuesses used: $_guessFreq";
        });
      } else {
        setState(() {
          credits.play("claps3.mp3");
          _result = "You guessed it correctly!\nYou used $_guessFreq Guesses!";
          _gameOver = true;
          showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text(_result),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Main Menu"),
                        onPressed: () {
                          ap.then((AudioPlayer val) => val.resume());
                          Navigator.popUntil(context,
                              ModalRoute.withName(Navigator.defaultRouteName));
                        },
                      )
                    ],
                  ));
        });
      }
    }
  }

  ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = new ScrollController();
    generateNumbertoGuess();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      onSwipeRight: () {
        ap.then((AudioPlayer val) => val.resume());
        Navigator.pop(context);
      },
      swipeConfiguration: SwipeConfiguration(horizontalSwipeMinVelocity: 40),
      child: WillPopScope(
        onWillPop: () {
          ap.then((AudioPlayer val) => val.resume());
          Navigator.pop(context);
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            // resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text("Guess Mode: $_gameValue"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: bgcol,
                onPressed: () {
                  ap.then((AudioPlayer val) => val.resume());
                  Navigator.pop(context);
                },
              ),
            ),
            backgroundColor: bgcol,
            body: Form(
              key: _formKey,
              child: ListView(
                controller: _scroll,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    margin: EdgeInsets.only(
                        left: 10, right: 10, top: 70, bottom: 50),
                    decoration: BoxDecoration(
                        color: _inVal,
                        shape: BoxShape.rectangle,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(15))),
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
                    child: Theme(
                      data: ThemeData(
                        primaryColor: Colors.black,
                      ),
                      child: TextFormField(
                        maxLength: 3,
                        style: Theme.of(context).textTheme.display1,
                        validator: (value) => _validate(value),
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                            labelText: "Make your Guess",
                            labelStyle: TextStyle(fontSize: 30),
                            errorStyle: TextStyle(fontSize: 15),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)))),
                        onFieldSubmitted: (val) {
                          _buttonPress();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, right: 100),
                    child: RaisedButton(
                      animationDuration: Duration(seconds: 4),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Text("Submit"),
                      onPressed: () {
                        _buttonPress();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}