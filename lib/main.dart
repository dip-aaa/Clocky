import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';   // <-- you'll create this next

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: MaterialColor(0xFFFF9500, {
          50: Color(0xFFFFE8CC),
          100: Color(0xFFFFD199),
          200: Color(0xFFFFBA66),
          300: Color(0xFFFFA333),
          400: Color(0xFFFF9500),
          500: Color(0xFFFF9500),
          600: Color(0xFFE6850D),
          700: Color(0xFFCC751A),
          800: Color(0xFFB36526),
          900: Color(0xFF995533),
        }),
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          onPrimary: Colors.black,
          surface: Color(0xFF21262D),
          onSurface: Colors.white,
          secondary: Colors.orange,
          onSecondary: Colors.black,
          background: Color(0xFF0D1117),
          onBackground: Colors.white,
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
            foregroundColor: Colors.orange,
          ),
        ),
        dialogBackgroundColor: const Color(0xFF21262D),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  void initState() {
    super.initState();

    // ⏳ Wait for 3 seconds → Go to HomePage()
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [

                // Face
                Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),

                // Left ear
                Positioned(top: -20, left: -5, child: _buildEar()),

                // Right ear
                Positioned(top: -20, right: -5, child: _buildEar()),

                // Left eye
                Positioned(
                  left: 30,
                  top: 60,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Wink
                Positioned(
                  right: 30,
                  top: 60,
                  child: SizedBox(
                    width: 30,
                    height: 15,
                    child: CustomPaint(
                      painter: StaticWinkPainter(),
                    ),
                  ),
                ),

                // Left diagonal arm
                Positioned(
                  top: 150,
                  left: 20,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Container(
                      width: 10,
                      height: 80,
                      color: const Color.fromARGB(255, 238, 163, 33),
                    ),
                  ),
                ),

                // Right diagonal arm
                Positioned(
                  top: 150,
                  right: 20,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      width: 10,
                      height: 80,
                      color: const Color.fromARGB(255, 238, 163, 33),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 62),

            // Body box
            Container(
              width: 180,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildYellowBox(),
                      const SizedBox(width: 8),
                      _buildYellowBox(),
                      const SizedBox(width: 8),
                      _buildYellowBox(),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Clocky",
                    style: GoogleFonts.pacifico(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEar() {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 238, 163, 33),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildYellowBox() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class StaticWinkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width,
        size.height * 0.6,
      );

    canvas.drawPath(path, paint);

    final eyelash = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final y = size.height * 0.3;

    canvas.drawLine(
      Offset(size.width * 0.2, y + 2),
      Offset(size.width * 0.15, y - 3),
      eyelash,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, y + 2),
      Offset(size.width * 0.5, y - 4),
      eyelash,
    );

    canvas.drawLine(
      Offset(size.width * 0.8, y + 2),
      Offset(size.width * 0.85, y - 3),
      eyelash,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
