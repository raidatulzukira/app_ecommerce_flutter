// lib/screens/product_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

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
    // Ubah jadi async
    // Panggil API
    bool success = await apiService.addToCart(product.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan ke keranjang!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green[700], // Beri warna sukses
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
      appBar: AppBar(
        title: Text('Daftar Produk', style: TextStyle(color: Colors.white)),
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
            // --- UI BARU MENGGUNAKAN CARD ---
            return ListView.builder(
              padding: EdgeInsets.all(8.0), // Beri jarak dari tepi layar
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
                        color: Colors.grey[200],
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
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.primary, // 4. Warna dari tema
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
                            color: Theme.of(context).colorScheme.primary,
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
            // --- AKHIR UI BARU ---
          }
        },
      ),
    );
  }
}
