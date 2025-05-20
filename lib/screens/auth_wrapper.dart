// lib/screens/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'home_screen.dart'; // Atau halaman utama aplikasi Anda

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Cek koneksi selesai
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          
          // Jika tidak ada user yang login
          if (user == null) {
            return const LoginScreen();
          }
          
          // Jika user sudah login
          return const ExploreScreen(); // Ganti dengan halaman utama aplikasi Anda
        }
        
        // Menunggu koneksi selesai
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}