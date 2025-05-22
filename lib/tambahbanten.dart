import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'dart:io';

class TambahBantenPage extends StatefulWidget {
  const TambahBantenPage({super.key});

  @override
  State<TambahBantenPage> createState() => _TambahBantenPageState();
}

class _TambahBantenPageState extends State<TambahBantenPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaBantenController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // ADDED: Missing controller
  final TextEditingController _sejarahController = TextEditingController();
  final TextEditingController _daerahController = TextEditingController();
  final TextEditingController _sumberReferensiController = TextEditingController();
  final TextEditingController _imageLinkController = TextEditingController();
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isUploading = false;
  String? _previewImageUrl;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    final user = _auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login terlebih dahulu'))
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _namaBantenController.dispose();
    _descriptionController.dispose(); // ADDED: Missing dispose
    _sejarahController.dispose();
    _daerahController.dispose();
    _sumberReferensiController.dispose();
    _imageLinkController.dispose();
    super.dispose();
  }
  
  // Function to pick image
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _previewImageUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }
  
  // Function to preview link image
  void _previewLinkImage() {
    final url = _imageLinkController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _previewImageUrl = url;
        _selectedImage = null;
      });
    } else {
      setState(() {
        _previewImageUrl = null;
      });
    }
  }
  
  // Function to upload image and get URL
  Future<String?> _uploadImage() async {
    if (_selectedImage == null && _imageLinkController.text.isNotEmpty) {
      return _imageLinkController.text.trim();
    }
    
    if (_selectedImage == null) {
      return null;
    }
    
    try {
      final path = 'banten/${DateTime.now().millisecondsSinceEpoch}_image.jpg';
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(_selectedImage!);
      
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading image: ${e.toString()}');
      return null;
    }
  }
  
  // Function to save data to Firestore
  Future<void> _saveBantenData() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add Banten')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // 1. Get user data
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      Map<String, dynamic>? userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
      
      // 2. Upload image if selected or use image link
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      } else if (_previewImageUrl != null) {
        imageUrl = _previewImageUrl;
      } else if (_imageLinkController.text.isNotEmpty) {
        imageUrl = _imageLinkController.text.trim();
      }
      
      // 3. Create photos array
      List<String> photos = [];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        photos.add(imageUrl);
      }
      
      // 4. Save data to Firestore - FIXED: Field mapping sesuai Firebase dan BantenModel
      await _firestore.collection('bantens').add({
        'userId': currentUser.uid,
        'namaBanten': _namaBantenController.text.trim(), // Konsisten dengan BantenModel
        'description': _descriptionController.text.trim(),    // FIXED: Menggunakan _descriptionController
        'sejarah': _sejarahController.text.trim(),        // FIXED: Field sejarah terpisah
        'daerah': _daerahController.text.trim(),          // Field daerah -> daerah
        'guddenKeyword': _sumberReferensiController.text.trim(),
        'photos': photos,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userName': userData?['name'] ?? currentUser.displayName ?? 'Anonymous',
        'userEmail': currentUser.email,
        'username': userData?['username'] ?? '',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banten berhasil disimpan')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Banten",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Banten Field
              _buildTextField(
                controller: _namaBantenController,
                hintText: 'Nama Banten',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi nama banten';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // ADDED: description Field (sesuai UI Figma)
              _buildTextField(
                controller: _descriptionController,
                hintText: 'description',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sejarah Field
              _buildTextField(
                controller: _sejarahController,
                hintText: 'Sejarah',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi sejarah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Daerah yang menggunakan Field
              _buildTextField(
                controller: _daerahController,
                hintText: 'Daerah yang menggunakan',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi daerah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sumber Referensi Field
              _buildTextField(
                controller: _sumberReferensiController,
                hintText: 'Sumber Referensi',
              ),
              const SizedBox(height: 16),
              
              // Image picker area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _previewImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _previewImageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error, color: Colors.red),
                                        SizedBox(height: 8),
                                        Text('Gagal memuat gambar', 
                                            style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 50,
                                color: Color(0xFF64B5F6),
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Paste the image link Field
              _buildTextField(
                controller: _imageLinkController,
                hintText: 'Paste the image link',
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _previewLinkImage();
                  }
                },
              ),
              const SizedBox(height: 32),
              
              // Posting Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _saveBantenData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Posting',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 2) {
            // Navigate to Profile
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  // Helper method to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 16
        ),
      ),
      validator: validator,
    );
  }
}