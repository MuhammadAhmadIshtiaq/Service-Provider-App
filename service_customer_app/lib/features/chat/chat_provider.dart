
// ============================================
// FIXED: lib/features/chat/chat_provider.dart
// Issue: Messages not properly ordered chronologically
// Fix: Always sort by created_at ASC, append new messages at end
// ============================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/message_model.dart';
import '../../core/errors/app_exception.dart';

class ChatState {
  final List<ConversationModel> conversations;
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;
  final String? currentConversationId;

  ChatState({
    this.conversations = const [],
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.currentConversationId,
  });

  ChatState copyWith({
    List<ConversationModel>? conversations,
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
    String? currentConversationId,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentConversationId: currentConversationId ?? this.currentConversationId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  final _supabase = SupabaseConfig.client;
Future<void> loadConversations() async {
  try {
    state = state.copyWith(isLoading: true, error: null);

    final userId = SupabaseConfig.currentUserId;
    if (userId == null) {
      throw AuthException('Not authenticated');
    }

    print('📥 Loading conversations for user: $userId');

    // ✅ CRITICAL: Proper Supabase join syntax
    final response = await _supabase
        .from('conversations')
        .select('''
          *,
          providers (
            id,
            business_name,
            business_logo_url
          )
        ''')
        .eq('customer_id', userId)
        .order('last_message_at', ascending: false);

    print('📦 Raw Supabase response:');
    print('   Type: ${response.runtimeType}');
    print('   Length: ${(response as List).length}');
    
    if ((response as List).isNotEmpty) {
      print('   First item keys: ${response.first.keys.toList()}');
      print('   First item providers: ${response.first['providers']}');
    }

    final conversations = (response as List)
        .map((json) {
          print('🔍 Processing conversation: ${json['id']}');
          return ConversationModel.fromJson(json);
        })
        .toList();

    print('✅ Loaded ${conversations.length} conversations');
    
    // Verify provider data is present
    for (var conv in conversations) {
      if (conv.provider != null) {
        print('   ✅ Conversation ${conv.id} has provider data');
      } else {
        print('   ⚠️ Conversation ${conv.id} MISSING provider data');
      }
    }

    state = state.copyWith(conversations: conversations, isLoading: false);
  } catch (e, stackTrace) {
    print('❌ Error loading conversations: $e');
    print('Stack trace: $stackTrace');
    state = state.copyWith(
      error: AppException.getErrorMessage(e),
      isLoading: false,
    );
  }
}

  Future<void> loadMessages(String conversationId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        currentConversationId: conversationId,
      );

      print('📥 Loading messages for conversation: $conversationId');

      // ✅ CRITICAL: Query ordered by created_at ASCENDING (oldest first)
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true); // ← OLDEST FIRST

      final messages =
          (response as List).map((json) => MessageModel.fromJson(json)).toList();

      // ✅ CRITICAL: Ensure messages are sorted chronologically
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        currentConversationId: conversationId,
      );

      print('✅ Loaded ${messages.length} messages in chronological order');
      
      // Debug: Print first 5 messages to verify order
      if (messages.isNotEmpty) {
        print('📊 Message order verification:');
        for (var i = 0; i < messages.length && i < 5; i++) {
          final preview = messages[i].message.length > 30 
              ? '${messages[i].message.substring(0, 30)}...'
              : messages[i].message;
          print('  ${i + 1}. [${messages[i].createdAt}] $preview');
        }
      }

      // Subscribe to new messages
      _subscribeToMessages(conversationId);
    } catch (e) {
      print('❌ Error loading messages: $e');
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  void _subscribeToMessages(String conversationId) {
    print('🔔 Subscribing to realtime messages for: $conversationId');
    
    // ✅ CRITICAL: Realtime stream with proper ordering
    _supabase
        .from('messages:conversation_id=eq.$conversationId')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true) // ← OLDEST FIRST
        .listen((data) {
          print('🔔 Realtime update received: ${data.length} total messages');
          
          final messages =
              data.map((json) => MessageModel.fromJson(json)).toList();
          
          // ✅ CRITICAL: Sort messages chronologically
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          // Update state with sorted messages
          state = state.copyWith(messages: messages);
          
          print('✅ Messages updated: ${messages.length} messages (chronologically sorted)');
          
          // Debug: Print last message
          if (messages.isNotEmpty) {
            final lastMsg = messages.last;
            final preview = lastMsg.message.length > 30 
                ? '${lastMsg.message.substring(0, 30)}...'
                : lastMsg.message;
            print('   Latest: [${lastMsg.createdAt}] $preview');
          }
        }, onError: (error) {
          print('❌ Realtime subscription error: $error');
        });
  }

  Future<String> getOrCreateConversation(String providerId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      print('🔍 Getting/Creating conversation for provider: $providerId');

      // First, try to find existing conversation
      final existingConversations = await _supabase
          .from('conversations')
          .select()
          .eq('customer_id', userId)
          .eq('provider_id', providerId)
          .limit(1);

      if (existingConversations.isNotEmpty) {
        final conversationId = existingConversations[0]['id'] as String;
        print('✅ Found existing conversation: $conversationId');
        return conversationId;
      }

      // Create new conversation
      print('📝 Creating new conversation...');
      final newConversation = await _supabase
          .from('conversations')
          .insert({
            'customer_id': userId,
            'provider_id': providerId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final conversationId = newConversation['id'] as String;
      print('✅ Created new conversation: $conversationId');

      // Reload conversations list
      await loadConversations();

      return conversationId;
    } catch (e) {
      print('❌ Error in getOrCreateConversation: $e');
      throw AppException('Failed to create conversation: ${e.toString()}');
    }
  }

  Future<void> sendMessage(String conversationId, String message) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      if (message.trim().isEmpty) {
        throw AppException('Message cannot be empty');
      }

      print('📤 Sending message to conversation: $conversationId');

      // ✅ CRITICAL: Let database set created_at for consistent server timestamps
      // This ensures proper ordering across all clients
      final insertedMessage = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': userId,
            'message': message.trim(),
            'is_read': false,
            // ⚠️ DON'T set created_at manually - let database default handle it
          })
          .select()
          .single();

      print('✅ Message sent successfully');
      print('   Message ID: ${insertedMessage['id']}');
      print('   Created at: ${insertedMessage['created_at']}');

      // Update conversation's last message and timestamp
      await _supabase
          .from('conversations')
          .update({
            'last_message': message.trim(),
            'last_message_at': insertedMessage['created_at'], // Use server timestamp
          })
          .eq('id', conversationId);

      print('✅ Conversation updated with last message');

      // Reload conversations to show updated last message
      await loadConversations();
      
      // ✅ Note: Realtime subscription will automatically add this message
      // to the messages list in chronological order
    } catch (e) {
      print('❌ Error sending message: $e');
      throw AppException('Failed to send message: ${e.toString()}');
    }
  }

  void clearMessages() {
    print('🧹 Clearing messages from state');
    state = state.copyWith(
      messages: [],
      currentConversationId: null,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier()..loadConversations();
});