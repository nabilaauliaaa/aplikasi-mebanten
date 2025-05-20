// lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;
  
  FirebaseService._internal();
  
  // Firebase Auth instance
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Firebase Storage instance
  final FirebaseStorage storage = FirebaseStorage.instance;
  
  // Inisialisasi Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Current user
  User? get currentUser => auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => auth.authStateChanges();
  
  // Mendapatkan referensi collection users
  CollectionReference<Map<String, dynamic>> get usersCollection => 
      firestore.collection('users');
  
  // Mendapatkan referensi collection bantens
  CollectionReference<Map<String, dynamic>> get bantensCollection => 
      firestore.collection('bantens');
  
  // Mendapatkan referensi storage
  Reference getStorageRef(String path) => storage.ref().child(path);
}