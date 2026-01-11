class Review {
  final String id;
  final int productId;
  final int userId;
  final int rating;
  final String comment;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // 1. Handle ID MongoDB yang kadang ribet formatnya
    String parsedId = '';
    if (json['_id'] != null) {
      if (json['_id'] is Map) {
        // Jika formatnya { "$oid": "xxx" }
        parsedId = json['_id']['\$oid']?.toString() ?? '';
      } else {
        // Jika formatnya string biasa "xxx"
        parsedId = json['_id'].toString();
      }
    }

    return Review(
      id: parsedId,
      // 2. Gunakan tryParse agar kalau data string/int tidak masalah
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      rating: int.tryParse(json['rating'].toString()) ?? 0,
      // 3. Cek kedua kemungkinan nama field (review atau comment)
      // comment: json['review'] ?? json['comment'] ?? '',
      comment: json['review_text'] ?? json['review'] ?? json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'review_text': comment, 
    };
  }
}