class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  // final String imageUrl; // <--- HAPUS INI

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    // required this.imageUrl, // <--- HAPUS INI
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      description: json['description'] ?? '',
      // imageUrl: json['image_url'] ?? '', // <--- HAPUS INI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      // 'image_url': imageUrl, // <--- HAPUS INI
    };
  }
}