import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';  // ← NEW: Permission handling
import '../auth/login_screen.dart';
import './screens/profile_page.dart';
import './screens/home_screen.dart';
import 'dart:io';

class TambahBantenPage extends StatefulWidget {
  const TambahBantenPage({super.key});

  @override
  State<TambahBantenPage> createState() => _TambahBantenPageState();
}

class _TambahBantenPageState extends State<TambahBantenPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaBantenController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sejarahController = TextEditingController();
  final TextEditingController _daerahController = TextEditingController();
  final TextEditingController _isiBantenController = TextEditingController();
  final TextEditingController _carabuatBantenController = TextEditingController();
  final TextEditingController _sumberReferensiController = TextEditingController();
  final TextEditingController _imageLinkController = TextEditingController();
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  // ENHANCED: Support camera + gallery + link (but still single image)
  File? _selectedImage;
  bool _isUploading = false;
  String? _previewImageUrl;
  String _imageSource = ''; // Track source: "camera", "gallery", "link"

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
    _descriptionController.dispose();
    _sejarahController.dispose();
    _daerahController.dispose();
    _isiBantenController.dispose();
    _carabuatBantenController.dispose();
    _sumberReferensiController.dispose();
    _imageLinkController.dispose();
    super.dispose();
  }
  
  // Function to launch URL for reference
  Future<void> _launchURL(String url) async {
    String finalUrl = url.trim();
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }
    
    try {
      final Uri uri = Uri.parse(finalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka URL')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error membuka URL: $e')),
        );
      }
    }
  }
  
  // ENHANCED: Show image source selection dialog (Camera + Gallery only)
  void _showImageSourceDialog() {
    print('🔍 DEBUG: Image source dialog opened');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                title: Text('Ambil Foto'),
                subtitle: Text('Gunakan kamera'),
                onTap: () {
                  print('🔍 DEBUG: Camera option selected');
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                title: Text('Pilih dari Galeri'),
                subtitle: Text('Pilih foto yang ada'),
                onTap: () {
                  print('🔍 DEBUG: Gallery option selected');
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // NEW: Check and request permissions
  Future<void> _checkPermissions() async {
    print('🔍 DEBUG: Checking permissions...');
    
    try {
      // Check storage permission
      final storageStatus = await Permission.storage.status;
      print('🔍 DEBUG: Storage permission status: $storageStatus');
      
      // Check camera permission  
      final cameraStatus = await Permission.camera.status;
      print('🔍 DEBUG: Camera permission status: $cameraStatus');
      
      // Check photos permission (for iOS and Android 13+)
      final photosStatus = await Permission.photos.status;
      print('🔍 DEBUG: Photos permission status: $photosStatus');
      
      // Request storage permission if not granted
      if (!storageStatus.isGranted) {
        print('🔍 DEBUG: Requesting storage permission...');
        final result = await Permission.storage.request();
        print('🔍 DEBUG: Storage permission request result: $result');
        
        if (!result.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Storage permission diperlukan untuk memilih gambar'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      
      // Request camera permission if not granted
      if (!cameraStatus.isGranted) {
        print('🔍 DEBUG: Requesting camera permission...');
        final result = await Permission.camera.request();
        print('🔍 DEBUG: Camera permission request result: $result');
        
        if (!result.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Camera permission diperlukan untuk mengambil foto'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      // Request photos permission if not granted (for Android 13+)
      if (!photosStatus.isGranted) {
        print('🔍 DEBUG: Requesting photos permission...');
        final result = await Permission.photos.request();
        print('🔍 DEBUG: Photos permission request result: $result');
      }
      
      print('✅ DEBUG: Permission check completed');
      
    } catch (e) {
      print('💥 DEBUG: Error checking permissions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // ENHANCED: Function to pick image (now supports camera + gallery) - WITH FULL DEBUG
  Future<void> _pickImage(ImageSource source) async {
    // NEW: Check permissions first
    await _checkPermissions();
    
    try {
      print('🔍 DEBUG: Starting image pick from $source');
      print('🔍 DEBUG: ImagePicker instance: ${_picker.runtimeType}');
      print('🔍 DEBUG: Current platform: ${Theme.of(context).platform}');
      
      final XFile? image = await _picker.pickImage(
        source: source, // ← ENHANCED: Can be camera or gallery
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      print('🔍 DEBUG: Image picker completed');
      print('🔍 DEBUG: Selected image: ${image?.path}');
      print('🔍 DEBUG: Image name: ${image?.name}');
      print('🔍 DEBUG: Image mimeType: ${image?.mimeType}');
      
      if (image != null) {
        final file = File(image.path);
        print('🔍 DEBUG: File created from path: ${image.path}');
        print('🔍 DEBUG: File exists: ${file.existsSync()}');
        
        if (file.existsSync()) {
          final fileSize = await file.length();
          print('🔍 DEBUG: File size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');
          
          // Test reading file to make sure it's accessible
          try {
            final bytes = await file.readAsBytes();
            print('🔍 DEBUG: File readable, byte length: ${bytes.length}');
          } catch (e) {
            print('❌ DEBUG: File not readable: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('File tidak dapat dibaca: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
          
          setState(() {
            _selectedImage = File(image.path);
            _previewImageUrl = null;
            _imageLinkController.clear(); // Clear image link when file selected
            _imageSource = source == ImageSource.camera ? 'camera' : 'gallery';
          });
          
          print('✅ DEBUG: State updated successfully');
          print('🔍 DEBUG: _selectedImage is null: ${_selectedImage == null}');
          print('🔍 DEBUG: _selectedImage path: ${_selectedImage?.path}');
          print('🔍 DEBUG: _imageSource: $_imageSource');
          
          // Success feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gambar berhasil dipilih dari $_imageSource'),
                backgroundColor: Color(0xFF4CAF50),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          print('❌ DEBUG: File does not exist at the specified path');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File gambar tidak ditemukan di path: ${image.path}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        print('❌ DEBUG: No image selected (user cancelled or error)');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak ada gambar yang dipilih'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('💥 DEBUG: Error picking image: $e');
      print('💥 DEBUG: Error type: ${e.runtimeType}');
      print('💥 DEBUG: Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  // ENHANCED: Function to preview link image - WITH DEBUG
  void _previewLinkImage() {
    final url = _imageLinkController.text.trim();
    print('🔍 DEBUG: Preview link called with URL: $url');
    
    if (url.isNotEmpty) {
      setState(() {
        _previewImageUrl = url;
        _selectedImage = null; // Clear file when link is used
        _imageSource = 'link';
      });
      print('✅ DEBUG: Link preview set successfully');
      print('🔍 DEBUG: _previewImageUrl: $_previewImageUrl');
      print('🔍 DEBUG: _imageSource: $_imageSource');
    } else {
      setState(() {
        _previewImageUrl = null;
        _imageSource = '';
      });
      print('🔍 DEBUG: Link preview cleared');
    }
  }
  
  // ENHANCED: Function to upload image and get URL - WITH FULL DEBUG
  Future<String?> _uploadImage() async {
    print('🔍 DEBUG: Starting upload process');
    print('🔍 DEBUG: _selectedImage is null: ${_selectedImage == null}');
    print('🔍 DEBUG: _imageLinkController.text: ${_imageLinkController.text}');
    print('🔍 DEBUG: _previewImageUrl: $_previewImageUrl');
    
    // If using link, return the link directly
    if (_selectedImage == null && _imageLinkController.text.isNotEmpty) {
      print('✅ DEBUG: Using link URL: ${_imageLinkController.text.trim()}');
      return _imageLinkController.text.trim();
    }
    
    // If no file selected, return null
    if (_selectedImage == null) {
      print('❌ DEBUG: No image to upload');
      return null;
    }
    
    try {
      print('🔍 DEBUG: Uploading file to Firebase Storage');
      print('🔍 DEBUG: File path: ${_selectedImage!.path}');
      print('🔍 DEBUG: File exists before upload: ${_selectedImage!.existsSync()}');
      
      if (!_selectedImage!.existsSync()) {
        print('❌ DEBUG: File does not exist, cannot upload');
        return null;
      }
      
      final fileSize = await _selectedImage!.length();
      print('🔍 DEBUG: File size before upload: $fileSize bytes');
      
      // Test file readability before upload
      try {
        final bytes = await _selectedImage!.readAsBytes();
        print('🔍 DEBUG: File readable for upload, byte length: ${bytes.length}');
      } catch (e) {
        print('❌ DEBUG: File not readable for upload: $e');
        return null;
      }
      
      final path = 'banten/${DateTime.now().millisecondsSinceEpoch}_image.jpg';
      print('🔍 DEBUG: Firebase Storage path: $path');
      
      final ref = _storage.ref().child(path);
      print('🔍 DEBUG: Storage reference created');
      
      final uploadTask = ref.putFile(_selectedImage!);
      print('🔍 DEBUG: Upload task started');
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('🔍 DEBUG: Upload progress: ${(progress * 100).toStringAsFixed(1)}% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)');
      });
      
      final snapshot = await uploadTask.whenComplete(() {
        print('🔍 DEBUG: Upload completed');
      });
      
      final url = await snapshot.ref.getDownloadURL();
      print('✅ DEBUG: Download URL obtained: $url');
      
      return url;
    } catch (e, stackTrace) {
      print('💥 DEBUG: Error uploading image: $e');
      print('💥 DEBUG: Upload error type: ${e.runtimeType}');
      print('💥 DEBUG: Upload stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
  
  // ENHANCED: Function to save data to Firestore
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
      print('🔍 DEBUG: Starting save process');
      
      // 1. Get user data
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      Map<String, dynamic>? userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
      print('🔍 DEBUG: User data retrieved');
      
      // 2. Upload image if selected or use image link
      String? imageUrl;
      if (_selectedImage != null) {
        print('🔍 DEBUG: Uploading file image');
        imageUrl = await _uploadImage();
      } else if (_previewImageUrl != null) {
        print('🔍 DEBUG: Using preview URL');
        imageUrl = _previewImageUrl;
      } else if (_imageLinkController.text.isNotEmpty) {
        print('🔍 DEBUG: Using link field URL');
        imageUrl = _imageLinkController.text.trim();
      }
      
      print('🔍 DEBUG: Final image URL: $imageUrl');
      
      // 3. Create photos array
      List<String> photos = [];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        photos.add(imageUrl);
      }
      print('🔍 DEBUG: Photos array: $photos');
      
      // 4. Save data to Firestore
      await _firestore.collection('bantens').add({
        'userId': currentUser.uid,
        'namaBanten': _namaBantenController.text.trim(),          
        'description': _descriptionController.text.trim(),  
        'sejarah': _sejarahController.text.trim(),          
        'daerah': _daerahController.text.trim(),
        'isiBanten': _isiBantenController.text.trim(),
        'carabuatBanten': _carabuatBantenController.text.trim(),             
        'guddenKeyword': _sumberReferensiController.text.trim(),
        'photos': photos,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userName': userData?['name'] ?? currentUser.displayName ?? 'Anonymous',
        'userEmail': currentUser.email,
        'username': userData?['username'] ?? '',
      });
      
      print('✅ DEBUG: Data saved to Firestore successfully');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banten berhasil disimpan'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      print('💥 DEBUG: Error saving data: $e');
      print('💥 DEBUG: Save error type: ${e.runtimeType}');
      print('💥 DEBUG: Save stack trace: $stackTrace');
      
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
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Tambah Banten",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
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
              
              // Description Field
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Deskripsi',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi deskripsi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sejarah Field
              _buildTextField(
                controller: _sejarahController,
                hintText: 'Sejarah',
                maxLines: 4,
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

              _buildTextField(
                controller: _isiBantenController,
                hintText: 'Isi Banten',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi komponen dari banten yang ingin ditambahkan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _carabuatBantenController,
                hintText: 'Cara Pembuatan Banten',
                maxLines: 7,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi cara pembuatan banten';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sumber Referensi Field with URL launcher
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _sumberReferensiController,
                    hintText: 'Sumber Referensi (URL)',
                    keyboardType: TextInputType.url,
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild to show/hide URL button
                    },
                  ),
                  const SizedBox(height: 8),

                  if (_sumberReferensiController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: GestureDetector(
                        onTap: () => _launchURL(_sumberReferensiController.text),
                        child: Row(
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Klik untuk buka URL',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // ENHANCED: Image picker area with 3 sources support - WITH DEBUG UI
              GestureDetector(
                onTap: () {
                  print('🔍 DEBUG: Image area tapped');
                  _showImageSourceDialog();
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if (frame == null) {
                                    print('🔍 DEBUG: Image frame is null, still loading...');
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(color: Color(0xFF4CAF50)),
                                            SizedBox(height: 8),
                                            Text('Loading image...'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  print('✅ DEBUG: Image frame loaded: $frame');
                                  return child;
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('💥 DEBUG: Image display error: $error');
                                  print('💥 DEBUG: Image error type: ${error.runtimeType}');
                                  print('💥 DEBUG: Image error stack: $stackTrace');
                                  return Container(
                                    color: Colors.red[100],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error, color: Colors.red, size: 40),
                                          SizedBox(height: 8),
                                          Text('Image Error', style: TextStyle(fontWeight: FontWeight.bold)),
                                          SizedBox(height: 4),
                                          Text('Tap to retry', style: TextStyle(fontSize: 12)),
                                          SizedBox(height: 4),
                                          Text(
                                            'Error: ${error.toString()}',
                                            style: TextStyle(fontSize: 10, color: Colors.red),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // ENHANCED: Source indicator
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _imageSource.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  print('🔍 DEBUG: Remove image button tapped');
                                  setState(() {
                                    _selectedImage = null;
                                    _imageSource = '';
                                  });
                                  print('✅ DEBUG: Image removed from state');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _previewImageUrl != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _previewImageUrl!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        print('✅ DEBUG: Network image loaded successfully');
                                        return child;
                                      }
                                      print('🔍 DEBUG: Loading network image... ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF4CAF50),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('💥 DEBUG: Network image error: $error');
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
                                ),
                                // ENHANCED: Source indicator for link
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'LINK',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      print('🔍 DEBUG: Remove link image button tapped');
                                      setState(() {
                                        _previewImageUrl = null;
                                        _imageLinkController.clear();
                                        _imageSource = '';
                                      });
                                      print('✅ DEBUG: Link image removed from state');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 50,
                                    color: Color(0xFF64B5F6),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Ketuk untuk menambahkan gambar',
                                    style: TextStyle(
                                      color: Color(0xFF64B5F6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pilih dari kamera atau galeri',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 16),
              
              // KEPT: Original image link field (for direct paste)
              _buildTextField(
                controller: _imageLinkController,
                hintText: 'Salin tautan gambar (opsional)',
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  print('🔍 DEBUG: Image link field changed: $value');
                  if (value.isNotEmpty) {
                    _previewLinkImage();
                  } else {
                    setState(() {
                      _previewImageUrl = null;
                      _imageSource = '';
                    });
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
                      backgroundColor: const Color(0xFF86C0AC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
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
      // Consistent BottomNavigationBar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 1, // Add tab active
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          onTap: (index) {
            switch (index) {
              case 0:
                // Navigate back to Home/Explore
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
                break;
              case 1:
                // Already on Add page - do nothing
                break;
              case 2:
                // Navigate to Profile page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 24),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add, size: 24),
              activeIcon: Icon(Icons.add, size: 24),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              label: 'Profile',
            ),
          ],
        ),
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
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: keyboardType,
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