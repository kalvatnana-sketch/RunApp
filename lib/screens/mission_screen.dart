import 'package:flutter/material.dart';

class MissionScreen extends StatelessWidget {
  final String missionTitle;
  const MissionScreen({super.key, required this.missionTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(missionTitle),
        backgroundColor: Colors.teal.shade900,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to $missionTitle',
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Back to Map'),
            ),
          ],
        ),
      ),
    );
  }
}

