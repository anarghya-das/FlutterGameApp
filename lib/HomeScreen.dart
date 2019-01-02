import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'GameScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
    audioPlayer = player.loop('background.mp3');
    timer = new Timer.periodic(new Duration(seconds: 2), (Timer timer) {
      setState(() {
        idx++;
        if (idx >= _backColors.length) {
          idx = 0;
        }
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
    print("Disposed");
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
          Navigator.of(context).push(PageRouteBuilder(
              opaque: true,
              transitionDuration: Duration(milliseconds: 250),
              pageBuilder: (context, _, __) {
                return GameScreen(t, audioPlayer, _backColors[idx]);
              },
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position:
                      Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
                          .animate(animation),
                  child: child,
                );
              }));
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
