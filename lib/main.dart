import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/services/auth_service.dart';
import '/widgets/wrapper.dart';
import '/screens/login_screen.dart';
import '/screens/register_screen.dart';
import '/screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

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
