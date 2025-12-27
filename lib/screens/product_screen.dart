// lib/screens/product_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart'; // Pastikan ini di-import
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
    _refreshProducts();
  }

  // --- FUNGSI BARU: Refresh List ---
  void _refreshProducts() {
    setState(() {
      futureProducts = apiService.fetchProducts();
    });
  }

  // --- FUNGSI LAMA: Navigasi Detail ---
  void _goToDetail(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  // --- FUNGSI BARU: Navigasi ke Form (Tambah/Edit) ---
  void _navigateToForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );
    // Jika kembali membawa data true (sukses), refresh list
    if (result == true) {
      _refreshProducts();
    }
  }

  // --- FUNGSI BARU: Hapus Produk ---
  void _deleteProduct(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await apiService.deleteProduct(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produk dihapus'), backgroundColor: Colors.green));
        _refreshProducts(); // Refresh setelah hapus
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menghapus produk')));
      }
    }
  }

  // --- FUNGSI LAMA: Add to Cart (Tetap Dipertahankan) ---
  void _addToCart(Product product) async {
    // Kirim object 'product' sesuai perbaikan sebelumnya
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
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('Daftar Produk', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.shopping_cart, size: 28, color: Colors.white),
              tooltip: 'Keranjang Belanja',
              onPressed: () {
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
                style: TextStyle(color: Colors.teal, fontSize: 18),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(15.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Product product = snapshot.data![index];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    // Navigasi Detail pindah ke onTap Card agar lebih UX friendly
                    onTap: () => _goToDetail(product.id),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      
                      // 1. UPDATE: Menampilkan Gambar dari URL
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Hapus logika Image.network, ganti Icon saja
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.teal,
                          size: 30,
                        ),
                      ),

                      // Styling Teks Tetap Sama
                      title: Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '\$${product.price}',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),

                      // 2. UPDATE: Menambah Tombol Edit & Hapus di samping Cart
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Edit
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit',
                            onPressed: () => _navigateToForm(product: product),
                          ),
                          // Tombol Hapus
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Hapus',
                            onPressed: () => _deleteProduct(product.id),
                          ),
                          // Tombol Cart (LAMA)
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
                  ),
                );
              },
            );
          }
        },
      ),

      // 3. UPDATE: Tombol Tambah Produk (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(), // Panggil form mode tambah
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Produk Baru',
      ),
    );
  }
}