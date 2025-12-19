// lib/core/models/booking_model.dart
import 'package:service_provider_app/core/models/provider_model.dart';
import 'package:service_provider_app/core/models/service_model.dart';
import 'package:service_provider_app/core/models/user_model.dart';

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
  
  // Optional joined data
  final ServiceModel? service;
  final ProviderModel? provider;
  final UserModel? customer;

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
    this.service,
    this.provider,
    this.customer,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      serviceId: json['service_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      totalPrice: (json['total_price'] as num).toDouble(),
      customerNotes: json['customer_notes'],
      cancellationReason: json['cancellation_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      service: json['services'] != null
          ? ServiceModel.fromJson(json['services'])
          : null,
      provider: json['providers'] != null
          ? ProviderModel.fromJson(json['providers'])
          : null,
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'])
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

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? providerId,
    String? serviceId,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    String? status,
    double? totalPrice,
    String? customerNotes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    ServiceModel? service,
    ProviderModel? provider,
    UserModel? customer,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      customerNotes: customerNotes ?? this.customerNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      service: service ?? this.service,
      provider: provider ?? this.provider,
      customer: customer ?? this.customer,
    );
  }
}