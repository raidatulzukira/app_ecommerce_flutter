import 'package:flutter/material.dart';
import '../../models/review_model.dart';

class ReviewDetailScreen extends StatelessWidget {
  final Review review;
  const ReviewDetailScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 230, 233),
      appBar: AppBar(title: const Text("Detail Review", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)), backgroundColor: Color.fromARGB(255, 243, 129, 149), foregroundColor: const Color.fromARGB(255, 255, 255, 255)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Icon(Icons.format_quote_rounded, size: 50, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => Icon(
                      index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 30,
                    )),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    review.comment,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Color(0xFF5D4037), fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  _buildInfoRow("Product ID", "${review.productId}"),
                  _buildInfoRow("User ID", "${review.userId}"),
                  _buildInfoRow("Review ID", review.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}