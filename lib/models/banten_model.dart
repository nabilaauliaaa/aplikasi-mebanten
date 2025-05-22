// lib/models/banten_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BantenModel {
  String? id;
  final String namaBanten;
  final String description;
  final String sejarah;        // ADDED: Field sejarah terpisah dari description
  final String daerah;         // Field untuk daerah yang menggunakan
  final String guddenKeyword;  // Field untuk sumber referensi
  final List<String> photos;
  final String userId;
  final String userName;
  final String? username;
  final String? userEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BantenModel({
    this.id,
    required this.namaBanten,
    required this.description,
    required this.sejarah,      // ADDED: Required sejarah field
    required this.daerah,
    this.guddenKeyword = '',
    required this.photos,
    required this.userId,
    required this.userName,
    this.username,
    this.userEmail,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'namaBanten': namaBanten,
      'description': description,
      'sejarah': sejarah,          // ADDED: Include sejarah field
      'daerah': daerah,
      'guddenKeyword': guddenKeyword,
      'photos': photos,
      'userId': userId,
      'userName': userName,
      'username': username,
      'userEmail': userEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  // Create model from Firestore JSON
  factory BantenModel.fromJson(String id, Map<String, dynamic> json) {
    // Helper function to handle Timestamp or String dates
    DateTime getDateTime(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        try {
          return DateTime.parse(timestamp);
        } catch (e) {
          print('Error parsing date string: $e');
          return DateTime.now();
        }
      } else if (timestamp == null) {
        return DateTime.now();
      }
      return DateTime.now();
    }
    
    // Helper function to handle photos array
    List<String> getPhotos(dynamic photos) {
      if (photos is List) {
        return photos.map((e) => e.toString()).where((photo) => photo.isNotEmpty).toList();
      }
      return [];
    }
    
    // Helper function to get string value safely
    String getStringValue(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      return value.toString().trim();
    }
    
    return BantenModel(
      id: id,
      // FIXED: Konsisten dengan field Firebase dan TambahBanten
      namaBanten: getStringValue(json['namaBanten']),
      description: getStringValue(json['description']),
      sejarah: getStringValue(json['sejarah']),        // ADDED: Parse sejarah field
      daerah: getStringValue(json['daerah']),
      guddenKeyword: getStringValue(json['guddenKeyword']),
      photos: getPhotos(json['photos']),
      userId: getStringValue(json['userId']),
      userName: getStringValue(json['userName'], defaultValue: 'Anonymous'),
      username: json['username'],
      userEmail: json['userEmail'],
      createdAt: getDateTime(json['createdAt']),
      updatedAt: getDateTime(json['updatedAt']),
    );
  }
  
  // ADDED: Copy method untuk editing functionality
  BantenModel copyWith({
    String? id,
    String? namaBanten,
    String? description,
    String? sejarah,
    String? daerah,
    String? guddenKeyword,
    List<String>? photos,
    String? userId,
    String? userName,
    String? username,
    String? userEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BantenModel(
      id: id ?? this.id,
      namaBanten: namaBanten ?? this.namaBanten,
      description: description ?? this.description,
      sejarah: sejarah ?? this.sejarah,
      daerah: daerah ?? this.daerah,
      guddenKeyword: guddenKeyword ?? this.guddenKeyword,
      photos: photos ?? this.photos,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      username: username ?? this.username,
      userEmail: userEmail ?? this.userEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // ADDED: toString method untuk debugging
  @override
  String toString() {
    return 'BantenModel{id: $id, namaBanten: $namaBanten, description: $description, sejarah: $sejarah, daerah: $daerah, guddenKeyword: $guddenKeyword, photos: $photos, userId: $userId, userName: $userName, createdAt: $createdAt}';
  }
  
  // ADDED: Equality operators untuk comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is BantenModel &&
        other.id == id &&
        other.namaBanten == namaBanten &&
        other.description == description &&
        other.sejarah == sejarah &&
        other.daerah == daerah &&
        other.guddenKeyword == guddenKeyword &&
        other.userId == userId;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        namaBanten.hashCode ^
        description.hashCode ^
        sejarah.hashCode ^
        daerah.hashCode ^
        guddenKeyword.hashCode ^
        userId.hashCode;
  }
  
  // ADDED: Validation methods
  bool get isValid {
    return namaBanten.isNotEmpty && 
           description.isNotEmpty && 
           userId.isNotEmpty && 
           userName.isNotEmpty;
  }
  
  bool get hasPhoto {
    return photos.isNotEmpty;
  }
  
  bool get hasSejarah {
    return sejarah.isNotEmpty;
  }
  
  bool get hasSumberReferensi {
    return guddenKeyword.isNotEmpty;
  }
}