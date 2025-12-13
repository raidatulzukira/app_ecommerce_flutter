import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';
import 'review_detail_screen.dart';
import 'add_review_screen.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Review>> futureReviews;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      futureReviews = apiService.fetchReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('Ulasan Pengguna', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        toolbarHeight: 60,
        titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
      ),
      body: FutureBuilder<List<Review>>(
        future: futureReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data. Pastikan server 5002 jalan.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada ulasan.'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Review review = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue[50],

                      child: Text(
                        "${review.id}",

                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 17,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // 1. BAGIAN ATAS: PRODUCT ID
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Product ID: ${review.productId}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Review ID kecil di pojok kanan
                        Text(
                          "#${review.id}",
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. BAGIAN TENGAH: RATING (BINTANG)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Row(
                            children: [
                              // Generate Bintang
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Angka Rating
                              // Text(
                              //   "${review.rating}.0",
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.grey[600],
                              //     fontSize: 13,
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                        // 3. BAGIAN BAWAH: ISI REVIEW
                        Text(
                          review.review,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.density_small_outlined,
                        size: 20,
                        color: Colors.blue[300],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ReviewDetailScreen(reviewId: review.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReviewScreen()),
          );

          // Jika sukses (true), refresh list
          if (result == true) {
            _loadReviews();
          }
        },
        backgroundColor: Colors.teal,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Tulis Ulasan", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
