import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  
  bool _isRunning = false;
  final List<String> _lapTimes = [];
  
  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int centiseconds = (milliseconds / 10).floor();
    int seconds = (centiseconds / 100).floor();
    int minutes = (seconds / 60).floor();
    
    int displayCentiseconds = centiseconds % 100;
    int displaySeconds = seconds % 60;
    int displayMinutes = minutes % 60;
    
    return '${displayMinutes.toString().padLeft(2, '0')}:'
           '${displaySeconds.toString().padLeft(2, '0')}.'
           '${displayCentiseconds.toString().padLeft(2, '0')}';
  }

  void _startStop() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _isRunning = false;
      } else {
        _stopwatch.start();
        _isRunning = true;
      }
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _isRunning = false;
      _lapTimes.clear();
    });
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      setState(() {
        String lapTime = _formatTime(_stopwatch.elapsedMilliseconds);
        _lapTimes.insert(0, 'Lap ${_lapTimes.length + 1}    $lapTime');
      });
    }
  }

  void _deleteLap(int index) {
    setState(() {
      _lapTimes.removeAt(index);
      // Update lap numbers for remaining items
      for (int i = 0; i < _lapTimes.length; i++) {
        String time = _lapTimes[i].split('    ')[1];
        _lapTimes[i] = 'Lap ${_lapTimes.length - i}    $time';
      }
    });
  }

  void _clearAllLaps() {
    setState(() {
      _lapTimes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Timer display
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                _formatTime(_stopwatch.elapsedMilliseconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          
          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Lap/Reset button
                GestureDetector(
                  onTap: _isRunning ? _lap : _reset,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800],
                      border: Border.all(color: Colors.grey[600]!, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _isRunning ? 'Lap' : 'Reset',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Two dots indicator
                Column(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                // Start/Stop button
                GestureDetector(
                  onTap: _startStop,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRunning ? Colors.red[600] : Colors.green[600],
                      border: Border.all(
                        color: _isRunning ? Colors.red[400]! : Colors.green[400]!, 
                        width: 2
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _isRunning ? 'Stop' : 'Start',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lap times list
          Expanded(
            flex: 2,
            child: _lapTimes.isEmpty
                ? const SizedBox()
                : Column(
                    children: [
                      // Clear all laps button
                      if (_lapTimes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_lapTimes.length} lap${_lapTimes.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: _clearAllLaps,
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Scrollable lap list
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            scrollbarTheme: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.all(Colors.orange),
                              trackColor: WidgetStateProperty.all(Colors.grey[800]),
                              thickness: WidgetStateProperty.all(4),
                              radius: const Radius.circular(2),
                            ),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _lapTimes.length,
                              itemBuilder: (context, index) {
                                return Dismissible(
                                  key: Key('lap_$index'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: Colors.red,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    _deleteLap(index);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    margin: const EdgeInsets.only(bottom: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[800]!,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _lapTimes[index],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _deleteLap(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
