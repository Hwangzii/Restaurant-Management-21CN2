class Item {
  final int itemId;
  final String itemName;
  final int itemType;
  final int quantity;
  final DateTime expItem;
  final bool inventoryStatus;
  final int price;
  final String unit;
  final int restaurant; // Thêm trường này

  Item({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.quantity,
    required this.expItem,
    required this.inventoryStatus,
    required this.price,
    required this.unit,
    required this.restaurant,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemType: json['item_type'],
      quantity: json['quantity'],
      expItem: DateTime.parse(json['exp_item']).toLocal(),
      inventoryStatus: json['inventory_status'],
      price: json['price'],
      unit: json['unit'],
      restaurant: json['restaurant'],
    );
  }

  Map<String, dynamic> toJson() {
    final formattedDate =
        "${expItem.year}-${expItem.month.toString().padLeft(2, '0')}-${expItem.day.toString().padLeft(2, '0')}";

    return {
      'item_id': itemId,
      'item_name': itemName,
      'item_type': itemType,
      'quantity': quantity,
      'exp_item': formattedDate,
      'inventory_status': inventoryStatus,
      'price': price,
      'unit': unit,
      'restaurant': 2, // Set cứng giá trị này
    };
  }
}
