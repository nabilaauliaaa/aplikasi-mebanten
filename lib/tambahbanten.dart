import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
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
  
  // Image handling
  File? _selectedImage;
  bool _isUploading = false;
  String? _previewImageUrl;
  String _imageSource = '';

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
          _showErrorMessage('Tidak dapat membuka URL');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error membuka URL: $e');
      }
    }
  }
  
  // Show image source selection dialog
  void _showImageSourceDialog() {
    print('🔍 DEBUG: Image source dialog opened');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF53B493)),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Gunakan kamera'),
                onTap: () {
                  print('🔍 DEBUG: Camera option selected');
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF53B493)),
                title: const Text('Pilih dari Galeri'),
                subtitle: const Text('Pilih foto yang ada'),
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

  // Check and request permissions
  Future<bool> _checkAndRequestPermissions(ImageSource source) async {
    try {
      print('🔍 DEBUG: Checking permissions for $source');
      
      if (source == ImageSource.camera) {
        var cameraStatus = await Permission.camera.status;
        print('🔍 DEBUG: Camera permission status: $cameraStatus');
        
        if (!cameraStatus.isGranted) {
          cameraStatus = await Permission.camera.request();
          if (!cameraStatus.isGranted) {
            _showErrorMessage('Permission kamera diperlukan untuk mengambil foto');
            return false;
          }
        }
      }
      
      // For gallery access
      if (Platform.isAndroid) {
        // Android 13+ uses photos permission
        var photosStatus = await Permission.photos.status;
        print('🔍 DEBUG: Photos permission status: $photosStatus');
        
        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
          if (!photosStatus.isGranted) {
            // Fallback to storage permission for older Android
            var storageStatus = await Permission.storage.status;
            if (!storageStatus.isGranted) {
              storageStatus = await Permission.storage.request();
              if (!storageStatus.isGranted) {
                _showErrorMessage('Permission storage diperlukan untuk memilih gambar');
                return false;
              }
            }
          }
        }
      } else if (Platform.isIOS) {
        var photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
          if (!photosStatus.isGranted) {
            _showErrorMessage('Permission photos diperlukan untuk memilih gambar');
            return false;
          }
        }
      }
      
      print('✅ DEBUG: All permissions granted');
      return true;
      
    } catch (e) {
      print('💥 DEBUG: Error checking permissions: $e');
      _showErrorMessage('Error checking permissions: $e');
      return false;
    }
  }
  
  // Enhanced image picker with full debugging
  Future<void> _pickImage(ImageSource source) async {
    try {
      print('🔍 DEBUG: Starting image pick from $source');
      
      // Check permissions first
      bool hasPermission = await _checkAndRequestPermissions(source);
      if (!hasPermission) {
        print('❌ DEBUG: Permissions not granted');
        return;
      }
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      print('🔍 DEBUG: Image picker result: ${image?.path}');
      
      if (image != null) {
        final file = File(image.path);
        
        // Verify file exists and is readable
        if (!await file.exists()) {
          print('❌ DEBUG: File does not exist at path: ${image.path}');
          _showErrorMessage('File gambar tidak ditemukan');
          return;
        }
        
        try {
          final bytes = await file.readAsBytes();
          print('✅ DEBUG: File readable, size: ${bytes.length} bytes');
          
          setState(() {
            _selectedImage = file;
            _previewImageUrl = null;
            _imageLinkController.clear();
            _imageSource = source == ImageSource.camera ? 'camera' : 'gallery';
          });
          
          print('✅ DEBUG: State updated successfully');
          _showSuccessMessage('Gambar berhasil dipilih dari $_imageSource');
          
        } catch (e) {
          print('❌ DEBUG: File not readable: $e');
          _showErrorMessage('File gambar tidak dapat dibaca: $e');
        }
      } else {
        print('ℹ️ DEBUG: No image selected');
        _showInfoMessage('Tidak ada gambar yang dipilih');
      }
    } catch (e, stackTrace) {
      print('💥 DEBUG: Error in _pickImage: $e');
      print('💥 DEBUG: Stack trace: $stackTrace');
      _showErrorMessage('Error memilih gambar: $e');
    }
  }
  
  // Preview link image
  void _previewLinkImage() {
    final url = _imageLinkController.text.trim();
    print('🔍 DEBUG: Preview link called with URL: $url');
    
    if (url.isNotEmpty) {
      setState(() {
        _previewImageUrl = url;
        _selectedImage = null;
        _imageSource = 'link';
      });
      print('✅ DEBUG: Link preview set successfully');
    } else {
      setState(() {
        _previewImageUrl = null;
        _imageSource = '';
      });
      print('🔍 DEBUG: Link preview cleared');
    }
  }

  // Validate image URL format
  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      if (!uri.hasScheme) return false;
      if (!['http', 'https'].contains(uri.scheme.toLowerCase())) return false;
      
      // For Firebase Storage URLs, check the pattern
      if (url.contains('firebasestorage.googleapis.com')) {
        return url.contains('/o/') && url.contains('?alt=media');
      }
      
      return true;
      
    } catch (e) {
      print('💥 DEBUG: Invalid URL format: $e');
      return false;
    }
  }

  // Verify uploaded image is accessible
  Future<void> _verifyUploadedImage(String url) async {
    try {
      print('🔍 DEBUG: Verifying uploaded image accessibility...');
      
      final response = await http.head(Uri.parse(url));
      print('🔍 DEBUG: Image verification response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ DEBUG: Image is accessible at: $url');
        final contentType = response.headers['content-type'];
        print('🔍 DEBUG: Content-Type: $contentType');
      } else {
        print('❌ DEBUG: Image not accessible, status: ${response.statusCode}');
      }
      
    } catch (e) {
      print('💥 DEBUG: Error verifying image: $e');
    }
  }
  
  // Enhanced upload with verification
  Future<String?> _uploadImage() async {
    print('🔍 DEBUG: Starting upload process');
    print('🔍 DEBUG: _selectedImage: ${_selectedImage?.path}');
    print('🔍 DEBUG: _imageLinkController.text: "${_imageLinkController.text}"');
    
    // If using link, return the link directly
    if (_selectedImage == null && _imageLinkController.text.isNotEmpty) {
      final linkUrl = _imageLinkController.text.trim();
      print('✅ DEBUG: Using link URL: $linkUrl');
      return linkUrl;
    }
    
    // If no file selected, return null
    if (_selectedImage == null) {
      print('ℹ️ DEBUG: No image to upload');
      return null;
    }
    
    try {
      // Verify file still exists before upload
      if (!await _selectedImage!.exists()) {
        print('❌ DEBUG: File no longer exists at upload time');
        _showErrorMessage('File gambar sudah tidak ada');
        return null;
      }
      
      final fileSize = await _selectedImage!.length();
      print('🔍 DEBUG: File size: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
      
      if (fileSize == 0) {
        print('❌ DEBUG: File is empty');
        _showErrorMessage('File gambar kosong');
        return null;
      }
      
      if (fileSize > 10 * 1024 * 1024) {
        _showErrorMessage('File terlalu besar (maksimal 10MB)');
        return null;
      }
      
      // Create unique path with proper extension
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String userId = _auth.currentUser!.uid;
      final String fileName = 'banten_${timestamp}_$userId.jpg';
      final String path = 'banten_images/$fileName';
      
      print('🔍 DEBUG: Uploading to path: $path');
      
      // Create storage reference
      final ref = _storage.ref().child(path);
      
      // Upload with proper metadata
      final uploadTask = ref.putFile(
        _selectedImage!,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=3600',
          customMetadata: {
            'uploaded_by': userId,
            'upload_time': DateTime.now().toIso8601String(),
            'original_size': fileSize.toString(),
          },
        ),
      );
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📊 DEBUG: Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      // Wait for upload completion
      final snapshot = await uploadTask;
      print('✅ DEBUG: Upload completed successfully');
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ DEBUG: Download URL obtained: $downloadUrl');
      
      // Verify the URL is accessible
      await _verifyUploadedImage(downloadUrl);
      
      return downloadUrl;
      
    } catch (e, stackTrace) {
      print('💥 DEBUG: Upload error: $e');
      print('💥 DEBUG: Upload error type: ${e.runtimeType}');
      print('💥 DEBUG: Upload stack trace: $stackTrace');
      
      _showErrorMessage('Gagal upload gambar: ${e.toString()}');
      return null;
    }
  }
  
  // Enhanced save method with validation
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
      
      // Get user data
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      Map<String, dynamic>? userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
      
      // Upload image and get URL
      String? imageUrl = await _uploadImage();
      print('🔍 DEBUG: Upload result - imageUrl: $imageUrl');
      
      // Create photos array - IMPORTANT: Only add valid URLs
      List<String> photos = [];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        if (_isValidImageUrl(imageUrl)) {
          photos.add(imageUrl);
          print('✅ DEBUG: Valid image URL added to photos: $imageUrl');
        } else {
          print('❌ DEBUG: Invalid image URL format: $imageUrl');
        }
      }
      
      print('🔍 DEBUG: Final photos array: $photos');
      
      // Prepare document data
      final docData = {
        'userId': currentUser.uid,
        'namaBanten': _namaBantenController.text.trim(),          
        'description': _descriptionController.text.trim(),  
        'sejarah': _sejarahController.text.trim(),          
        'daerah': _daerahController.text.trim(),
        'isiBanten': _isiBantenController.text.trim(),
        'carabuatBanten': _carabuatBantenController.text.trim(),             
        'guddenKeyword': _sumberReferensiController.text.trim(),
        'photos': photos, // Critical field for image display
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userName': userData?['name'] ?? currentUser.displayName ?? 'Anonymous',
        'userEmail': currentUser.email,
        'username': userData?['username'] ?? '',
      };
      
      print('🔍 DEBUG: Document data to save:');
      docData.forEach((key, value) {
        print('  $key: $value');
      });
      
      // Save to Firestore
      DocumentReference docRef = await _firestore.collection('bantens').add(docData);
      print('✅ DEBUG: Document saved with ID: ${docRef.id}');
      
      // Verify the saved document
      DocumentSnapshot savedDoc = await docRef.get();
      if (savedDoc.exists) {
        Map<String, dynamic> savedData = savedDoc.data() as Map<String, dynamic>;
        print('✅ DEBUG: Verified saved photos: ${savedData['photos']}');
        print('✅ DEBUG: Photos array length: ${(savedData['photos'] as List).length}');
      }
      
      _showSuccessMessage('Banten berhasil disimpan');
      Navigator.of(context).pop();
      
    } catch (e, stackTrace) {
      print('💥 DEBUG: Error saving data: $e');
      print('💥 DEBUG: Save error type: ${e.runtimeType}');
      print('💥 DEBUG: Save stack trace: $stackTrace');
      
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Remove image from state
  void _removeImage() {
    print('🔍 DEBUG: Removing image');
    setState(() {
      _selectedImage = null;
      _previewImageUrl = null;
      _imageLinkController.clear();
      _imageSource = '';
    });
    print('✅ DEBUG: Image removed from state');
  }

  // Image preview widget
  Widget _buildImagePreview() {
    return GestureDetector(
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
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // Show selected file image
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder<bool>(
              future: _selectedImage!.exists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }
                
                if (snapshot.hasError || !(snapshot.data ?? false)) {
                  print('❌ DEBUG: File check failed: ${snapshot.error}');
                  return _buildErrorIndicator('File tidak ditemukan');
                }
                
                return Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (frame == null) {
                      return _buildLoadingIndicator();
                    }
                    return child;
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('💥 DEBUG: Image.file error: $error');
                    return _buildErrorIndicator('Gagal memuat gambar');
                  },
                );
              },
            ),
          ),
          _buildImageOverlay(),
        ],
      );
    }
    
    // Show preview from URL
    if (_previewImageUrl != null && _previewImageUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _previewImageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                print('💥 DEBUG: Network image error: $error');
                return _buildErrorIndicator('Gagal memuat gambar dari URL');
              },
            ),
          ),
          _buildImageOverlay(isLink: true),
        ],
      );
    }
    
    // Show placeholder
    return _buildPlaceholder();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF53B493)),
            SizedBox(height: 8),
            Text('Memuat gambar...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(String message) {
    return Container(
      color: Colors.red[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Ketuk untuk coba lagi',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOverlay({bool isLink = false}) {
    return Stack(
      children: [
        // Source indicator
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
              isLink ? 'LINK' : _imageSource.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeImage,
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
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
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
    );
  }

  // Helper methods for showing messages
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF53B493),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showInfoMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF53B493),
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
              
              // Enhanced Image picker area
              _buildImagePreview(),
              const SizedBox(height: 16),
              
              // Image link field (for direct paste)
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
                      backgroundColor: const Color(0xFF53B493),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                            'Unggah',
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
          selectedItemColor: const Color(0xFF53B493),
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
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add, size: 24),
              activeIcon: Icon(Icons.add, size: 24),
              label: 'Tambah Banten',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              label: 'Profil',
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
          borderSide: const BorderSide(color: Color(0xFF53B493), width: 2),
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