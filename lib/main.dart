import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus.io',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = FocusPage();
        break;
      case 1:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    if (MediaQuery.of(context).size.width > 640) {
      return Row(
        children: <Widget>[
          NavigationRail(
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: Text('Stats'),
              ),
            ],
            minWidth: 70,
            useIndicator: true,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            indicatorColor: Theme.of(context).colorScheme.tertiaryContainer,
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          )
        ],
      );
    } else {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart_rounded),
                label: 'Stats',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: (int index) {
              setState(() {
                selectedIndex = index;
              });
            }),
        body: page,
      );
    }
  }
}

class FocusPage extends StatefulWidget {
  @override
  _FocusPageState createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  int _workTimeInMinutes = 1;
  int _secondsRemaining = 0;
  Timer? focusCountdownTimer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _workTimeInMinutes * 60;
  }

  @override
  void dispose() {
    focusCountdownTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isRunning = true;
    });

    focusCountdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          focusCountdownTimer!.cancel();
          _isRunning = false;
        }
      });
    });

    Timer(Duration(minutes: _workTimeInMinutes), () {
      resetTimer();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Time\'s up!'),
              content:
                  Text('Great job staying focused. Time for a short break.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                )
              ],
            );
          });
    });
  }

  void stopTimer() {
    focusCountdownTimer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _secondsRemaining = _workTimeInMinutes * 60;
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      _workTimeInMinutes = 1;
    });
  }

  void pauseTimer() {
    focusCountdownTimer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void resumeTimer() {
    startTimer();
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: CircularPercentIndicator(
        radius: 200,
        lineWidth: 20,
        percent: _secondsRemaining / (_workTimeInMinutes * 60),
      ),
    ));
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    ;
  }
}
