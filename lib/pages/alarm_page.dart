import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:typed_data' show Int64List;

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  final List<Alarm> _alarms = [];
  Timer? _checkTimer;

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notifications.initialize(initializationSettings);
    
    // Request notification permissions
    await _requestPermissions();
    
    // Start checking for alarms
    _startAlarmChecker();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await Permission.notification.request();
    }
  }

  void _startAlarmChecker() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    final now = DateTime.now();
    for (final alarm in _alarms) {
      if (alarm.isEnabled && alarm.shouldTrigger(now)) {
        _triggerAlarm(alarm);
        // Disable the alarm after triggering (for one-time alarms)
        alarm.isEnabled = false;
      }
    }
  }

  void _triggerAlarm(Alarm alarm) {
    // Play the selected alarm sound
    _playAlarmSound(alarm.selectedSound);
    
    // Show notification with sound
    _showNotification(alarm);

    // Show a full-screen dialog that acts like an alarm
    if (alarm._context != null) {
      showDialog(
        context: alarm._context!,
        barrierDismissible: false,
        builder: (context) => AlarmDialog(alarm: alarm),
      );
    }
  }

  void _playAlarmSound(String soundFile) async {
    try {
      final player = AudioPlayer();
      
      if (kIsWeb) {
        try {
          await player.play(AssetSource('alarm_sounds/$soundFile'));
        } catch (e1) {
          try {
            await player.play(UrlSource('assets/alarm_sounds/$soundFile'));
          } catch (e2) {
            print('Web audio failed, using fallback beep');
            _playWebBeep();
            return;
          }
        }
      } else {
        await player.play(AssetSource('alarm_sounds/$soundFile'));
      }
    } catch (e) {
      print('Error playing alarm sound: $e');
      // Try system sound as ultimate fallback
      _playWebBeep();
    }
  }

  void _playWebBeep() {
    // Simple web beep using HTML5 audio
    if (kIsWeb) {
      try {
        // Create a simple beep sound for web
        final player = AudioPlayer();
        // Use a data URL for a simple beep
        player.play(UrlSource('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+PqmVYeCEeq3/OLIAQSVa3f7a1EEgU1ld/pu4EfAhVap+ftu1QTE0qj3fe7XCYEKHzK8u2QQAoUXrTp66hVFApGn+PqmVYeCEeq3/OLIAQSVa3f7a1EEgU1ld/pu4EfAhVap+ftu1QTE0qj3fe7'));
      } catch (e) {
        print('Web beep failed: $e');
      }
    }
  }

  Future<void> _showNotification(Alarm alarm) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Notifications for alarms',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await notifications.show(
      alarm.id.hashCode % 100000, // Ensure ID fits in 32-bit integer
      'Alarm: ${alarm.label}',
      'Time: ${alarm.timeString}',
      platformChannelSpecifics,
    );
  }

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
  }

  void removeAlarm(Alarm alarm) {
    _alarms.remove(alarm);
  }

  void toggleAlarm(Alarm alarm) {
    alarm.isEnabled = !alarm.isEnabled;
  }

  void dispose() {
    _checkTimer?.cancel();
  }
}

class Alarm {
  int id;
  TimeOfDay time;
  String label;
  String selectedSound;
  bool isEnabled;
  BuildContext? _context;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.selectedSound,
    this.isEnabled = true,
  });

  String get timeString {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool shouldTrigger(DateTime now) {
    if (!isEnabled) return false;
    
    return now.hour == time.hour && 
           now.minute == time.minute && 
           now.second == 0; // Trigger only at the exact minute
  }

  void setContext(BuildContext context) {
    _context = context;
  }
}

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final AlarmService _alarmService = AlarmService();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _timeSelected = false;
  String _selectedSound = 'mixkit-digital-clock-digital-alarm-buzzer-992.wav';
  final TextEditingController _labelController = TextEditingController();
  
  // Preview audio state
  AudioPlayer? _previewPlayer;
  bool _isPreviewPlaying = false;
  String? _currentPreviewSound;
  Timer? _previewTimer;
  
  // Available alarm sounds
  final List<Map<String, String>> _availableSounds = [
    {
      'file': 'mixkit-digital-clock-digital-alarm-buzzer-992.wav',
      'name': 'Digital Buzzer',
    },
    {
      'file': 'mixkit-casino-win-alarm-and-coins-1990.wav',
      'name': 'Casino Win',
    },
    {
      'file': 'mixkit-retro-game-emergency-alarm-1000.wav',
      'name': 'Emergency Alarm',
    },
    {
      'file': 'mixkit-rooster-crowing-in-the-morning-2462.wav',
      'name': 'Rooster Morning',
    },
    {
      'file': 'mixkit-short-rooster-crowing-2470.wav',
      'name': 'Rooster Short',
    },
    {
      'file': 'mixkit-warning-alarm-buzzer-991.wav',
      'name': 'Warning Buzzer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _alarmService.initialize();
  }

  @override
  void dispose() {
    _alarmService.dispose();
    _labelController.dispose();
    _stopPreview();
    super.dispose();
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange, // Header background and selected time
              onPrimary: Colors.black, // Text color on header
              surface: Color(0xFF21262D), // Dialog background
              onSurface: Colors.white, // Default text color
              secondary: Colors.orange, // Selected circle and buttons
              onSecondary: Colors.black, // Text on selected items
              background: Color(0xFF0D1117), // Background color
              onBackground: Colors.white, // Text on background
            ),
            dialogBackgroundColor: const Color(0xFF21262D),
            textTheme: const TextTheme(
              headlineMedium: TextStyle(color: Colors.white), // Time display
              bodyLarge: TextStyle(color: Colors.white), // Time numbers
              bodyMedium: TextStyle(color: Colors.white), // AM/PM text
              labelLarge: TextStyle(color: Colors.white), // Button text
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF21262D),
              hourMinuteTextColor: Colors.white,
              hourMinuteColor: const Color(0xFF0D1117),
              dayPeriodTextColor: Colors.white,
              dayPeriodColor: Colors.orange.withOpacity(0.2),
              dialHandColor: Colors.orange,
              dialBackgroundColor: const Color(0xFF0D1117),
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.orange,
              helpTextStyle: const TextStyle(color: Colors.white),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeSelected = true;
      });
    }
  }

  void _previewSound(String soundFile) async {
    // If currently playing the same sound, stop it
    if (_isPreviewPlaying && _currentPreviewSound == soundFile) {
      _stopPreview();
      return;
    }
    
    // Stop any current preview
    _stopPreview();
    
    try {
      _previewPlayer = AudioPlayer();
      
      setState(() {
        _isPreviewPlaying = true;
        _currentPreviewSound = soundFile;
      });
      
      // For web, try different approaches
      if (kIsWeb) {
        try {
          // Try asset source first
          await _previewPlayer!.play(AssetSource('alarm_sounds/$soundFile'));
        } catch (e1) {
          print('AssetSource failed on web: $e1');
          try {
            // Try URL source as fallback
            await _previewPlayer!.play(UrlSource('assets/alarm_sounds/$soundFile'));
          } catch (e2) {
            print('UrlSource failed on web: $e2');
            // Web fallback - simple beep
            _playWebBeep();
            _stopPreview();
            return;
          }
        }
      } else {
        // For mobile platforms
        await _previewPlayer!.play(AssetSource('alarm_sounds/$soundFile'));
      }
      
      // Auto-stop preview after 3 seconds
      _previewTimer = Timer(const Duration(seconds: 3), () {
        _stopPreview();
      });
      
      // Listen for completion
      _previewPlayer!.onPlayerComplete.listen((event) {
        _stopPreview();
      });
      
    } catch (e) {
      print('Error playing preview sound: $e');
      _stopPreview();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not preview sound: ${_availableSounds.firstWhere((s) => s['file'] == soundFile)['name']}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
  
  void _stopPreview() {
    _previewTimer?.cancel();
    _previewPlayer?.stop();
    _previewPlayer?.dispose();
    _previewPlayer = null;
    
    if (mounted) {
      setState(() {
        _isPreviewPlaying = false;
        _currentPreviewSound = null;
      });
    }
  }

  void _playWebBeep() {
    // Simple web beep using HTML5 audio
    if (kIsWeb) {
      try {
        // Create a simple beep sound for web
        final player = AudioPlayer();
        // Use a data URL for a simple beep
        player.play(UrlSource('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+PqmVYeCEeq3/OLIAQSVa3f7a1EEgU1ld/pu4EfAhVap+ftu1QTE0qj3fe7XCYEKHzK8u2QQAoUXrTp66hVFApGn+PqmVYeCEeq3/OLIAQSVa3f7a1EEgU1ld/pu4EfAhVap+ftu1QTE0qj3fe7'));
      } catch (e) {
        print('Web beep failed: $e');
      }
    }
  }

  void _showSoundSelector() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF21262D),
          title: const Text(
            'Select Alarm Sound',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableSounds.length,
              itemBuilder: (context, index) {
                final sound = _availableSounds[index];
                final isSelected = sound['file'] == _selectedSound;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.orange : Colors.grey,
                  ),
                  title: Text(
                    sound['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      (_isPreviewPlaying && _currentPreviewSound == sound['file']) 
                          ? Icons.pause 
                          : Icons.play_arrow, 
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      _previewSound(sound['file']!);
                      setDialogState(() {}); // Update dialog state
                    },
                  ),
                  onTap: () {
                    _stopPreview(); // Stop any preview when selecting
                    setState(() {
                      _selectedSound = sound['file']!;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _stopPreview(); // Stop preview when canceling
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

  void _addAlarm() {
    if (_labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an alarm label')),
      );
      return;
    }

    if (!_timeSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time for the alarm')),
      );
      return;
    }

    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch,
      time: _selectedTime,
      label: _labelController.text,
      selectedSound: _selectedSound,
    );
    alarm.setContext(context);

    _alarmService.addAlarm(alarm);
    _labelController.clear();
    
    setState(() {
      _timeSelected = false;
      _selectedSound = 'mixkit-digital-clock-digital-alarm-buzzer-992.wav';
      _selectedTime = TimeOfDay.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm set for ${alarm.timeString}')),
    );
  }

  void _deleteAlarm(Alarm alarm) {
    _alarmService.removeAlarm(alarm);
    setState(() {});
  }

  void _toggleAlarm(Alarm alarm) {
    _alarmService.toggleAlarm(alarm);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Alarms',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              
              // Add new alarm section
              Card(
                color: const Color(0xFF21262D),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _labelController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Alarm Label',
                                labelStyle: TextStyle(color: Colors.orange),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_timeSelected) ...[
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    _timeSelected 
                                        ? _selectedTime.format(context)
                                        : 'Tap to set time',
                                    style: TextStyle(
                                      color: _timeSelected ? Colors.white : Colors.orange,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Sound selection
                      GestureDetector(
                        onTap: _showSoundSelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.music_note,
                                color: Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Select Sound: ${_availableSounds.firstWhere(
                                    (sound) => sound['file'] == _selectedSound,
                                    orElse: () => {'name': 'Digital Buzzer'},
                                  )['name']!}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  (_isPreviewPlaying && _currentPreviewSound == _selectedSound) 
                                      ? Icons.pause 
                                      : Icons.play_arrow, 
                                  color: Colors.orange,
                                ),
                                onPressed: () => _previewSound(_selectedSound),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addAlarm,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Alarm',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Alarms list
              Expanded(
                child: _alarmService.alarms.isEmpty
                    ? const Center(
                        child: Text(
                          'No alarms set',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _alarmService.alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = _alarmService.alarms[index];
                          return Card(
                            color: const Color(0xFF21262D),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Switch(
                                value: alarm.isEnabled,
                                onChanged: (value) => _toggleAlarm(alarm),
                                activeColor: Colors.orange,
                              ),
                              title: Text(
                                alarm.label,
                                style: TextStyle(
                                  color: alarm.isEnabled 
                                      ? Colors.white 
                                      : Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alarm.timeString,
                                    style: TextStyle(
                                      color: alarm.isEnabled 
                                          ? Colors.orange 
                                          : Colors.grey,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _availableSounds.firstWhere(
                                      (sound) => sound['file'] == alarm.selectedSound,
                                      orElse: () => {'name': 'Digital Buzzer'},
                                    )['name']!,
                                    style: TextStyle(
                                      color: alarm.isEnabled 
                                          ? Colors.grey[400] 
                                          : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteAlarm(alarm),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlarmDialog extends StatefulWidget {
  final Alarm alarm;

  const AlarmDialog({super.key, required this.alarm});

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _soundTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _startAlarmSound();
  }

  void _startAlarmSound() {
    // Play the selected alarm sound repeatedly
    try {
      _soundTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        // Play the selected sound with cross-platform support
        try {
          final player = AudioPlayer();
          if (kIsWeb) {
            try {
              await player.play(AssetSource('alarm_sounds/${widget.alarm.selectedSound}'));
            } catch (e1) {
              try {
                await player.play(UrlSource('assets/alarm_sounds/${widget.alarm.selectedSound}'));
              } catch (e2) {
                print('Web audio failed in alarm dialog: $e2');
                _playWebBeep();
              }
            }
          } else {
            await player.play(AssetSource('alarm_sounds/${widget.alarm.selectedSound}'));
          }
        } catch (e) {
          print('Error playing alarm sound in dialog: $e');
          _playWebBeep();
        }
        
        // Also show notification with system sound as backup
        _showRepeatingNotification();
        
        // Stop after 30 seconds (10 repeats)
        if (timer.tick >= 10) {
          timer.cancel();
        }
      });
      
      // Play the sound immediately when dialog opens
      _playInitialSound();
    } catch (e) {
      print('Alarm sound setup failed: $e');
      // Fallback to system notification sound only
      _soundTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _showRepeatingNotification();
        if (timer.tick >= 10) {
          timer.cancel();
        }
      });
    }
  }

  void _playInitialSound() async {
    try {
      final player = AudioPlayer();
      if (kIsWeb) {
        try {
          await player.play(AssetSource('alarm_sounds/${widget.alarm.selectedSound}'));
        } catch (e1) {
          try {
            await player.play(UrlSource('assets/alarm_sounds/${widget.alarm.selectedSound}'));
          } catch (e2) {
            _playWebBeep();
          }
        }
      } else {
        await player.play(AssetSource('alarm_sounds/${widget.alarm.selectedSound}'));
      }
    } catch (e) {
      _playWebBeep();
    }
  }

  void _playWebBeep() {
    if (kIsWeb) {
      try {
        final player = AudioPlayer();
        player.play(UrlSource('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+PqmVYeCEeq3/OLIAQSVa3f7a1EEgU1ld/pu4EfAhVap+ftu1QTE0qj3fe7'));
      } catch (e) {
        print('Web beep failed in dialog: $e');
      }
    }
  }

  Future<void> _showRepeatingNotification() async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alarm_repeat_channel',
      'Alarm Repeat',
      channelDescription: 'Repeating alarm notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Access the AlarmService instance to use notifications
    final alarmService = AlarmService();
    await alarmService.notifications.show(
      999, // Use a fixed ID for repeating notifications
      'ALARM!',
      '${widget.alarm.label}',
      platformDetails,
    );
  }

  void _stopAlarmSound() {
    _soundTimer?.cancel();
    // Cancel any pending notifications
    final alarmService = AlarmService();
    alarmService.notifications.cancel(999);
  }

  void _snoozeAlarm() {
    // Stop current alarm sound
    _stopAlarmSound();
    
    // Close current dialog
    Navigator.of(context).pop();
    
    // Create a new alarm for 5 minutes from now
    final now = DateTime.now();
    final snoozeTime = now.add(const Duration(minutes: 5));
    final snoozeTimeOfDay = TimeOfDay(hour: snoozeTime.hour, minute: snoozeTime.minute);
    
    final snoozeAlarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch + 1, // Slightly different ID
      time: snoozeTimeOfDay,
      label: '${widget.alarm.label} (Snoozed)',
      selectedSound: widget.alarm.selectedSound,
      isEnabled: true,
    );
    snoozeAlarm.setContext(context);
    
    // Add the snooze alarm
    final alarmService = AlarmService();
    alarmService.addAlarm(snoozeAlarm);
    
    // Show snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm snoozed for 5 minutes (${snoozeAlarm.timeString})'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _stopAlarmSound();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.alarm,
                        color: Colors.orange,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.alarm.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.alarm.timeString,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _snoozeAlarm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'SNOOZE\n5 MIN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _stopAlarmSound();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'STOP\nALARM',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
