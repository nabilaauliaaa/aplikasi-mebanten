import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/banten_service.dart';
import '../models/banten_model.dart';
import '../services/auth_service.dart';
import 'edit_banten_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    _loadBanten();
    _checkIfBookmarked();
  }
  
  void _loadBanten() {
    _bantenFuture = _fetchBantenModel();
  }

  // Tambahkan variabel state di dalam class _DetailBantenPageState
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isBookmarked = false;
  bool _isCheckingBookmark = true;
  bool _isBookmarkLoading = false;
  
  User? get currentUser => _auth.currentUser;

  // Fungsi untuk mengecek apakah banten sudah di-bookmark
  Future<void> _checkIfBookmarked() async {
    if (currentUser == null || widget.bantenId == false) {
      setState(() {
        _isCheckingBookmark = false;
      });
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (userDoc.exists && userDoc.data()?['bookmarks'] != null) {
        List<String> bookmarks = List<String>.from(userDoc.data()!['bookmarks']);
        setState(() {
          _isBookmarked = bookmarks.contains(widget.bantenId);
          _isCheckingBookmark = false;
        });
      } else {
        setState(() {
          _isBookmarked = false;
          _isCheckingBookmark = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCheckingBookmark = false;
      });
      print('Error checking bookmark status: $e');
    }
  }

  // Fungsi untuk toggle bookmark
  Future<void> _toggleBookmark() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.bantenId == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID banten tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBookmarkLoading = true;
    });

    try {
      if (_isBookmarked) {
        // Remove bookmark
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'bookmarks': FieldValue.arrayRemove([widget.bantenId])
        });
        
        setState(() {
          _isBookmarked = false;
          _isBookmarkLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari favorit'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Add bookmark
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'bookmarks': FieldValue.arrayUnion([widget.bantenId])
        }, SetOptions(merge: true));
        
        setState(() {
          _isBookmarked = true;
          _isBookmarkLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke favorit'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isBookmarkLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

   // Widget untuk bookmark button
  Widget _buildBookmarkButton() {
    if (_isCheckingBookmark) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _isBookmarkLoading ? null : _toggleBookmark,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isBookmarkLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              )
            : Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? const Color(0xFF4CAF50) : Colors.grey[600],
                size: 24,
              ),
      ),
    );
  }

  // Widget untuk bookmark button alternatif (untuk di AppBar)
  Widget _buildAppBarBookmarkButton() {
    if (_isCheckingBookmark) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _isBookmarkLoading ? null : _toggleBookmark,
      icon: _isBookmarkLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
    );
  }
  
  // Fetch dan convert data dari Firebase
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
  
  // Helper method untuk format tanggal
  String _formatDate(DateTime dateTime) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Banten',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<BantenModel?>(
        future: _bantenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.inter(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Banten tidak ditemukan',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          final banten = snapshot.data!;
          final isOwner = banten.userId == _authService.currentUser?.uid;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ADDED: Tampilkan gambar jika ada
                if (banten.photos.isNotEmpty)
                  Container(
                    height: 250,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        banten.photos.first,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, 
                                       size: 50, 
                                       color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Gambar tidak dapat dimuat'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                
                // Header: Judul dan tanggal
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                                                  banten.namaBanten, // FIXED: Konsisten dengan Firebase 'name' field
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        _formatDate(banten.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // ADDED: Info pembuat dan daerah
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Dibuat oleh: ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              banten.userName?.isNotEmpty == true ? banten.userName! : 'Tidak diketahui',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (banten.daerah.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Daerah: ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                banten.daerah,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Deskripsi
                _buildSection(
                  title: 'Deskripsi',
                                      content: banten.description, // FIXED: Konsisten dengan Firebase 'description' field
                  icon: Icons.description,
                ),
                const SizedBox(height: 20),
                
                // ADDED: Sejarah section (field terpisah)
                if (banten.sejarah.isNotEmpty) ...[
                  _buildSection(
                    title: 'Sejarah',
                    content: banten.sejarah,
                    icon: Icons.history_edu,
                  ),
                  const SizedBox(height: 20),
                ],
                
                // ADDED: Sumber Referensi (guddenKeyword)
                if (banten.guddenKeyword.isNotEmpty) ...[
                  _buildSection(
                    title: 'Sumber Referensi',
                    content: banten.guddenKeyword,
                    icon: Icons.source,
                  ),
                  const SizedBox(height: 32),
                ],
                
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
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showDeleteConfirmation,
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Bookmark button
            GestureDetector(
              onTap: _isBookmarkLoading ? null : _toggleBookmark,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isBookmarked ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isBookmarked ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isBookmarkLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF4CAF50),
                        ),
                      )
                    else
                      Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? const Color(0xFF4CAF50) : Colors.grey[600],
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _isBookmarked ? 'Tersimpan' : 'Simpan',
                      style: GoogleFonts.inter(
                        color: _isBookmarked ? const Color(0xFF4CAF50) : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
  
  // Helper widget untuk section content
  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}