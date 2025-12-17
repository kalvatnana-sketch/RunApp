import 'package:flutter/material.dart';
import 'mission_screen.dart';

class StoryModeScreen extends StatefulWidget {
  const StoryModeScreen({super.key});

  @override
  State<StoryModeScreen> createState() => _StoryModeScreenState();
}

class _StoryModeScreenState extends State<StoryModeScreen> {
  final int _currentLevel = 3; // Example: up to level 3 completed

  final List<Map<String, dynamic>> _missions = List.generate(10, (index) {
    return {
      'id': index + 1,
      'title': 'Mission ${index + 1}',
      'isUnlocked': index < 3, // first 3 unlocked
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Story Mode'),
        backgroundColor: Colors.teal.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.black],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            reverse: true, // 👈 makes scrolling start from bottom
            child: Column(
              children: _missions.reversed.map((mission) {
                final bool unlocked = mission['isUnlocked'];
                final bool completed = mission['id'] < _currentLevel;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: unlocked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MissionScreen(
                                    missionTitle: mission['title'],
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.brightness_1,
                            size: 80,
                            color: completed
                                ? Colors.tealAccent
                                : unlocked
                                    ? Colors.white24
                                    : Colors.grey.shade800,
                          ),
                          Text(
                            mission['id'].toString(),
                            style: TextStyle(
                              color: unlocked ? Colors.black : Colors.white24,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          if (completed)
                            const Icon(Icons.check_circle,
                                color: Colors.black, size: 30),
                        ],
                      ),
                    ),
                    if (mission != _missions.first)
                      Container(
                        height: 60,
                        width: 4,
                        color: Colors.tealAccent.withOpacity(0.3),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
