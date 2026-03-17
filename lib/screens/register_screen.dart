import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;

  final Color primary = const Color(0xFF00C98D);
  final Color accent = const Color(0xFFFFB84D);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _log(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.black));
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _log("FIELDS INCOMPLETE");
      return;
    }

    if (pass != confirm) {
      _log("KEY MISMATCH");
      return;
    }

    setState(() => _isLoading = true);

    /// fake delay for system feel
    await Future.delayed(const Duration(seconds: 1));

    try {
      await _authService.registerWithEmail(email, pass);

      _log("PROFILE CREATED");

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String msg = "REGISTRATION FAILED";

      switch (e.code) {
        case 'email-already-in-use':
          msg = 'IDENTIFIER EXISTS';
          break;
        case 'weak-password':
          msg = 'WEAK KEY';
          break;
        case 'invalid-email':
          msg = 'FORMAT INVALID';
          break;
      }

      _log(msg);
    } catch (_) {
      _log("ERROR");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    BoxShadow(color: primary.withOpacity(0.12), blurRadius: 15),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Text(
                      "AGENT REGISTRATION",
                      style: TextStyle(color: primary, letterSpacing: 2),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "LEVEL 1 CLEARANCE",
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const Divider(height: 30),

                    /// EMAIL
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: primary),
                      decoration: const InputDecoration(
                        labelText: "IDENTIFIER",
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// PASSWORD
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: primary),
                      decoration: const InputDecoration(
                        labelText: "ACCESS KEY",
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// CONFIRM
                    TextField(
                      controller: _confirmController,
                      obscureText: true,
                      style: TextStyle(color: primary),
                      decoration: const InputDecoration(
                        labelText: "CONFIRM KEY",
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// BUTTON
                    if (_isLoading)
                      Center(child: CircularProgressIndicator(color: primary))
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: const Text("INITIALIZE AGENT"),
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
