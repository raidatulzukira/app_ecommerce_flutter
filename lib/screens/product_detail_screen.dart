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

  // --- FUNGSI TAMBAH KE KERANJANG (LOGIC LAMA TETAP ADA) ---
  void _addToCart(Product product) async {
    // Panggil API (Jika Anda sudah update ApiService ke database, ini akan jalan)
    // Jika masih simulasi, ini juga tetap jalan.
    bool success = await apiService.addToCart(product.id);

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
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50], // Background soft matching theme
      appBar: AppBar(
        title: Text('Detail Produk', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        toolbarHeight: 60,
        titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
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
                  flex: 2, // Mengambil porsi atas layar
                  child: Center(
                    child: Hero(
                      tag: 'product_${product.id}', // Animasi transisi jika ada
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 150,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),

                // --- 2. AREA KONTEN (White Sheet) ---
                Expanded(
                  flex: 3, // Mengambil porsi lebih besar di bawah
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
                        // Garis kecil di tengah atas sheet (hiasan UI modern)
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

                        // Isi Deskripsi (Scrollable jika panjang)
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              product.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                                height:
                                    1.6, // Jarak antar baris agar mudah dibaca
                              ),
                            ),
                          ),
                        ),

                        // SizedBox(height: 20),

                        // --- 3. TOMBOL AKSI FIXED DI BAWAH ---
                        // --- TAMBAHKAN WIDGET CENTER DI SINI ---
                        Center(
                          child: SizedBox(
                            width: 235, // Lebar tombol
                            height: 53,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
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

                        SizedBox(height: 130),
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
