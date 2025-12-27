import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';

class ApiService {
  // IP Emulator Android (Gunakan IP LAN laptop jika pakai HP fisik)
  final String baseUrlProduct = 'http://10.150.38.203:3000';
  final String baseUrlCart = 'http://10.0.2.2:8000';
  final String baseUrlReview = 'http://10.0.2.2:5002';
  final String baseUrlUser = 'http://10.0.2.2:4000';


  // --- PRODUCT CRUD ---

  // 1. GET ALL
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrlProduct/products'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Backend Anda membungkus data dalam key 'data'
      List<dynamic> body = jsonResponse['data']; 
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  // 2. GET DETAIL
  Future<Product> fetchProductDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrlProduct/products/$id'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Product.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Gagal memuat detail produk');
    }
  }

  // 3. CREATE
  Future<bool> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrlProduct/products'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(product.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 4. UPDATE
  Future<bool> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrlProduct/products/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(product.toJson()),
    );
    return response.statusCode == 200;
  }

  // 5. DELETE
  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrlProduct/products/$id'));
    return response.statusCode == 200;
  }

  // --- PRODUCT SERVICE (Port 3000) ---

  // Future<List<Product>> fetchProducts() async {
  //   final response = await http.get(Uri.parse('$baseUrlProduct/products'));
  //   if (response.statusCode == 200) {
  //     List<dynamic> body = jsonDecode(response.body);
  //     return body.map((item) => Product.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Gagal memuat produk');
  //   }
  // }

  // Future<Product> fetchProductDetail(int id) async {
  //   final response = await http.get(Uri.parse('$baseUrlProduct/products/$id'));
  //   if (response.statusCode == 200) {
  //     return Product.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Gagal memuat detail produk');
  //   }
  // }

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

  // Catatan: Backend PHP saya masih statis (array hardcoded),
  // jadi tidak ada endpoint POST untuk benar-benar menambah data baru dari Product.

  // 4. Tambah Item (Simulasi)
  // Future<bool> addToCart(int productId) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrlCart/carts'),
  //     body: {'id': productId.toString()},
  //   );
  //   return response.statusCode == 201;
  // }

  // 4. Tambah Item ke Keranjang
  // UBAH parameter dari (int productId) MENJADI (Product product)
  Future<bool> addToCart(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrlCart/carts'),
        headers: {"Content-Type": "application/json"},
        // Kirim data lengkap (id, name, price) agar Backend PHP bisa menyimpannya
        body: jsonEncode({
          'product_id': product.id,
          'name': product.name,
          'price': product.price,
        }),
      );
      // Return true jika status 200 (OK) atau 201 (Created)
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error adding to cart: $e");
      return false;
    }
  }

  // --- REVIEW SERVICE (Port 5002) ---

  // 1. Ambil Semua Review
  Future<List<Review>> fetchReviews() async {
    final response = await http.get(Uri.parse('$baseUrlReview/reviews'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat ulasan');
    }
  }

  // 2. Ambil Detail Review
  Future<Review> fetchReviewDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrlReview/reviews/$id'));
    if (response.statusCode == 200) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ulasan tidak ditemukan');
    }
  }

  // 3. Tambah Review Baru
  Future<bool> createReview(Review review) async {
    final response = await http.post(
      Uri.parse('$baseUrlReview/reviews'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(review.toJson()),
    );
    return response.statusCode == 201;
  }

  // --- USER SERVICE (Port 4001) ---

  // 1. Ambil Semua User
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrlUser/users'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat pengguna');
    }
  }

  // 2. Tambah User Baru
  Future<bool> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrlUser/users'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  // 3. Ambil Detail User (TAMBAHKAN INI)
  Future<User> fetchUserDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrlUser/users/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('User tidak ditemukan');
    }
  }
}
