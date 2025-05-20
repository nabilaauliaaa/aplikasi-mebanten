// lib/models/banten_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BantenModel {
  String? id;
  final String namaBanten;
  final String deskripsi;
  final String sarana;
  final String guddenKeyword;
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
    required this.deskripsi,
    required this.sarana,
    this.guddenKeyword = '',
    required this.photos,
    required this.userId,
    required this.userName,
    this.username,
    this.userEmail,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'namaBanten': namaBanten,
      'deskripsi': deskripsi,
      'sarana': sarana,
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
  
  factory BantenModel.fromJson(String id, Map<String, dynamic> json) {
    // Handle Timestamp or String dates
    DateTime getDateTime(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }
    
    // Handle photos array
    List<String> getPhotos(dynamic photos) {
      if (photos is List) {
        return photos.map((e) => e.toString()).toList();
      }
      return [];
    }
    
    return BantenModel(
      id: id,
      namaBanten: json['namaBanten'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      sarana: json['sarana'] ?? '',
      guddenKeyword: json['guddenKeyword'] ?? '',
      photos: getPhotos(json['photos']),
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      username: json['username'],
      userEmail: json['userEmail'],
      createdAt: json['createdAt'] != null 
          ? getDateTime(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? getDateTime(json['updatedAt'])
          : DateTime.now(),
    );
  }
}