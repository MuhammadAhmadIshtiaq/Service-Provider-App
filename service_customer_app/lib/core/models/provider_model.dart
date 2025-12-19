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
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String,
      businessDescription: json['business_description'] as String?,
      businessAddress: json['business_address'] as String?,
      businessPhone: json['business_phone'] as String?,
      businessLogoUrl: json['business_logo_url'] as String?,
      serviceCategories: json['service_categories'] != null
          ? List<String>.from(json['service_categories'] as List)
          : [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
}