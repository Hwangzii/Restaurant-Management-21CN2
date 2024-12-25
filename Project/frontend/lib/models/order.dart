class Order {
  final int? id; // ID của order, null nếu là order mới
  final String tableName;
  final String itemName;
  final int quantity;
  final int itemPrice;
  final String status;

  Order({
    this.id,
    required this.tableName,
    required this.itemName,
    required this.quantity,
    required this.itemPrice,
    this.status = 'Pending',
  });

  // Chuyển đổi từ Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'table_name': tableName,
      'item_name': itemName,
      'quantity': quantity,
      'item_price': itemPrice,
      'status': status,
    };
  }

  // Chuyển đổi từ JSON sang Dart (nếu cần)
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableName: json['table_name'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      itemPrice: json['item_price'],
      status: json['status'],
    );
  }
}
