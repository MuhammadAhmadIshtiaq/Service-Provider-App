// lib/core/models/payment_model.dart
class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final String? paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      transactionId: json['transaction_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}