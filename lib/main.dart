import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'services/image_classifier.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(NutriTakesApp(cameras: cameras));
}

class NutriTakesApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const NutriTakesApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTakes',
      theme: ThemeData.light(),
      // Add this routes map 👇
      routes: {
        '/': (context) => Wrapper(authService: _authService),
        '/login': (context) => LoginScreen(authService: _authService),
        '/register': (context) => RegisterScreen(authService: _authService),
        '/forgot-password': (context) => ForgotPasswordScreen(authService: _authService),
      },
      initialRoute: '/',
    );
  }
}
