// lib/core/models/review_model.dart
import 'package:service_provider_app/core/models/user_model.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional joined data
  final UserModel? customer;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'provider_id': providerId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}