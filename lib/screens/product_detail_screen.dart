// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Product> futureProduct;

  @override
  void initState() {
    super.initState();
    futureProduct = apiService.fetchProductDetail(widget.productId);
  }

  // --- FUNGSI ADD TO CART (Sudah disesuaikan) ---
  void _addToCart(Product product) async {
    // Kirim object 'product' utuh (bukan ID saja)
    bool success = await apiService.addToCart(product);

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('${product.name} berhasil ditambahkan!')),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan produk.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50], // Background header soft teal
      appBar: AppBar(
        title: Text('Detail Produk', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0, // Hilangkan shadow agar menyatu dengan background
        toolbarHeight: 60,
        titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Product>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Product product = snapshot.data!;

            return Column(
              children: [
                // --- 1. AREA GAMBAR PRODUK (Header) ---
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(30),
                        // HAPUS LOGIKA GAMBAR, GANTI ICON SAJA
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 150,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                ),

                // --- 2. AREA KONTEN (White Sheet) ---
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Garis kecil (Handle)
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Baris Nama & Harga
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              '\$${product.price}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Judul Deskripsi
                        Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Isi Deskripsi (Scrollable)
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              product.description.isNotEmpty 
                                  ? product.description 
                                  : 'Tidak ada deskripsi tersedia.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),

                        // --- 3. TOMBOL AKSI FIXED DI BAWAH ---
                        SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: double.infinity, // Agar tombol selebar container
                            height: 55,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                              label: Text(
                                'Tambah ke Keranjang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _addToCart(product),
                            ),
                          ),
                        ),
                        // SizedBox bawah dihapus agar tombol pas di bawah
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('Produk tidak ditemukan.'));
          }
        },
      ),
    );
  }
}