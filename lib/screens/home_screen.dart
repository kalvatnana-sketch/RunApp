import 'dart:math';
import 'package:flutter/material.dart';
import 'story_mode_screen.dart';
import 'open_mode_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Color primary = const Color(0xFF00C98D);
  final Color neonBlue = const Color(0xFF00E5FF);

  late AnimationController _pulseController;
  late AnimationController _ringController;
  late AnimationController _scanController;

  bool _expanded = false;
  double _fakeAudioLevel = 0.5;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Fake sound-reactive effect
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return false;
      setState(() {
        _fakeAudioLevel = 0.4 + Random().nextDouble() * 0.6;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Widget _glowingButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);

        // Delay navigation so animation plays
        Future.delayed(const Duration(milliseconds: 250), onTap);
      },
      child: AnimatedBuilder(
        animation: _ringController,
        builder: (context, child) {
          double ringScale = 1 + (_ringController.value * 0.6);

          return Stack(
            alignment: Alignment.center,
            children: [
              /// EXPANDING RING
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: neonBlue.withOpacity(1 - _ringController.value),
                      width: 2,
                    ),
                  ),
                ),
              ),

              /// MAIN BUTTON
              ScaleTransition(
                scale: Tween(begin: 0.95, end: 1.05).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withOpacity(0.6 * _fakeAudioLevel),
                        blurRadius: 25 * _fakeAudioLevel,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: primary, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scanLines() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (_, __) {
        return CustomPaint(
          painter: _ScanLinePainter(_scanController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "MISSION HUB",
            style: TextStyle(color: primary, letterSpacing: 2),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.settings, color: neonBlue),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: primary),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("PROFILE", style: TextStyle(color: primary)),
          Text("LEADERBOARD", style: TextStyle(color: primary)),
          Text("INVENTORY", style: TextStyle(color: primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020303), Color(0xFF050A08)],
              ),
            ),
          ),

          /// SCAN LINES
          Opacity(opacity: 0.08, child: _scanLines()),

          /// TOP BAR
          Align(alignment: Alignment.topCenter, child: _topBar()),

          /// CENTER BUTTONS
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(_expanded ? -40 : 0, 0),
                    child: _glowingButton("STORY", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StoryModeScreen(),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(width: 40),

                  Transform.translate(
                    offset: Offset(_expanded ? 40 : 0, 0),
                    child: _glowingButton("OPEN", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OpenModeScreen(),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM BAR
          Align(alignment: Alignment.bottomCenter, child: _bottomBar()),
        ],
      ),
    );
  }
}

/// SCAN LINE EFFECT
class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y + progress * 4),
        Offset(size.width, y + progress * 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
