// lib/services/banten_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/banten_model.dart';

class BantenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Create a new banten
  Future<DocumentReference> createBanten({
    required String namaBanten,
    required String daerah,
    required String description,
    String? sejarah,
    String? isiBanten,
    String? carabuatBanten,
    String? guddenKeyword,
    required List<XFile> images,
  }) async {
    // Check if user is logged in
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to create Banten');
    }
    
    // Get user data
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    Map<String, dynamic>? userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
    
    // Upload images
    List<String> imageUrls = await _uploadImages(images);
    
    // Create Banten document
    return await _firestore.collection('bantens').add({
      'userId': currentUser.uid,
      'namaBanten': namaBanten,
      'daerah': daerah,
      'description': description,
      'sejarah': sejarah ?? '',
      'isiBanten': isiBanten ?? '',
      'carabuatBanten': carabuatBanten ?? '',
      'guddenKeyword': guddenKeyword ?? '',
      'photos': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userName': userData?['name'] ?? currentUser.displayName ?? 'Anonymous',
      'userEmail': currentUser.email,
      'username': userData?['username'] ?? '',
    });
  }
  
  // Get all bantens - return Stream<List<BantenModel>> for easier use in UI
  Stream<List<BantenModel>> getAllBantens() {
    return _firestore
        .collection('bantens')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BantenModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }
  
  // Get all bantens as QuerySnapshot (for compatibility with existing UI)
  Stream<QuerySnapshot> getAllBantensAsQuerySnapshot() {
    return _firestore
        .collection('bantens')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Get bantens by user
  Stream<QuerySnapshot> getBantensByUser(String userId) {
    return _firestore
        .collection('bantens')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Get banten by ID
  Future<DocumentSnapshot> getBantenById(String bantenId) {
    return _firestore.collection('bantens').doc(bantenId).get();
  }
  
  // Get banten by ID as BantenModel
  Future<BantenModel> getBantenModelById(String bantenId) async {
    DocumentSnapshot doc = await _firestore.collection('bantens').doc(bantenId).get();
    if (!doc.exists) {
      throw Exception('Banten not found');
    }
    return BantenModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  }
  
  // Update a banten
  Future<void> updateBanten({
    required String bantenId,
    required String namaBanten,
    required String daerah,
    required String description,
    String? sejarah,
    String? isiBanten,
    String? carabuatBanten,
    String? guddenKeyword,
    List<XFile>? newImages,
    List<String>? existingImageUrls,
  }) async {
    // Check if user is logged in
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to update Banten');
    }
    
    // Check if the banten belongs to the user
    DocumentSnapshot doc = await _firestore.collection('bantens').doc(bantenId).get();
    if (!doc.exists) {
      throw Exception('Banten not found');
    }
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != currentUser.uid) {
      throw Exception('You do not have permission to update this Banten');
    }
    
    // Handle images
    List<String> updatedImageUrls = existingImageUrls ?? [];
    
    if (newImages != null && newImages.isNotEmpty) {
      List<String> newImageUrls = await _uploadImages(newImages);
      updatedImageUrls.addAll(newImageUrls);
    }
    
    // Update banten document
    await _firestore.collection('bantens').doc(bantenId).update({
      'namaBanten': namaBanten,
      'daerah': daerah,
      'description': description,
      'sejarah': sejarah ?? '',
      'isiBanten': isiBanten ?? '',
      'carabuatBanten': carabuatBanten ?? '',
      'guddenKeyword': guddenKeyword ?? '',
      'photos': updatedImageUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Delete a banten
  Future<void> deleteBanten(String bantenId) async {
    // Check if user is logged in
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to delete Banten');
    }
    
    // Check if the banten belongs to the user
    DocumentSnapshot doc = await _firestore.collection('bantens').doc(bantenId).get();
    if (!doc.exists) {
      throw Exception('Banten not found');
    }
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != currentUser.uid) {
      throw Exception('You do not have permission to delete this Banten');
    }
    
    // Delete images from storage
    List<dynamic> photos = data['photos'] ?? [];
    for (String photoUrl in photos.cast<String>()) {
      try {
        await _storage.refFromURL(photoUrl).delete();
      } catch (e) {
        print('Error deleting photo: $e');
      }
    }
    
    // Delete document
    await _firestore.collection('bantens').doc(bantenId).delete();
  }
  
  // Upload images to Firebase Storage
  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> imageUrls = [];
    
    for (var image in images) {
      final path = 'banten/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final file = File(image.path);
      
      try {
        final ref = _storage.ref().child(path);
        final uploadTask = ref.putFile(file);
        
        final snapshot = await uploadTask.whenComplete(() {});
        final url = await snapshot.ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    
    return imageUrls;
  }
  
  // Get bantens by category (guddenKeyword)
  Stream<QuerySnapshot> getBantensByCategory(String category) {
    return _firestore
        .collection('bantens')
        .where('guddenKeyword', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Add simple method for basic CRUD (for compatibility with simple UI)
  Future<DocumentReference> addBanten(String name, String description) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in');
    }
    
    return await _firestore.collection('bantens').add({
      'userId': currentUser.uid,
      'name': name,
      'namaBanten': name, 
      'description': description,
      'daerah': '',
      'sejarah': '',
      'isiBanten': '',
      'carabuatBanten': '',
      'guddenKeyword': '',
      'photos': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Update simple banten (for compatibility)
  Future<void> updateBantenSimple(String id, String name, String description) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in');
    }
    
    DocumentSnapshot doc = await _firestore.collection('bantens').doc(id).get();
    if (!doc.exists) {
      throw Exception('Banten not found');
    }
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != currentUser.uid) {
      throw Exception('Not authorized to update this banten');
    }
    
    await _firestore.collection('bantens').doc(id).update({
      'name': name,
      'namaBanten': name,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}