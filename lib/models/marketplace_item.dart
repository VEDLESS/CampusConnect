class MarketplaceItem {
  const MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerEmail,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String sellerEmail;
  final DateTime createdAt;
  final String? imageUrl;

  factory MarketplaceItem.fromMap(String id, Map<String, dynamic> map) {
    return MarketplaceItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Essentials',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? 'Anonymous',
      sellerPhone: map['sellerPhone'] ?? '',
      sellerEmail: map['sellerEmail'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'sellerEmail': sellerEmail,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
