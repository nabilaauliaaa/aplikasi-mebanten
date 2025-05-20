// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banten_model.dart';
import '../services/banten_service.dart';
import '../services/auth_service.dart';
import 'banten_detail_screen.dart';
import 'package:apk_mebanten/tambahbanten.dart'; // Sesuaikan dengan nama file yang benar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BantenService _bantenService = BantenService();
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Banten',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // Navigate to login screen or show dialog
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Ubah dari mengharapkan Stream<List<BantenModel>> menjadi StreamBuilder<QuerySnapshot>
        stream: _bantenService.getAllBantens(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            );
          }
          
          // Cek apakah ada data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada banten yang ditambahkan',
                style: GoogleFonts.inter(fontSize: 16),
              ),
            );
          }
          
          // Konversi QuerySnapshot ke List<BantenModel>
          final List<BantenModel> bantens = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return BantenModel.fromJson(doc.id, data);
          }).toList();
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bantens.length,
            itemBuilder: (context, index) {
              final banten = bantens[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BantenDetailScreen(bantenId: banten.id!),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banten.namaBanten, // Ubah dari name ke namaBanten
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banten.deskripsi, // Ubah dari description ke deskripsi
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dibuat oleh: ${banten.userName}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3FAE82),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahBantenPage()), // Ubah nama class sesuai dengan class yang benar
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}