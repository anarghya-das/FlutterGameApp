import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: new ThemeData(primaryColor: Colors.black),
      home: Scaffold(
        drawer: Drawer(),
        appBar: AppBar(centerTitle: true, title: Text("Guess The Number!")),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.mail),
              title: new Text('Messages'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: Text('Profile'))
          ],
        ),
        body: ListView(
          children: [
            Image.asset(
              'images/ask.png',
              width: 600.0,
              height: 240.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20.0),
            NameTap("Number")
          ],
        ),
      ),
    );
  }
}

class WidgetBuilder extends StatelessWidget {
  final String name;

  WidgetBuilder(this.name);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(color: Colors.lightBlueAccent),
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(name,
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center),
        ));
  }
}

class NameTap extends StatefulWidget {
  final String _name;

  NameTap(this._name);
  @override
  _NameTapState createState() => _NameTapState(_name);
}

class _NameTapState extends State<NameTap> {
  int count = 0;
  String _name;
  _NameTapState(this._name);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (count == 11) {
            count = 0;
          } else {
            count++;
          }
        });
      },
      child: conditionText(_name, count),
    );
  }
}

class conditionText extends StatelessWidget {
  final String n;
  final int c;
  conditionText(this.n, this.c);
  @override
  Widget build(BuildContext context) {
    if (c == 0) {
      return Text(
        "$n : $c is neither even nor odd!",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
      );
    }
    if (c % 2 == 0) {
      return Text("$n : $c is even!",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold));
    } else {
      return Text("$n : $c is odd!",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold));
    }
  }
}
