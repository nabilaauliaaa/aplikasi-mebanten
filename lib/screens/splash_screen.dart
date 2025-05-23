import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apk_mebanten/screens/welcome_screen.dart';
import 'package:apk_mebanten/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer untuk tampilan splash
    Timer(
      const Duration(seconds: 5),
      () => _checkAuthState(),
    );
  }
  
  // Memeriksa status autentikasi dan navigasi ke halaman yang sesuai
  void _checkAuthState() {
    final User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // User sudah login, navigasi ke home screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    } else {
      // User belum login, navigasi ke welcome screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/background1.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}