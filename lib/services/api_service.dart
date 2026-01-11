import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Jangan lupa import ini
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';

class ApiService {
  // IP Sesuai file yang kamu kirim
  final String baseUrlProduct = 'http://10.150.38.203:3000';
  final String baseUrlCart = 'http://10.150.38.203:8000';
  final String baseUrlReview = 'http://10.150.38.203:5012';
  final String baseUrlUser = 'http://10.150.38.203:4000';

  // --- AUTHENTICATION (Ditambahkan Baru) ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrlUser/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Simpan sesi (sederhana)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', data['user']['role']); 
        await prefs.setInt('userId', data['user']['id']);
        
        return {'success': true, 'role': data['user']['role'], 'data': data};
      } else {
        return {'success': false, 'message': 'Email atau password salah'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    final url = Uri.parse('$baseUrlUser/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name, 
        'email': email, 
        'password': password, 
        'role': role
      }),
    );
    return response.statusCode == 201;
  }


  // --- PRODUCT CRUD ---

  // 1. GET ALL
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrlProduct/products'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
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
  // Future<CartResponse> fetchCart() async {
  //   final response = await http.get(Uri.parse('$baseUrlCart/carts'));
  //   if (response.statusCode == 200) {
  //     return CartResponse.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Gagal memuat keranjang');
  //   }
  // }

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

  // Hapus 1 Item di Cart
  // Future<bool> removeCartItem(int userId, int productId) async {
  //   final response = await http.delete(Uri.parse('$baseUrlCart/cart/$userId/item/$productId'));
  //   return response.statusCode == 200;
  // }

  // --- CART SERVICE ---

  // 1. Ambil List Cart berdasarkan User ID
  Future<List<CartItem>> fetchCart(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrlCart/cart/$userId'));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => CartItem.fromJson(item)).toList();
      } else {
        return []; // Kembalikan list kosong jika gagal/kosong
      }
    } catch (e) {
      print("Error fetch cart: $e");
      return [];
    }
  }

  // 2. Hapus Item dari Cart
  Future<bool> removeCartItem(int userId, int productId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrlCart/cart/$userId/$productId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. Update Quantity (Tambah/Kurang)
  // Kita gunakan method PUT ke backend
  Future<bool> updateCartQuantity(int userId, int productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrlCart/cart/$userId/$productId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'quantity': quantity}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
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
  // 4. Tambah Item ke Keranjang (FIXED)
  Future<bool> addToCart(Product product) async {
    try {
      // Ambil User ID yang sedang login
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 1; // Default 1 jika null

      // Endpoint '/cart' (sesuai backend PHP)
      final url = Uri.parse('$baseUrlCart/cart'); 
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,       // ID Admin yang login
          'product_id': product.id,
          'name': product.name,
          'price': product.price,
          'quantity': 1            // Default tambah 1
        }),
      );

      print("Add to Cart Response: ${response.body}"); // Debugging

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error adding to cart: $e");
      return false;
    }
  }

  // --- REVIEW SERVICE (Port 5002) ---

  // 1. Ambil Semua Review
  // Future<List<Review>> fetchReviews() async {
  //   final response = await http.get(Uri.parse('$baseUrlReview/reviews'));
  //   if (response.statusCode == 200) {
  //     List<dynamic> body = jsonDecode(response.body);
  //     return body.map((item) => Review.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Gagal memuat ulasan');
  //   }
  // }

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
  // Future<bool> createReview(Review review) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrlReview/reviews'),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode(review.toJson()),
  //   );
  //   return response.statusCode == 201;
  // }

  // Hapus Review
  // Future<bool> deleteReview(String id) async {
  //   final response = await http.delete(Uri.parse('$baseUrlReview/reviews/$id'));
  //   return response.statusCode == 200;
  // }
  
  // // Edit Review
  // Future<bool> updateReview(String id, int rating, String comment) async {
  //   final response = await http.put(
  //     Uri.parse('$baseUrlReview/reviews/$id'),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({'rating': rating, 'comment': comment}),
  //   );
  //   return response.statusCode == 200;
  // }

  // --- REVIEW SERVICE (Port 5002 - Python/MongoDB) ---

  // 1. Ambil Semua Review
  // 1. Ambil Semua Review (Debug Mode)
  Future<List<Review>> fetchReviews() async {
    try {
      print("Fetching reviews from: $baseUrlReview/reviews"); 
      final response = await http.get(Uri.parse('$baseUrlReview/reviews'));
      
      print("Fetch Status: ${response.statusCode}");
      print("Fetch Body: ${response.body}"); 

      if (response.statusCode == 200) {
        // Decode dulu JSON-nya
        final jsonResponse = jsonDecode(response.body);

        // PERBAIKAN: Ambil list dari dalam key 'data'
        // Karena backend mengirim format: {"success": true, "data": [...]}
        List<dynamic> listData = jsonResponse['data']; 
        
        return listData.map((item) => Review.fromJson(item)).toList();
      } else {
        print("Gagal Fetch: ${response.reasonPhrase}");
        return [];
      }
    } catch (e) {
      print("Error Parsing Fetch Reviews: $e"); 
      return [];
    }
  }

  // 2. Tambah Review (Debug Mode)
  Future<bool> createReview(Review review) async {
    try {
      final url = Uri.parse('$baseUrlReview/reviews');
      final bodyData = jsonEncode(review.toJson());
      
      print("--- SENDING REVIEW ---");
      print("URL: $url");
      print("Data: $bodyData");

      final response = await http.post(
        url,
        // headers: {"Content-Type": "application/json"},
        headers: {
          "Content-Type": "application/json", // <--- INI WAJIB ADA & BENAR
          "Accept": "application/json",       // Tambahkan ini juga biar aman
        },
        body: bodyData,
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error Fatal Create Review: $e");
      return false;
    }
  }

  // 3. Update Review
  Future<bool> updateReview(String id, int productId, int userId, int rating, String comment) async {
    try {
      final url = Uri.parse('$baseUrlReview/reviews/$id');
      
      final bodyData = jsonEncode({
        "product_id": productId,
        "user_id": userId,
        "rating": rating,
        "review_text": comment // Ingat, kuncinya 'review_text'
      });

      print("Updating Review ID: $id");
      print("Data: $bodyData");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: bodyData,
      );

      print("Update Response: ${response.statusCode}");
      print("Update Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error Update Review: $e");
      return false;
    }
  }

  // 4. Delete Review
  Future<bool> deleteReview(String id) async {
    try {
      final url = Uri.parse('$baseUrlReview/reviews/$id');
      print("Deleting Review ID: $id");

      final response = await http.delete(url);
      
      print("Delete Response: ${response.statusCode}");
      
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete Review: $e");
      return false;
    }
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

  Future<bool> createUserWithPassword(User user, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrlUser/users'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'password': password // Password dikirim manual disini
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
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

  // Update User (Hanya Admin yang bisa diedit sesuai rules)
  Future<Map<String, dynamic>> updateUser(int id, String name, String email, String password, String role) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'role': role,
      };

      // Hanya kirim password jika diisi (tidak kosong)
      if (password.isNotEmpty) {
        data['password'] = password;
      }

      print("Sending Data to Update: ${jsonEncode(data)}"); // Cek di Terminal

      final response = await http.put(
        Uri.parse('$baseUrlUser/users/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User berhasil diperbarui!'};
      } else {
        // Ambil pesan error dari backend jika ada
        return {'success': false, 'message': 'Gagal: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi: $e'};
    }
  }

  // Delete User (Dengan Return Pesan Error)
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrlUser/users/$id'));
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User berhasil dihapus!'};
      } else {
        return {'success': false, 'message': 'Gagal hapus: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi: $e'};
    }
  }

}
