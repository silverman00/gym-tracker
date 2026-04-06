import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

/// Routes between login/signup/home based on auth state.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isLoggedIn) {
          return const HomeScreen();
        }

        if (_showLogin) {
          return LoginScreen(
            onGoToSignUp: () => setState(() => _showLogin = false),
          );
        }

        return SignUpScreen(
          onGoToLogin: () => setState(() => _showLogin = true),
        );
      },
    );
  }
}
