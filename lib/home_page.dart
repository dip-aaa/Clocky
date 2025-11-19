import 'package:flutter/material.dart';
import 'pages/world_clock_page.dart';
import 'pages/alarm_page.dart';
import 'pages/stopwatch_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final screens = const [
    WorldClockPage(),   // default = HOME
    AlarmPage(),
    StopwatchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: "World Clock",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: "Alarm",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: "Stopwatch",
          ),
        ],
      ),
    );
  }
}
