import 'package:service_customer_app/core/models/user_model.dart';

class ConversationModel {
  final String id;
  final String customerId;
  final String providerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  
  // Optional nested data
  final UserModel? customer;
  final dynamic provider; // Can be UserModel or ProviderModel

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
    // ✅ CRITICAL FIX: Check both 'providers' (from Supabase join) and 'provider'
    dynamic providerData;
    
    if (json['providers'] != null) {
      // Supabase returns joined table data using the TABLE NAME (plural)
      providerData = json['providers'];
      print('✅ Found provider data in "providers" key');
    } else if (json['provider'] != null) {
      providerData = json['provider'];
      print('✅ Found provider data in "provider" key');
    } else {
      print('⚠️ No provider data found in conversation JSON');
      print('   Available keys: ${json.keys.toList()}');
    }

    return ConversationModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      provider: providerData, // ✅ Now correctly captures the provider data
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
      'providers': provider,
    };
  }
}