import 'package:flutter/material.dart';

class OpenModeScreen extends StatelessWidget {
  const OpenModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Mode')),
      body: const Center(
        child: Text(
          'Free run mode coming soon...',
          style: TextStyle(fontSize: 20, color: Colors.white70),
        ),
      ),
    );
  }
}
