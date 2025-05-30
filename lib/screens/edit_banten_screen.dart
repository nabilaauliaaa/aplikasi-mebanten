// lib/screens/edit_banten_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/banten_model.dart';
import '../services/banten_service.dart';

class EditBantenScreen extends StatefulWidget {
  final BantenModel banten;
  
  const EditBantenScreen({super.key, required this.banten});

  @override
  State<EditBantenScreen> createState() => _EditBantenScreenState();
}

class _EditBantenScreenState extends State<EditBantenScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bantenNameController;
  late TextEditingController _bantenDescController;
  late TextEditingController _sejarahController; 
  late TextEditingController _daerahController;
  late TextEditingController _carabuatBantenController; 
  late TextEditingController _isiBantenController;
  late TextEditingController _guddenKeywordController;
  bool _isLoading = false;
  final BantenService _bantenService = BantenService();
  
  @override
  void initState() {
    super.initState();
    
    _bantenNameController = TextEditingController(text: widget.banten.namaBanten);
    _bantenDescController = TextEditingController(text: widget.banten.description);
    _sejarahController = TextEditingController(text: widget.banten.sejarah);
    _daerahController = TextEditingController(text: widget.banten.daerah);
    _carabuatBantenController = TextEditingController(text: widget.banten.carabuatBanten);
    _isiBantenController = TextEditingController(text: widget.banten.isiBanten);
    _guddenKeywordController = TextEditingController(text: widget.banten.guddenKeyword);
  }
  
  @override
  void dispose() {
    _bantenNameController.dispose();
    _bantenDescController.dispose();
    _sejarahController.dispose();
    _daerahController.dispose();
    _isiBantenController.dispose();
    _carabuatBantenController.dispose();
    _guddenKeywordController.dispose();
    super.dispose();
  }
  
  Future<void> _updateBanten() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Perbaiki cara memanggil updateBanten untuk disesuaikan dengan metode di BantenService
      await _bantenService.updateBanten(
        bantenId: widget.banten.id!,
        namaBanten: _bantenNameController.text.trim(),
        description: _bantenDescController.text.trim(),
        sejarah: _sejarahController.text.trim(),
        daerah: _daerahController.text.trim(),
        isiBanten: _isiBantenController.text.trim(),
        carabuatBanten: _carabuatBantenController.text.trim(),
        guddenKeyword: _guddenKeywordController.text.trim(),
        existingImageUrls: widget.banten.photos, // Gunakan photos yang sudah ada
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banten berhasil diperbarui!'),
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Banten'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Detail Banten',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Nama Banten field
                TextFormField(
                  controller: _bantenNameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Banten',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Banten tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // description field
                TextFormField(
                  controller: _bantenDescController,
                  decoration: InputDecoration(
                    labelText: 'description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'description tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sejarah field
                TextFormField(
                  controller: _sejarahController,
                  decoration: InputDecoration(
                    labelText: 'Sejarah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sejarah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),


                // Daerah field
                TextFormField(
                  controller: _daerahController,
                  decoration: InputDecoration(
                    labelText: 'Daerah yang menggunakan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Daerah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                //isi Banten field
                TextFormField(
                  controller: _isiBantenController,
                  decoration: InputDecoration(
                    labelText: 'Isi Banten',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi Banten tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),


                // Cara Buat Banten field
                TextFormField(
                  controller: _carabuatBantenController,
                  decoration: InputDecoration(
                    labelText: 'Cara Buat Banten',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cara Buat Banten tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),


                // Sumber Referensi field
                TextFormField(
                  controller: _guddenKeywordController,
                  decoration: InputDecoration(
                    labelText: 'Sumber Referensi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateBanten,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FAE82),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}