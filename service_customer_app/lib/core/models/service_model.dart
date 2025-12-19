import 'provider_model.dart';

class ServiceModel {
  final String id;
  final String providerId;
  final String title;
  final String? description;
  final String category;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional nested provider data
  final ProviderModel? provider;

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    this.description,
    required this.category,
    required this.price,
    required this.durationMinutes,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.provider,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      provider: json['providers'] != null
          ? ProviderModel.fromJson(json['providers'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'duration_minutes': durationMinutes,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
