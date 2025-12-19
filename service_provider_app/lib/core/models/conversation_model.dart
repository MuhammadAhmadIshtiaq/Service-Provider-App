// lib/core/models/conversation_model.dart
import 'package:service_provider_app/core/models/provider_model.dart';
import 'package:service_provider_app/core/models/user_model.dart';

class ConversationModel {
  final String id;
  final String customerId;
  final String providerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  
  // Optional joined data
  final UserModel? customer;
  final ProviderModel? provider;

  ConversationModel({
    required this.id,
    required this.customerId,
    required this.providerId,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    this.customer,
    this.provider,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'])
          : null,
      provider: json['providers'] != null
          ? ProviderModel.fromJson(json['providers'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'provider_id': providerId,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

