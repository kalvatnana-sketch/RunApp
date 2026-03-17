import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00C98D);
    const accent = Color(0xFFFFB84D);

    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF020303),
                  Color(0xFF050A08),
                  Color(0xFF020303),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// SCANLINES (SAFE even if image missing)
          Opacity(opacity: 0.03, child: Container(color: Colors.black)),

          /// CONTENT
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  border: Border.all(color: primary),
                  boxShadow: [
                    BoxShadow(color: primary.withOpacity(0.15), blurRadius: 20),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NO TRACE RUN",
                      style: TextStyle(
                        color: primary,
                        fontSize: 28,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "CLASSIFIED SYSTEM INTERFACE",
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "STATUS: READY\nNODE: 07\nSECURITY: ACTIVE",
                      style: TextStyle(color: primary, height: 1.6),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text("ENTER THE RUN"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
