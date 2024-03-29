import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          fontFamily: 'Work Sans'),
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
        page = StatsPage();
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
            labelType: NavigationRailLabelType.selected,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            groupAlignment: 0.0,
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
        bottomNavigationBar: NavigationBar(
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
        ),
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
  int _workTimeInMinutes = 25;
  int _secondsRemaining = 0;
  Timer? focusCountdownTimer;
  bool _isRunning = false;
  bool _isPaused = false;
  final String _remainingTimeKey = 'remaining_time';

  @override
  void initState() {
    super.initState();
    _loadRemainingTimeFromPrefs().then((value) {
      setState(() {
        _secondsRemaining = value;
      });
    });
    _secondsRemaining = _workTimeInMinutes * 60;
  }

  @override
  void dispose() {
    focusCountdownTimer?.cancel();
    _saveRemainingTimeToPrefs();
    super.dispose();
  }

  void _saveRemainingTimeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_remainingTimeKey, _secondsRemaining);
  }

  Future<int> _loadRemainingTimeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_remainingTimeKey) ?? _workTimeInMinutes * 60;
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
      _saveRemainingTimeToPrefs();
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
    _saveRemainingTimeToPrefs();
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
    _saveRemainingTimeToPrefs();
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
      appBar: AppBar(
        title: Text('Focus.io'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Focus',
                  style: TextStyle(
                    fontFamily: 'Abril Fatface',
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              CircularPercentIndicator(
                radius: 150,
                lineWidth: 10,
                percent: _secondsRemaining / (_workTimeInMinutes * 60),
                center: Text(
                  _formatDuration(Duration(seconds: _secondsRemaining)),
                  style: TextStyle(
                    fontSize: 48,
                    fontFamily: 'Arbutus Slab',
                  ),
                ),
                progressColor: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (!_isRunning)
                    FloatingActionButton(
                      onPressed: startTimer,
                      child: Icon(Icons.play_arrow),
                      elevation: 0,
                    ),
                  if (_isRunning)
                    FloatingActionButton(
                      onPressed: stopTimer,
                      child: Icon(Icons.stop),
                      elevation: 0,
                    ),
                  SizedBox(
                    width: 10,
                  ),
                  if (_isRunning && !_isPaused)
                    FloatingActionButton(
                      onPressed: pauseTimer,
                      child: Icon(Icons.pause),
                      elevation: 0,
                    ),
                  if (_isRunning && _isPaused)
                    FloatingActionButton(
                      onPressed: resumeTimer,
                      child: Icon(Icons.play_arrow),
                      elevation: 0,
                    ),
                ],
              )
            ],
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    ;
  }
}



class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Focus.io'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        body: Column(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Stats',
                      style: TextStyle(
                        fontFamily: 'Abril Fatface',
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ))),
            Placeholder(
              fallbackHeight: 500,
              fallbackWidth: double.infinity,
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 2,
            ),
            Text(
              'Under Development',
              style: TextStyle(
                fontFamily: 'Arbutus Slab',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ));
  }
}
