import 'user_model.dart';

// ============================================
// REVIEW MODEL
// ============================================
class ReviewModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional nested data
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
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'] as Map<String, dynamic>)
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

// ============================================
// CONVERSATION MODEL
// ============================================
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
      provider: json['provider'],
    );
  }
}

// ============================================
// MESSAGE MODEL
// ============================================
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ============================================
// NOTIFICATION MODEL
// ============================================
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      referenceId: json['reference_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}