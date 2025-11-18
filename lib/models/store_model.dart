import 'dart:convert';

class StoreModel {
  final int id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int count;
  StoreModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.count,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['title'] ?? json['name'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse('${json['price']}') ?? 0.0,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      rating: json['rating'] != null
          ? ((json['rating']['rate'] is num)
              ? (json['rating']['rate'] as num).toDouble()
              : double.tryParse('${json['rating']['rate']}') ?? 0.0)
          : (json['score'] is num ? (json['score'] as num).toDouble() : double.tryParse('${json['score']}') ?? 0.0),
      count: json['rating'] != null ? (json['rating']['count'] ?? 0) : (json['count'] ?? 0),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'price': price,
      'description': description,
      'category': category,
      'image': imageUrl,
      'rating': {
        'rate': rating,
        'count': count,
      },
    };
  }

  // Convenience getters used by UI
  String get title => name;
  double get score => rating;
}