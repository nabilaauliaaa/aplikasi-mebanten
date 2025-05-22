// lib/main.dart
import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'screens/splash_screen.dart';

void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await FirebaseService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mebanten',
      theme: ThemeData(
        primaryColor: const Color(0xFF53B493),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF53B493),
          primary: const Color(0xFF53B493),
        ),
        // Tema lainnya
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}