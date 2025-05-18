import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/login_screen.dart';
import '../widgets/splash_screen.dart';
import '../widgets/BottomNavigationBar.dart';  // BottomNav widget
import '../services/auth_service.dart';

class Wrapper extends StatelessWidget {
  final AuthService authService;

  const Wrapper({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(authService: authService);
        } else if (snapshot.hasData) {
          final email = snapshot.data!.email ?? 'No Email';
          return BottomNav(
            email: email,
              classificationHistory: [], // empty list to satisfy required parameter
              pickedImages: [],          // empty list to satisfy required parameter
          );
        } else {
          return LoginScreen(authService: authService);
        }
      },
    );
  }
}
