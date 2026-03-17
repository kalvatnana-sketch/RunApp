import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color primary = const Color(0xFF00C98D);
  final Color accent = const Color(0xFFFFB84D);

  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _notifications = true;
  bool _vibration = true;

  void _log(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.black),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: accent, letterSpacing: 1.5, fontSize: 11),
      ),
    );
  }

  Widget _slider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: primary)),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: primary,
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label, style: TextStyle(color: primary)),
      value: value,
      onChanged: onChanged,
      activeColor: primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS"),
        backgroundColor: Colors.black,
      ),
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

          /// CONTENT
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: primary),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.12),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SYSTEM CONFIGURATION",
                        style: TextStyle(color: primary, letterSpacing: 2),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),

                      /// AUDIO
                      _sectionTitle("AUDIO"),
                      _slider("MUSIC VOLUME", _musicVolume, (val) {
                        setState(() => _musicVolume = val);
                      }),
                      _slider("SFX VOLUME", _sfxVolume, (val) {
                        setState(() => _sfxVolume = val);
                      }),

                      const Divider(height: 30),

                      /// PREFERENCES
                      _sectionTitle("PREFERENCES"),
                      _toggle("NOTIFICATIONS", _notifications, (val) {
                        setState(() => _notifications = val);
                      }),
                      _toggle("VIBRATION", _vibration, (val) {
                        setState(() => _vibration = val);
                      }),

                      const Divider(height: 30),

                      /// ACCOUNT
                      _sectionTitle("ACCOUNT"),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _log("CLEARING DATA...");
                          },
                          child: const Text("RESET DATA"),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("RETURN"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}