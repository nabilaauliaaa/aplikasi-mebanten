import 'package:flutter/material.dart';
import 'package:apk_mebanten/auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _nextPage() {
    if (currentPage < 1) {  // Adjusted to limit to two pages
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Navigate to the next screen or do something after the last onboarding screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/background1.png',
              width: 415,
              height: 560,
              fit: BoxFit.cover,
            ),
          ),
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              // First Onboarding Screen
              _buildOnboardingScreen(
                image: 'assets/images/background1.png',
                title: 'Om Swastyastu',
                subtitle: 'Setiap persembahan adalah doa, setiap pencarian adalah makna',
              ),
              // Second Onboarding Screen
              _buildOnboardingScreen(
                image: 'assets/images/background1.png',
                title: 'Mebanten',
                subtitle: 'Selamat datang di Mebanten, rumah digital untuk menjaga warisan budaya Bali',
              ),
            ],
          ),
          // Next Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF53B493),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 155, vertical: 14),
                  textStyle: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  
                ),
                child: Text(currentPage == 1 ? 'Log In' : 'Next'),
                
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingScreen({required String image, required String title, required String subtitle}) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Image.asset(
            image,
            width: 415,
            height: 560,
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 15),  // Adjusted height
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 90), // Reduced distance between subtitle and button
              ],
            ),
          ),
        ),
      ],
    );
  }
}