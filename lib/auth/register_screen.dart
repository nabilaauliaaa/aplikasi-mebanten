import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // Function to handle registration - REVISI
  Future<void> _register() async {
    // Validate passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Kata sandi tidak cocok. Silakan coba lagi.';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 1. Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. If user created successfully, save additional user data
      if (userCredential.user != null) {
        // 3. Generate username unik
        final username = '@${_nameController.text.trim().toLowerCase().replaceAll(' ', '')}${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
        
        // 4. Simpan data user ke Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,           
          'name': _nameController.text.trim(),       
          'email': _emailController.text.trim(),     
          'username': username,                     
          'photoURL': null,                          
          'createdAt': FieldValue.serverTimestamp(), 
          'updatedAt': FieldValue.serverTimestamp(), 
        });
        
        // 5. Update display name di Firebase Auth
        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        
        // 6. Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran akun berhasil! Silakan masuk')),
        );
        
        // 7. Navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      
      switch (e.code) {
        case 'weak-password':
          message = 'Kata Sandi terlalu lemah, masukkan 8 karakter.';
          break;
        case 'email-already-in-use':
          message = 'Alamat email telah terdaftar.';
          break;
        case 'invalid-email':
          message = 'Alamat email tidak valid.';
          break;
        case 'operation-not-allowed':
          message = 'Alamat email/kata sandi tidak valid.';
          break;
        default:
          message = 'Terjadi error. Silakan coba lagi';
      }
      
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      print('Error during registration: $e'); // Logging untuk debugging
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
        width: screenWidth,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Akun',
                style: GoogleFonts.inter(
                  fontSize: screenHeight * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Daftar akun untuk memulai!',
                style: GoogleFonts.inter(
                  fontSize: screenHeight * 0.02,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              
              // Name field
              Text(
                'Nama',
                style: GoogleFonts.inter(
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                height: screenHeight * 0.06,
                child: TextField(
                  controller: _nameController,
                  style: GoogleFonts.inter(),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3FAE82), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              
              // Email field
              Text(
                'Alamat Email',
                style: GoogleFonts.inter(
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                height: screenHeight * 0.06,
                child: TextField(
                  controller: _emailController,
                  style: GoogleFonts.inter(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Masukkan email',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3FAE82), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              
              // Password field
              Text(
                'Kata Sandi',
                style: GoogleFonts.inter(
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                height: screenHeight * 0.06,
                child: TextField(
                  controller: _passwordController,
                  style: GoogleFonts.inter(),
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Buat kata sandi',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3FAE82), width: 2),
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
              SizedBox(height: screenHeight * 0.025),
              
              // Confirm Password field
              SizedBox(
                height: screenHeight * 0.06,
                child: TextField(
                  controller: _confirmPasswordController,
                  style: GoogleFonts.inter(),
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Konfirmasi Kata Sandi',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3FAE82), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
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
                      fontSize: screenHeight * 0.016,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Terms and conditions checkbox - UPDATED WITH STYLED LINKS
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value!;
                      });
                    },
                    activeColor: const Color(0xFF3FAE82),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: screenHeight * 0.018,
                        ),
                        children: [
                          const TextSpan(text: "Saya telah membaca dan menyetujui "),
                          TextSpan(
                            text: "Syarat dan Ketentuan",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF3FAE82),
                              fontSize: screenHeight * 0.018,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF3FAE82),
                            ),
                          ),
                          const TextSpan(text: " dan "),
                          TextSpan(
                            text: "Kebijakan Privasi",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF3FAE82),
                              fontSize: screenHeight * 0.018,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF3FAE82),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              
              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: (_agreeToTerms && !_isLoading) ? _register : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3FAE82),
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
                          'Daftar Akun',
                          style: GoogleFonts.inter(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              
              // Login link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: screenHeight * 0.018,
                    ),
                    children: [
                      const TextSpan(text: "Sudah memiliki akun? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            'Masuk di sini', 
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
            ],
          ),
        ),
      ),
    );
  }
}