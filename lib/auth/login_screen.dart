import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apk_mebanten/screens/home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  final String? message;
  final String? routeAfterLogin;
  
  const LoginScreen({
    super.key,
    this.message,
    this.routeAfterLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFormValid = false;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  

    if (widget.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.message!)),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Function to validate form fields
  void _validateForm() {
    setState(() {
      _isFormValid = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  // Function to handle login - Revised
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 1. Login dengan Firebase Authentication
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. User berhasil login
      if (userCredential.user != null) {
        // 3. Update updatedAt di Firestore
        try {
          await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
          });
        } catch (e) {
          // Jika gagal update, itu bukan masalah fatal
          print('Warning: Could not update user timestamp: $e');
        }
        
        // 4. Navigate sesuai parameter atau ke home
        if (widget.routeAfterLogin == 'home_screen') {
          // Jika ditentukan untuk pergi ke add_banten
          Navigator.of(context).pushNamedAndRemoveUntil('/home_screen', (route) => false);
        } else {
          // Default navigasi ke Home Screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      print('Error during login: $e'); // Logging untuk debugging
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   
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
                      height: screenHeight * 0.4,
                      width: screenWidth * 1.5,
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
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Welcome text
                        Text(
                          'Om Swastyastu!',
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
                              hintText: 'Alamat Email',
                              hintStyle: GoogleFonts.inter(color: const Color.fromARGB(255, 95, 95, 95)),
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
                              hintText: 'Kata Sandi',
                              hintStyle: GoogleFonts.inter(color: const Color.fromARGB(255, 95, 95, 95)),
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
                              'Lupa Password?',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF3FAE82),
                                fontSize: screenHeight * 0.022,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Error message
                        if (_errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(
                                color: Colors.red,
                                fontSize: screenHeight * 0.018,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.055,
                          child: ElevatedButton(
                            onPressed: (_isFormValid && !_isLoading) ? _login : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF53B493),
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Masuk',
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
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: screenHeight * 0.018,
                              ),
                              children: [
                                const TextSpan(text: "Belum memiliki akun? "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Daftar di sini',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF3FAE82),
                                        fontSize: 18,
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
                            'Atau lanjutkan dengan',
                            style: GoogleFonts.inter(
                              color: const Color.fromARGB(255, 0, 0, 0),
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