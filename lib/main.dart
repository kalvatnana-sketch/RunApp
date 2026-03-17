import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mode_select_screen.dart';
import 'screens/story_mode_screen.dart';
import 'screens/open_mode_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NoTraceRunApp());
}

class NoTraceRunApp extends StatelessWidget {
  const NoTraceRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoTraceRun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),

        fontFamily: 'JetBrainsMono',

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF9C),
          secondary: Color(0xFF00E5FF),
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF00FF9C), letterSpacing: 1.2),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FF9C)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FF9C), width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFF00FF9C)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF00FF9C),
            side: BorderSide(color: Color(0xFF00FF9C)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Color(0xFF00FF9C)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/modeSelect': (context) => const ModeSelectScreen(),
        '/storyMode': (context) => const StoryModeScreen(),
        '/openMode': (context) => const OpenModeScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
