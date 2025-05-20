// lib/screens/banten_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan import ini
import '../services/banten_service.dart';
import '../models/banten_model.dart';
import '../services/auth_service.dart';
import 'edit_banten_screen.dart';

class BantenDetailScreen extends StatefulWidget {
  final String bantenId;
  
  const BantenDetailScreen({super.key, required this.bantenId});

  @override
  State<BantenDetailScreen> createState() => _BantenDetailScreenState();
}

class _BantenDetailScreenState extends State<BantenDetailScreen> {
  final BantenService _bantenService = BantenService();
  final AuthService _authService = AuthService();
  late Future<BantenModel?> _bantenFuture;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadBanten();
  }
  
  void _loadBanten() {
    // Ubah ini untuk mengonversi DocumentSnapshot ke BantenModel dengan benar
    _bantenFuture = _fetchBantenModel();
  }
  
  // Tambahkan metode baru untuk mengambil dan mengonversi data
  Future<BantenModel?> _fetchBantenModel() async {
    try {
      final doc = await _bantenService.getBantenById(widget.bantenId);
      if (!doc.exists) {
        return null;
      }
      
      // Konversi DocumentSnapshot ke BantenModel
      final data = doc.data() as Map<String, dynamic>;
      return BantenModel.fromJson(doc.id, data);
    } catch (e) {
      print('Error fetching banten: $e');
      rethrow;
    }
  }
  
  Future<void> _deleteBanten() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _bantenService.deleteBanten(widget.bantenId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banten berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Banten'),
        content: const Text('Apakah Anda yakin ingin menghapus banten ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBanten();
            },
            child: const Text(
              'Hapus', 
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Banten'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<BantenModel?>(
        future: _bantenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
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
          
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Banten tidak ditemukan'),
            );
          }
          
          final banten = snapshot.data!;
          final isOwner = banten.userId == _authService.currentUser?.uid;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul dan tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        banten.namaBanten, // Ubah dari banten.name ke banten.namaBanten
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${banten.createdAt.day}/${banten.createdAt.month}/${banten.createdAt.year}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Deskripsi
                Text(
                  'Deskripsi',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    banten.deskripsi, // Ubah dari banten.description ke banten.deskripsi
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Tombol edit dan hapus (hanya untuk pemilik)
                if (isOwner) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditBantenScreen(banten: banten),
                              ),
                            ).then((_) => _loadBanten());
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showDeleteConfirmation,
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}