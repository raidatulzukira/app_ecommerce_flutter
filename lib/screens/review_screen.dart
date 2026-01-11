import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';
import 'add_review_screen.dart'; 
import 'review_detail_screen.dart'; 

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Review>> _reviewsFuture;

  // Variabel Session
  int _currentUserId = 0;
  String _role = 'customer';

  @override
  void initState() {
    super.initState();
    _loadSession();
    _refreshReviews();
  }

  // Fungsi Cek Siapa yang Login
  void _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('userId') ?? 0;
      _role = prefs.getString('role') ?? 'customer';
    });
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = _apiService.fetchReviews();
    });
  }

  void _deleteReview(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Hapus Review?"),
                content: const Text("Yakin ingin menghapus ulasan ini?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Hapus",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      bool success = await _apiService.deleteReview(id);
      _refreshReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? "Review berhasil dihapus" : "Gagal menghapus review"),
            backgroundColor:
                success ? Color.fromARGB(255, 231, 118, 139) : Colors.red,
          ),
        );
      }
    }
  }

  // Helper untuk menampilkan bintang
  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan Role
    bool isAdmin = _role == 'admin';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      
      // 2. LOGIKA JUDUL APPBAR
      appBar: AppBar(
        // Jika Admin: "Moderasi Review", Jika Customer: "Ulasan Produk"
        title: Text(
          isAdmin ? "Moderasi Review" : "Ulasan Produk", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 237, 126, 146), // Pink konsisten
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // 3. LOGIKA FLOATING ACTION BUTTON
      // Hanya Customer yang boleh tambah review
      floatingActionButton: !isAdmin
          ? FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 233, 108, 131),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReviewScreen()));
                _refreshReviews();
              },
            )
          : null, // Admin tidak punya tombol tambah

      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5C8D)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada ulasan.", style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final review = snapshot.data![index];
              
              // 4. LOGIKA KEPEMILIKAN (KUNCI UTAMA)
              // Cek apakah ini review milik user yang sedang login?
              bool isMyReview = (_currentUserId != 0) && (review.userId == _currentUserId);

              // Tentukan apakah baris tombol harus muncul
              // Muncul jika: SAYA ADMIN -atau- INI REVIEW SAYA
              bool showActions = isAdmin || isMyReview;

              return Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 251, 230, 234),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    // Siapapun bisa klik untuk lihat detail
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: review)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Header Card (Product ID & Rating) ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Product ID: ${review.productId}",
                                  style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 230, 130, 130), fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildStars(review.rating),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // --- Isi Komentar ---
                          Text(
                            review.comment,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
                          ),
                          
                          // 5. TOMBOL AKSI (Hanya muncul jika berhak)
                          if (showActions) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 1, color: Color.fromARGB(255, 255, 255, 255)),
                            const SizedBox(height: 4),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Tombol Edit: HANYA jika Customer DAN Punya Sendiri
                                if (!isAdmin && isMyReview) 
                                  TextButton.icon(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => AddReviewScreen(review: review)),
                                      );
                                      _refreshReviews();
                                    },
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.orange),
                                    label: const Text("Edit", style: TextStyle(color: Colors.orange)),
                                  ),

                                const SizedBox(width: 8),

                                // Tombol Hapus: Muncul karena showActions sudah true
                                // (Bisa karena saya Admin, atau karena ini review saya)
                                TextButton.icon(
                                  onPressed: () => _deleteReview(review.id),
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  label: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ] 
                          // Jika showActions false (Review orang lain dilihat Customer), 
                          // bagian ini tidak akan dirender sama sekali.
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
