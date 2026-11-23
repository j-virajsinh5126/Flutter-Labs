class Product {
  const Product({required this.id, required this.title, required this.price, required this.description, required this.category, required this.image, required this.rating, required this.ratingCount});
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'] is Map ? json['rating'] as Map : const {};
    return Product(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      price: (json['price'] as num).toDouble(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'Other').toString(),
      image: (json['image'] ?? '').toString(),
      rating: ((ratingJson['rate'] ?? 0) as num).toDouble(),
      ratingCount: ((ratingJson['count'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'price': price, 'description': description,
    'category': category, 'image': image,
    'rating': {'rate': rating, 'count': ratingCount},
  };
}
