import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart'; // Import login screen
import 'dart:io';

class TambahBantenPage extends StatefulWidget {
  const TambahBantenPage({super.key});

  @override
  State<TambahBantenPage> createState() => _TambahBantenPageState();
}

class _TambahBantenPageState extends State<TambahBantenPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaBantenController = TextEditingController();
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
    // Pastikan pengguna sudah login saat halaman dibuka
    _checkAuth();
  }

  // Fungsi untuk memeriksa apakah pengguna sudah login
  void _checkAuth() {
    final user = _auth.currentUser;
    if (user == null) {
      // Jika belum login, arahkan ke halaman login
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
          // Reset preview image URL jika gambar baru dipilih
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
        // Reset selected image jika menggunakan URL
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
    // If using link directly, return the link
    if (_selectedImage == null && _imageLinkController.text.isNotEmpty) {
      return _imageLinkController.text.trim();
    }
    
    // If selected image is null and no link, return null
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
    // Check if user is logged in
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
      // 1. Get user data to get username
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
      
      // 4. Save data to Firestore - using 'bantens' collection as in your Firestore
      await _firestore.collection('bantens').add({
        'userId': currentUser.uid,
        'namaBanten': _namaBantenController.text,
        'deskripsi': _sejarahController.text, // Field for 'sejarah'
        'sarana': _daerahController.text,     // Field for 'daerah yang menggunakan'
        'guddenKeyword': _sumberReferensiController.text,  // Field for 'sumber referensi'
        'photos': photos,                     // Array of photo URLs
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userName': userData?['name'] ?? currentUser.displayName ?? 'Anonymous',
        'userEmail': currentUser.email,
        'username': userData?['username'] ?? '',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banten berhasil disimpan')),
      );
      
      // Navigate back after successful save
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
    // Jika pengguna tidak login, tidak perlu render UI
    if (_auth.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Banten"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Banten
              _buildTextField(
                controller: _namaBantenController,
                label: 'Nama Banten',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi nama banten';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sejarah
              _buildTextField(
                controller: _sejarahController,
                label: 'Sejarah',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi sejarah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Daerah yang menggunakan
              _buildTextField(
                controller: _daerahController,
                label: 'Daerah yang menggunakan',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi daerah';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sumber Referensi
              _buildTextField(
                controller: _sumberReferensiController,
                label: 'Sumber Referensi',
              ),
              const SizedBox(height: 16),
              
              // Image picker area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _previewImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _previewImageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / 
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
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
                                Icons.image,
                                size: 50,
                                color: Colors.blue,
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Image Link input with preview button
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _imageLinkController,
                      label: 'Paste the image link',
                      hint: 'Optional: jika ada URL gambar',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.preview, color: Colors.blue),
                    onPressed: _previewLinkImage,
                    tooltip: 'Preview image',
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveBantenData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53B493),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading // Menggunakan _isUploading, bukan _isLoading
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Add tab
        onTap: (index) {
          if (index == 0) {
            // Navigate to Explore
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 2) {
            // Navigate to Profile
            // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
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
  
  // Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}