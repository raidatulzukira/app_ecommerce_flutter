class CartItem {
  final int productId;
  final String name;
  final double price;
  int quantity; // Tidak final karena bisa diubah (+/-)

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Factory untuk mengubah JSON dari Backend menjadi Object Dart
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: int.parse(json['product_id'].toString()),
      name: json['name'],
      price: double.parse(json['price'].toString()),
      quantity: int.parse(json['quantity'].toString()),
    );
  }

  // Mengubah Object ke JSON (jika perlu dikirim balik)
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}