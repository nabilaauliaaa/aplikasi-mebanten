import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFF86C0AC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Column(
              children: [
                // Top section dengan gambar canang
                SizedBox(
                  height: screenHeight * 0.35,
                  child: Center(
                    child: Image.asset(
                      'assets/images/kedua.png',
                      height: screenHeight * 0.2,
                      width: screenWidth * 0.4,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                // Bottom section dengan form login
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.02,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start, // Align kiri
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Welcome text - di sisi kiri
                        Text(
                          'Welcome!',
                          style: GoogleFonts.inter(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Email field
                        SizedBox(
                          height: screenHeight * 0.055,
                          child: TextField(
                            controller: _emailController,
                            style: GoogleFonts.inter(),
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Password field
                        SizedBox(
                          height: screenHeight * 0.055,
                          child: TextField(
                            controller: _passwordController,
                            style: GoogleFonts.inter(),
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        
                        // Forgot password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF3FAE82),
                                fontSize: screenHeight * 0.018,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.055,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle login
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF53B493),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.inter(
                                fontSize: screenHeight * 0.022,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Register link - center aligned
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: screenHeight * 0.018,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account yet? "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Register here',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF3FAE82),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Continue with - center aligned
                        Center(
                          child: Text(
                            'Or continue with',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: screenHeight * 0.018,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Social login buttons - center aligned
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(Colors.red, null, screenHeight, text: 'G'),
                              SizedBox(width: screenWidth * 0.04),
                              _buildSocialButton(Colors.black, Icons.apple, screenHeight),
                              SizedBox(width: screenWidth * 0.04),
                              _buildSocialButton(Colors.blue, Icons.facebook, screenHeight),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(Color color, IconData? icon, double screenHeight, {String? text}) {
    return Container(
      width: screenHeight * 0.06,
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: icon != null 
        ? Icon(icon, color: Colors.white, size: screenHeight * 0.035)
        : Center(
            child: Text(
              text ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
    );
  }
}