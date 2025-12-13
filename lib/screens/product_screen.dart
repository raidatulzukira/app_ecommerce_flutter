// lib/screens/product_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'user_screen.dart';
import 'cart_screen.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = apiService.fetchProducts();
  }

  void _goToDetail(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  // void _addToCart(Product product) {
  //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('${product.name} ditambahkan ke keranjang!'),
  //       duration: Duration(seconds: 1),
  //       backgroundColor: Colors.green[700], // Beri warna sukses
  //     ),
  //   );
  // }

  void _addToCart(Product product) async {
    // 1. PERBAIKAN UTAMA: Kirim object 'product', bukan 'product.id'
    bool success = await apiService.addToCart(product);

    // 2. PERBAIKAN TAMBAHAN: Cek mounted agar aman dari error "Async Gap"
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
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('Daftar Produk', style: TextStyle(color: Colors.white)),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              // Ganti Icon User jadi Shopping Cart
              icon: Icon(Icons.shopping_cart, size: 28, color: Colors.white),
              tooltip: 'Keranjang Belanja',
              onPressed: () {
                // Navigasi ke CartScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
          ),
        ],

        backgroundColor: Colors.teal,
        toolbarHeight: 60,
        titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada produk.',
                style: TextStyle(color: Colors.teal),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(15.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Product product = snapshot.data![index];

                return Card(
                  // 1. Bungkus dengan Card agar terstruktur
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    // 2. Placeholder gambar
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.teal,
                        size: 30,
                      ),
                    ),

                    // 3. Styling Teks
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '\$${product.price}', // Harga
                      style: TextStyle(
                        color: Colors.teal,
                        // color:
                        //     Theme.of(
                        //       context,
                        //     ).colorScheme.primary, // 4. Warna dari tema
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    // 5. Tombol-tombol di akhir
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.density_small_outlined,
                            color: Colors.blue[300],
                            // color: Theme.of(context).colorScheme.secondary,
                          ),
                          tooltip: 'Lihat Detail',
                          onPressed: () => _goToDetail(product.id),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart,
                            color: Colors.teal,
                          ),
                          tooltip: 'Tambah ke Keranjang',
                          onPressed: () => _addToCart(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
