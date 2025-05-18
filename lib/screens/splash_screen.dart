import 'package:flutter/material.dart';
import 'package:apk_mebanten/screens/welcome_screen.dart';

class SplashScreen extends StatelessWidget{
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(seconds: 3)).then((value){
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
          ),
          (route) => false);
    });
    return Scaffold(
      body: Stack(children: [Image.asset('assets/images/background1.png')]),
    );
  }
}