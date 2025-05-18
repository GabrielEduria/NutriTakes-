import 'dart:async';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class SplashScreen extends StatefulWidget {

  final AuthService authService;

  const SplashScreen({
    super.key,
    required this.authService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;

  final Color bgColor = Colors.white;
  final Color orangeColor = const Color(0xFFFF6600);
  final Color blackColor = Colors.black;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Navigate to login screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            authService: widget.authService,          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  TextStyle _welcomeTextStyle() => TextStyle(
        color: blackColor.withOpacity(0.7),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      );

  TextStyle _titleTextStyle() => TextStyle(
        color: orangeColor,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      );

  TextStyle _subtitleTextStyle() => TextStyle(
        color: blackColor.withOpacity(0.6),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/icon/NT.png',
                height: 150,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to',
                style: _welcomeTextStyle(),
              ),
              const SizedBox(height: 8),
              Text(
                'NutriTakes',
                style: _titleTextStyle(),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Filipino Food Nutrition Tracker',
                textAlign: TextAlign.center,
                style: _subtitleTextStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
