import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audio_cache.dart';
import 'package:swipedetector/swipedetector.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Guess the Number!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  background: Image.asset(
                    "images/ask.png",
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ];
          },
          body: MyApp(),
        ),
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
  final List<String> _gameModes = ['50', '100', '200', '500'];
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
    debugPrint("State: ${state.toString()}");
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
            padding: const EdgeInsets.only(
                top: 100, left: 10, right: 10, bottom: 20),
            child: Text(
              "Choose a Game Mode to Start!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0, color: Colors.white),
            ),
          ),
          Expanded(child: listBuild())
        ],
      )),
    );
  }

  Widget _buildRow(int idx) {
    var t = _gameModes[idx];
    return ListTile(
        leading: CircleAvatar(
          child: Text('$t'),
          backgroundColor: _backColors[idx],
          foregroundColor: Colors.black,
          radius: 30,
        ),
        onTap: () {
          audioPlayer.then((AudioPlayer val) => val.pause());
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GameScreen(t, audioPlayer, _backColors[idx]),
              ));
        },
        title: Text(
          "Guess from 0 to $t",
          style: TextStyle(fontSize: 20.0),
        ));
  }

  Widget listBuild() {
    return ListView.separated(
        itemCount: _gameModes.length,
        padding: const EdgeInsets.all(16.0),
        separatorBuilder: (context, i) => Divider(),
        itemBuilder: (context, i) {
          return _buildRow(i);
        });
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
    } else if (double.tryParse(value) == null) {
      return "Enter proper Number for guess.";
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
                          Navigator.popUntil(context,ModalRoute.withName(Navigator.defaultRouteName));
                        },
                      )
                    ],
                  ));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    generateNumbertoGuess();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      onSwipeRight: () {
        ap.then((AudioPlayer val) => val.resume());
        Navigator.pop(context);
      },
      swipeConfiguration: SwipeConfiguration(horizontalSwipeMinVelocity: 60),
      child: WillPopScope(
        onWillPop: () {
          ap.then((AudioPlayer val) => val.resume());
          Navigator.pop(context);
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  RaisedButton(
                    animationDuration: Duration(seconds: 4),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Text("Submit"),
                    onPressed: () {
                      _buttonPress();
                    },
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
