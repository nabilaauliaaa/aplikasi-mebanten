// lib/models/banten_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BantenModel {
  String? id;
  final String namaBanten;
  final String name; // For compatibility
  final String description;
  final String daerah;
  final String sejarah;
  final String isiBanten;
  final String carabuatBanten;
  final String guddenKeyword;
  final List<String> photos;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userEmail;
  final String? username;
  
  BantenModel({
    this.id,
    required this.namaBanten,
    required this.description,
    required this.userId,
    required this.createdAt,
    this.daerah = '',
    this.sejarah = '',
    this.isiBanten = '',
    this.carabuatBanten = '',
    this.guddenKeyword = '',
    this.photos = const [],
    DateTime? updatedAt,
    this.userName,
    this.userEmail,
    this.username,
  }) : name = namaBanten, // Set name same as namaBanten for compatibility
       updatedAt = updatedAt ?? createdAt;
  
  Map<String, dynamic> toJson() {
    return {
      'namaBanten': namaBanten,
      'name': namaBanten, // For compatibility
      'description': description,
      'daerah': daerah,
      'sejarah': sejarah,
      'isiBanten': isiBanten,
      'carabuatBanten': carabuatBanten,
      'guddenKeyword': guddenKeyword,
      'photos': photos,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userName': userName,
      'userEmail': userEmail,
      'username': username,
    };
  }
  
  // Factory constructor from Firestore document
  factory BantenModel.fromFirestore(String id, Map<String, dynamic> data) {
    return BantenModel(
      id: id,
      namaBanten: data['namaBanten'] ?? data['name'] ?? '', // Support both fields
      description: data['description'] ?? '',
      daerah: data['daerah'] ?? '',
      sejarah: data['sejarah'] ?? '',
      isiBanten: data['isiBanten'] ?? '',
      carabuatBanten: data['carabuatBanten'] ?? '',
      guddenKeyword: data['guddenKeyword'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      userName: data['userName'],
      userEmail: data['userEmail'],
      username: data['username'],
    );
  }
  
  // Legacy factory constructor for backward compatibility
  factory BantenModel.fromJson(String id, Map<String, dynamic> json) {
    return BantenModel.fromFirestore(id, json);
  }
  
  // Copy with method for updating
  BantenModel copyWith({
    String? id,
    String? namaBanten,
    String? description,
    String? daerah,
    String? sejarah,
    String? isiBanten,
    String? carabuatBanten,
    String? guddenKeyword,
    List<String>? photos,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userEmail,
    String? username,
  }) {
    return BantenModel(
      id: id ?? this.id,
      namaBanten: namaBanten ?? this.namaBanten,
      description: description ?? this.description,
      daerah: daerah ?? this.daerah,
      sejarah: sejarah ?? this.sejarah,
      isiBanten: isiBanten ?? this.isiBanten,
      carabuatBanten: carabuatBanten ?? this.carabuatBanten,
      guddenKeyword: guddenKeyword ?? this.guddenKeyword,
      photos: photos ?? this.photos,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      username: username ?? this.username,
    );
  }
}