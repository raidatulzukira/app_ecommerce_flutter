import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Pastikan sudah add dependency intl di pubspec.yaml
import '../../models/cart_model.dart';
import '../../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Format Currency Rupiah
  String formatRupiah(double number) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(number);
  }

  void _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
    });

    if (_userId != 0) {
      final items = await _apiService.fetchCart(_userId);
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Hitung Total Harga
  double get _totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  void _updateQuantity(CartItem item, int change) async {
    int newQty = item.quantity + change;

    if (newQty < 1) return; // Tidak boleh 0, gunakan tombol hapus jika ingin menghapus

    // Optimistic UI Update (Ubah tampilan dulu biar cepat)
    setState(() {
      item.quantity = newQty;
    });

    // Kirim ke Backend
    bool success = await _apiService.updateCartQuantity(_userId, item.productId, newQty);
    
    // Jika gagal, kembalikan ke angka semula
    if (!success) {
      setState(() {
        item.quantity = item.quantity - change;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengupdate keranjang")));
      }
    }
  }

  void _deleteItem(int productId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Item?"),
        content: const Text("Yakin ingin menghapus produk ini dari keranjang?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
      bool success = await _apiService.removeCartItem(_userId, productId);
      if (success) {
        _loadCart(); // Reload data
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item dihapus"), backgroundColor: Color.fromARGB(255, 221, 125, 143)));
      } else {
        setState(() => _isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromARGB(255, 237, 126, 146),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5C8D)))
          : _cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Keranjang masih kosong", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // LIST ITEM
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Icon Produk
                                  Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.shopping_bag, color: Color(0xFFFF5C8D)),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Info Produk
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(formatRupiah(item.price), style: const TextStyle(color: Color(0xFFFF5C8D), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),

                                  // Kontrol Quantity
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                        onPressed: () => _updateQuantity(item, -1),
                                      ),
                                      Text("${item.quantity}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF5C8D)),
                                        onPressed: () => _updateQuantity(item, 1),
                                      ),
                                    ],
                                  ),

                                  // Tombol Hapus
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteItem(item.productId),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // TOTAL HARGA & CHECKOUT
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Harga:", style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 129, 120, 120))),
                              Text(formatRupiah(_totalPrice), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Checkout belum tersedia")));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 233, 108, 131),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("CHECKOUT SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}