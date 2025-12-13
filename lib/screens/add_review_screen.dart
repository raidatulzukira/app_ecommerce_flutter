import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';

class AddReviewScreen extends StatefulWidget {
  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();

  // State untuk Dropdown
  Product? _selectedProduct;
  int _selectedRating = 5;
  List<Product> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProductIdsFromReviews();
  }

  // --- LOGIKA: AMBIL ID DARI API REVIEW (Tanpa Nama Produk) ---
  void _loadProductIdsFromReviews() async {
    try {
      // 1. Panggil API get_reviews (Port 5002)
      List<Review> reviews = await apiService.fetchReviews();

      // 2. Ambil semua product_id yang unik dari data tersebut
      // (Menggunakan Set agar ID 101 tidak muncul dua kali jika ada banyak review di ID itu)
      Set<int> uniqueIds = reviews.map((r) => r.productId).toSet();

      // 3. Ubah menjadi list Product untuk dropdown
      // Kita gunakan model Product hanya sebagai wadah ID dan Label
      List<Product> extractedProducts =
          uniqueIds.map((id) {
            return Product(
              id: id,
              // HANYA MENAMPILKAN ID, TIDAK ADA NAMA PRODUK
              name: "Product ID: $id",
              price: 0,
              description: "",
            );
          }).toList();

      // 4. Urutkan berdasarkan ID (101, 102, 103...)
      extractedProducts.sort((a, b) => a.id.compareTo(b.id));

      setState(() {
        _products = extractedProducts;
        _isLoadingProducts = false;
        // Set default ke item pertama jika ada
        if (extractedProducts.isNotEmpty)
          _selectedProduct = extractedProducts[0];
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoadingProducts = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat ID produk')));
    }
  }
  // -----------------------------------------------------------

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProduct == null) return;

      Review newReview = Review(
        id: 0,
        productId: _selectedProduct!.id, // Ini akan mengirim 101/102/dst
        review: _reviewController.text,
        rating: _selectedRating,
      );

      bool success = await apiService.createReview(newReview);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ulasan berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim ulasan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tulis Ulasan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 60,
        titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
      ),
      body:
          _isLoadingProducts
              ? Center(child: CircularProgressIndicator(color: Colors.teal))
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Dropdown Produk
                      Text(
                        "Pilih ID Produk",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Product>(
                            value: _selectedProduct,
                            isExpanded: true,
                            hint: Text("Pilih ID Produk"),
                            items:
                                _products.map((Product product) {
                                  return DropdownMenuItem<Product>(
                                    value: product,
                                    child: Text(
                                      product
                                          .name, // Ini akan tampil: "Product ID: 101"
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (Product? newValue) {
                              setState(() {
                                _selectedProduct = newValue;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // 2. Input Rating (Model Bintang Interaktif)
                      Text(
                        "Beri Rating",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            int starValue = index + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRating = starValue;
                                });
                              },
                              child: Icon(
                                starValue <= _selectedRating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: Colors.amber,
                                size: 40,
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: 20),

                      // 3. Input Ulasan
                      Text(
                        "Ulasan Anda",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _reviewController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Tulis pengalaman Anda...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ulasan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 30),

                      // 4. Tombol Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Kirim Ulasan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
