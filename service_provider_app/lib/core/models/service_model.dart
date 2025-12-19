// lib/core/models/service_model.dart
import 'package:service_provider_app/core/models/provider_model.dart';

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
  
  // Optional joined data
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
      id: json['id'],
      providerId: json['provider_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      provider: json['providers'] != null
          ? ProviderModel.fromJson(json['providers'])
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

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? title,
    String? description,
    String? category,
    double? price,
    int? durationMinutes,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProviderModel? provider,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      provider: provider ?? this.provider,
    );
  }
}

