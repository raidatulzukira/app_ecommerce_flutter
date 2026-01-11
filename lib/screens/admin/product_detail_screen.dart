import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import 'product_form_screen.dart'; // Untuk edit dari halaman detail

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // 2. TAMBAHKAN VARIABEL USER ID
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadSession(); // 3. PANGGIL FUNGSI SESSION
  }

  // 4. BUAT FUNGSI AMBIL ID DARI HP
  void _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
    });
  }

  void _addToCart() async {
    // Cek apakah user sudah login
    if (_userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // 5. PERBAIKI PEMANGGILAN FUNGSI (Kirim 3 Parameter)
    // Parameter: (User ID, Product ID, Quantity 1)
    bool success = await _apiService.addToCart(_userId, widget.product, 1);
    
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil masuk keranjang!"),
          backgroundColor: Color.fromARGB(255, 241, 117, 140),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menambahkan. Cek koneksi backend."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 232, 240), // Background Lavender Blush
      
      // AppBar Transparan agar gambar terlihat full di atas (opsional)
      // Disini kita pakai AppBar biasa tapi warnanya senada
      appBar: AppBar(
        title: const Text("Detail Produk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
        backgroundColor: Color.fromARGB(255, 239, 130, 150), 
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          // Tombol Edit di pojok kanan atas
          // IconButton(
          //   icon: const Icon(Icons.edit, color: Color(0xFFFF5C8D)),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => ProductFormScreen(product: widget.product)),
          //     );
          //   },
          // )
        ],
      ),
      
      body: Column(
        children: [
          // BAGIAN ATAS: Gambar / Icon Produk
          Expanded(
            flex: 2, // Mengambil 40% layar
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Center(
                child: Hero(
                  tag: 'product-${widget.product.id}', // Efek animasi transisi
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    size: 150,
                    color: Color(0xFFFFC1CC), // Soft Pink
                  ),
                ),
              ),
            ),
          ),

          // BAGIAN BAWAH: Informasi & Tombol
          Expanded(
            flex: 3, // Mengambil 60% layar
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Harga
                  Text(
                    "Rp ${widget.product.price}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5C8D), // Pink Tua
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi Title
                  const Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Isi Deskripsi
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.product.description ?? "Tidak ada deskripsi.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Add to Cart Besar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addToCart,
                      icon: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Icon(Icons.shopping_cart_checkout),
                      label: Text(_isLoading ? "Menambahkan..." : "TAMBAH KE KERANJANG"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 233, 108, 131),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),

                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}