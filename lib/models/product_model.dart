class Product {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final String discount;
  final String category;
  final String description;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.category,
    required this.description,
    this.quantity = 1,
  });

  // Method to convert Product object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'discount': discount,
      'category': category,
      'description': description,
    };
  }

  // Method to create Product object from Firestore Map
  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: data['price'] is int ? data['price'] : 0,
      discount: data['discount'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
