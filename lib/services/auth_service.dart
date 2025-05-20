// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseService.instance.auth;
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update lastLoginAt timestamp
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return userCredential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }
  
  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email, 
    String password, 
    String name,
  ) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Generate username
      final username = '@${name.toLowerCase().replaceAll(' ', '')}${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'username': username,
        'photoURL': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update display name in Auth
      await userCredential.user!.updateDisplayName(name);
      
      return userCredential;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      // Add updatedAt timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(userId).update(data);
      
      // Update Auth profile if needed
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        if (data.containsKey('name')) {
          await currentUser.updateDisplayName(data['name']);
        }
        if (data.containsKey('photoURL')) {
          await currentUser.updatePhotoURL(data['photoURL']);
        }
      }
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }
}