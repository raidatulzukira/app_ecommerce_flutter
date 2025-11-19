import 'dart:convert';

class Product {
  final int id;
  final String name;
  final int price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  // Perhatikan: 'Description' di API Anda menggunakan 'D' besar
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['Description'], // Sesuaikan dengan key di API Anda
    );
  }
}
