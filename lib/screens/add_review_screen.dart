import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/review_model.dart';
import '../../models/product_model.dart'; // Import Product Model
import '../../services/api_service.dart';

class AddReviewScreen extends StatefulWidget {
  final Review? review;
  const AddReviewScreen({super.key, this.review});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentCtrl = TextEditingController();
  
  // Variabel untuk Dropdown Product
  List<Product> _products = [];
  int? _selectedProductId; 
  bool _isLoadingProducts = true;

  int _rating = 5;
  bool _isSaving = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Ambil data produk saat buka halaman
    
    if (widget.review != null) {
      _selectedProductId = widget.review!.productId;
      _commentCtrl.text = widget.review!.comment;
      _rating = widget.review!.rating;
    }
  }

  // Fungsi ambil produk untuk dropdown
  void _loadProducts() async {
    try {
      final products = await _apiService.fetchProducts();
      setState(() {
        _products = products;
        _isLoadingProducts = false;
        
        // Pastikan product ID yang diedit masih ada di list, kalau tidak null-kan
        if (widget.review != null) {
          bool exists = _products.any((p) => p.id == widget.review!.productId);
          if (!exists) _selectedProductId = null;
        }
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      print("Error loading products: $e");
    }
  }

  void _saveReview() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih Produk dulu"), backgroundColor: Colors.red));
        return;
      }

      setState(() => _isSaving = true);
      
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? 1;

      bool success;
      if (widget.review == null) {
        // Create
        final newReview = Review(
          id: '', 
          productId: _selectedProductId!, // Ambil dari Dropdown
          userId: userId,
          rating: _rating,
          comment: _commentCtrl.text,
        );
        success = await _apiService.createReview(newReview);
      } else {
        // Update
        success = await _apiService.updateReview(
          widget.review!.id,           // ID Review
          widget.review!.productId,    // Product ID (Jangan diubah)
          widget.review!.userId,       // User ID (Jangan diubah/Pakai yg lama)
          _rating,                     // Rating Baru
          _commentCtrl.text            // Komentar Baru
        );
      }

      setState(() => _isSaving = false);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan!"), backgroundColor: Color.fromARGB(255, 237, 118, 140)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan"), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.review != null;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Review" : "Tambah Review", style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 239, 122, 143),
        foregroundColor: const Color(0xFF5D4037),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- DROPDOWN PRODUCT ---
              const Text("Pilih Produk:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _isLoadingProducts 
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400)
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedProductId,
                        hint: const Text("Pilih Produk yang diulas"),
                        isExpanded: true,
                        items: _products.map((Product product) {
                          return DropdownMenuItem<int>(
                            value: product.id,
                            child: Text("${product.name} (ID: ${product.id})"),
                          );
                        }).toList(),
                        onChanged: isEdit ? null : (newValue) { // Disable dropdown jika mode Edit
                          setState(() {
                            _selectedProductId = newValue;
                          });
                        },
                      ),
                    ),
                  ),
              if (isEdit) 
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text("* Produk tidak bisa diubah saat edit", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              
              const SizedBox(height: 20),
              
              // --- RATING INPUT ---
              const Text("Rating:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() => _rating = index + 1);
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // --- COMMENT INPUT ---
              TextFormField(
                controller: _commentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Komentar / Ulasan", 
                  prefixIcon: Icon(Icons.comment_outlined), 
                  alignLabelWithHint: true
                ),
                validator: (v) => v!.isEmpty ? "Komentar wajib diisi" : null,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveReview,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 233, 108, 131)),
                  child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("SIMPAN ULASAN", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}