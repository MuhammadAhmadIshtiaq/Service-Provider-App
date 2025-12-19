// lib/core/models/provider_model.dart
class ProviderModel {
  final String id;
  final String userId;
  final String businessName;
  final String? businessDescription;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessLogoUrl;
  final List<String> serviceCategories;
  final double rating;
  final int totalReviews;
  final int totalBookings;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.businessName,
    this.businessDescription,
    this.businessAddress,
    this.businessPhone,
    this.businessLogoUrl,
    this.serviceCategories = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'],
      userId: json['user_id'],
      businessName: json['business_name'],
      businessDescription: json['business_description'],
      businessAddress: json['business_address'],
      businessPhone: json['business_phone'],
      businessLogoUrl: json['business_logo_url'],
      serviceCategories: json['service_categories'] != null
          ? List<String>.from(json['service_categories'])
          : [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_description': businessDescription,
      'business_address': businessAddress,
      'business_phone': businessPhone,
      'business_logo_url': businessLogoUrl,
      'service_categories': serviceCategories,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_bookings': totalBookings,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProviderModel copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? businessDescription,
    String? businessAddress,
    String? businessPhone,
    String? businessLogoUrl,
    List<String>? serviceCategories,
    double? rating,
    int? totalReviews,
    int? totalBookings,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalBookings: totalBookings ?? this.totalBookings,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

