// lib/core/models/message_model.dart
import 'package:service_provider_app/core/models/user_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  
  // Optional joined data
  final UserModel? sender;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'] != null
          ? UserModel.fromJson(json['sender'])
          : null,
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

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    UserModel? sender,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }
}

