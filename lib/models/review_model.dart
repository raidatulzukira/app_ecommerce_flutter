class Review {
  final int id;
  final int productId;
  final String review;
  final int rating;

  Review({
    required this.id,
    required this.productId,
    required this.review,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product_id'],
      review: json['review'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'review': review, 'rating': rating};
  }
}
