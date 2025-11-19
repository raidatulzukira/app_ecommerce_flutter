class CartItem {
  final int id;
  final String name;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // PHP kadang mengirim angka sebagai string/int/double, kita parsing aman
    return CartItem(
      id: json['id'],
      name: json['name'],
      quantity: int.parse(json['quantity'].toString()),
      price: double.parse(json['price'].toString()),
    );
  }
}

class CartResponse {
  final List<CartItem> items;
  final double total;

  CartResponse({required this.items, required this.total});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<CartItem> itemsList = list.map((i) => CartItem.fromJson(i)).toList();

    return CartResponse(
      items: itemsList,
      total: double.parse(json['total'].toString()),
    );
  }
}
