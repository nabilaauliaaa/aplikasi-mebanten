// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String username;
  String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserModel({
    required this.uid, 
    required this.name, 
    required this.email,
    required this.username,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle Timestamp or String dates
    DateTime getDateTime(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }
    
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      photoURL: json['photoURL'],
      createdAt: json['createdAt'] != null 
          ? getDateTime(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? getDateTime(json['updatedAt'])
          : DateTime.now(),
    );
  }
}