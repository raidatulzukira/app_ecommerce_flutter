import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';

class ReviewDetailScreen extends StatelessWidget {
  final int reviewId;
  final ApiService apiService = ApiService();

  ReviewDetailScreen({required this.reviewId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('Detail Ulasan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 60,
        titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
      ),
      body: FutureBuilder<Review>(
        future: apiService.fetchReviewDetail(reviewId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final review = snapshot.data!;

            return Column(
              children: [
                // --- 1. HEADER ICON ---
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  width: double.infinity,
                  color: Colors.teal[50],
                  child: Center(
                    child: Icon(
                      Icons.rate_review_outlined,
                      size: 115,
                      color: Colors.teal,
                    ),
                  ),
                ),

                // --- 2. WHITE SHEET (Konten Utama) ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Review
                        Text(
                          "Product ID: ${review.productId}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Badge Product ID
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Review ID: ${review.id}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // --- RATING BOX (FULL WIDTH) ---
                        Container(
                          width: 280, // Lebar penuh
                          margin: EdgeInsets.only(left: 32.0),
                          padding: EdgeInsets.all(17),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rating",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Angka Rating Besar
                                  Text(
                                    "${review.rating}.0",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(width: 16),

                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 32,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // -------------------------------
                        SizedBox(height: 30),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        SizedBox(height: 20),

                        // --- ISI KOMENTAR ---
                        Text(
                          "Komentar Pengguna",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Text(
                              review.review,
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.5,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
