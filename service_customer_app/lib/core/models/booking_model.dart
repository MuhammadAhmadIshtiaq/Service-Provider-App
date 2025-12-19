import 'provider_model.dart';
import 'service_model.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String providerId;
  final String serviceId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final double totalPrice;
  final String? customerNotes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional nested data
  final ProviderModel? provider;
  final ServiceModel? service;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    this.customerNotes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.provider,
    this.service,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      serviceId: json['service_id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: json['status'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      customerNotes: json['customer_notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      provider: json['providers'] != null
          ? ProviderModel.fromJson(json['providers'] as Map<String, dynamic>)
          : null,
      service: json['services'] != null
          ? ServiceModel.fromJson(json['services'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'total_price': totalPrice,
      'customer_notes': customerNotes,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get canCancel => isPending || isConfirmed;
  bool get canReview => isCompleted;
}
