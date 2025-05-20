import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Firebase core
import 'package:camera/camera.dart';

import '../services/auth_service.dart';
import '../widgets/wrapper.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before anything else
  await Firebase.initializeApp();
  
  // Get the available cameras on the device
  final cameras = await availableCameras();

  // Run the app and pass the cameras list
  runApp(NutriTakesApp(cameras: cameras));
}

class NutriTakesApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final AuthService _authService = AuthService();

  NutriTakesApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTakes',
      theme: ThemeData.light(),
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