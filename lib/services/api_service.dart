import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/cart_model.dart';

class ApiService {
  // IP Emulator Android (Gunakan IP LAN laptop jika pakai HP fisik)
  final String baseUrlProduct = 'http://10.0.2.2:3000';
  final String baseUrlCart = 'http://10.0.2.2:8000';

  // --- PRODUCT SERVICE (Port 3000) ---

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrlProduct/products'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  Future<Product> fetchProductDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrlProduct/products/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail produk');
    }
  }

  // --- CART SERVICE (Port 8000) ---

  // 1. Ambil List Cart
  Future<CartResponse> fetchCart() async {
    final response = await http.get(Uri.parse('$baseUrlCart/carts'));
    if (response.statusCode == 200) {
      return CartResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat keranjang');
    }
  }

  // 2. Ambil Detail Cart Item
  Future<CartItem> fetchCartDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrlCart/carts/$id'));
    if (response.statusCode == 200) {
      return CartItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Item tidak ditemukan');
    }
  }

  // 3. Hapus Item
  Future<bool> deleteCartItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrlCart/carts/$id'));
    return response.statusCode == 200;
  }

  // Catatan: Backend PHP Anda statis (array hardcoded),
  // jadi tidak ada endpoint POST untuk benar-benar menambah data baru dari Product.

  // 4. Tambah Item (Simulasi)
  Future<bool> addToCart(int productId) async {
    // Kita kirim ID produk, meski backend PHP saat ini tidak menyimpannya
    final response = await http.post(
      Uri.parse('$baseUrlCart/carts'),
      body: {'id': productId.toString()},
    );
    return response.statusCode == 201; // Sesuai return code PHP di atas
  }
}
