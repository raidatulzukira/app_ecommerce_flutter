import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'product_form_screen.dart'; // Untuk Tambah/Edit Produk
import 'product_detail_screen.dart'; // Untuk Lihat Detail Produk

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  // Fungsi refresh untuk mengambil data terbaru dari server
  void _refreshProducts() {
    setState(() {
      _productsFuture = _apiService.fetchProducts();
    });
  }

  // Fungsi Hapus Produk dengan Konfirmasi
  void _deleteProduct(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: const Text("Tindakan ini tidak bisa dibatalkan."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm) {
      bool success = await _apiService.deleteProduct(id);
      if (success) {
        _refreshProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil dihapus"), backgroundColor: Color.fromARGB(255, 231, 119, 139))
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menghapus produk"), backgroundColor: Colors.red)
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Background Pink Muda (Lavender Blush)
      
      appBar: AppBar(
        title: const Text("Manage Products", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 246, 125, 147),
        foregroundColor: const Color(0xFF5D4037), // Coklat Tua Elegant
        elevation: 0,
        centerTitle: true,
      ),
      
      // Tombol Tambah Produk (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 233, 108, 131), // Pink Cerah
        elevation: 5,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          // Navigasi ke Form Tambah
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen()));
          _refreshProducts(); // Refresh setelah kembali
        },
      ),
      
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5C8D)));
          }
          
          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.red[300]),
                  const SizedBox(height: 10),
                  Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _refreshProducts, child: const Text("Coba Lagi"))
                ],
              ),
            );
          }
          
          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Belum ada produk.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          // 4. Data List State (GridView)
          return RefreshIndicator(
            onRefresh: () async => _refreshProducts(),
            color: const Color(0xFFFF5C8D),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 Kolom
                childAspectRatio: 0.70, // Rasio Tinggi:Lebar kartu
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                
                // CARD ITEM
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8FA3).withOpacity(0.15), 
                        blurRadius: 10, 
                        offset: const Offset(0, 5)
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // --- NAVIGASI KE DETAIL PRODUK ---
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- GAMBAR PRODUK (Placeholder Hero) ---
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFCE4EC), // Pink sangat muda
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Center(
                                child: Hero(
                                  tag: 'product-${product.id}',
                                  child: Icon(
                                    Icons.shopping_bag_rounded, 
                                    size: 60, 
                                    color: const Color(0xFFFF8FA3).withOpacity(0.6)
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // --- INFO PRODUK ---
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama
                                Text(
                                  product.name, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4E342E)), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                const SizedBox(height: 4),
                                
                                // Harga
                                Text(
                                  "Rp ${product.price}", 
                                  style: const TextStyle(color: Color.fromARGB(255, 233, 108, 131), fontWeight: FontWeight.w700, fontSize: 14)
                                ),
                                const SizedBox(height: 8),
                                
                                // --- TOMBOL AKSI (Edit & Hapus) ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Tombol Edit
                                    InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                          context, 
                                          MaterialPageRoute(builder: (_) => ProductFormScreen(product: product))
                                        );
                                        _refreshProducts();
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                                        child: const Icon(Icons.edit_rounded, size: 18, color: Colors.orange),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Tombol Hapus
                                    InkWell(
                                      onTap: () => _deleteProduct(product.id),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                                        child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}