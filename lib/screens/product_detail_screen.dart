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

  // --- FUNGSI BARU UNTUK TOMBOL KERANJANG ---
  void _addToCart(Product product) {
    print('Menambahkan ${product.name} ke keranjang');
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating, // Biar lebih bagus
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Produk')),
      body: FutureBuilder<Product>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Product product = snapshot.data!;

            // --- UI BARU HALAMAN DETAIL ---
            return SingleChildScrollView(
              // 1. Agar bisa di-scroll
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Placeholder Gambar Besar
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.shopping_bag, // Icon placeholder
                      size: 100,
                      color: Colors.grey[600],
                    ),
                  ),

                  // 3. Konten Teks (Nama, Harga, Deskripsi)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Produk
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        // Harga (Berwarna)
                        Text(
                          '\$${product.price}',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Judul Deskripsi
                        Text(
                          'Deskripsi Produk',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        // Isi Deskripsi
                        Text(
                          product.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 15),
                        ),
                        SizedBox(height: 32), // Spasi sebelum tombol
                        // 4. Tombol "Tambah ke Keranjang"
                        SizedBox(
                          width: double.infinity, // Tombol penuh
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.add_shopping_cart_outlined),
                            label: Text('Tambah ke Keranjang'),
                            onPressed: () => _addToCart(product),
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            // --- AKHIR UI BARU ---
          } else {
            return Center(child: Text('Produk tidak ditemukan.'));
          }
        },
      ),
    );
  }
}
