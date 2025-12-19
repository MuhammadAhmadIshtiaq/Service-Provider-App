// lib/features/chat/chat_provider.dart
// FIXED VERSION WITH CUSTOMER PROFILES AND AVATARS

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/message_model.dart';
import '../auth/auth_provider.dart';

// FIXED: Now fetches customer data with JOIN
final conversationsProvider = StreamProvider<List<ConversationModel>>((ref) {
  final providerProfile = ref.watch(currentProviderProvider);

  return providerProfile.when(
    data: (provider) {
      if (provider == null) return Stream.value([]);

      return SupabaseConfig.client
          .from(SupabaseConfig.conversationsTable)
          .stream(primaryKey: ['id'])
          .eq('provider_id', provider.id)
          .order('last_message_at', ascending: false)
          .map((data) {
            // For each conversation, fetch customer details
            return data.map((json) async {
              try {
                // Fetch customer details
                final customerData = await SupabaseConfig.client
                    .from(SupabaseConfig.usersTable)
                    .select()
                    .eq('id', json['customer_id'])
                    .single();
                
                // Add customer data to conversation
                json['customer'] = customerData;
              } catch (e) {
                print('Error fetching customer for conversation: $e');
              }
              
              return ConversationModel.fromJson(json);
            }).toList();
          })
          .asyncMap((futures) => Future.wait(futures));
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// FIXED: Messages now include sender data
final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return SupabaseConfig.client
      .from(SupabaseConfig.messagesTable)
      .stream(primaryKey: ['id'])
      .eq('conversation_id', conversationId)
      .order('created_at', ascending: true)
      .map((data) {
        // For each message, fetch sender details
        return data.map((json) async {
          try {
            // Fetch sender details
            final senderData = await SupabaseConfig.client
                .from(SupabaseConfig.usersTable)
                .select()
                .eq('id', json['sender_id'])
                .single();
            
            // Add sender data to message
            json['sender'] = senderData;
          } catch (e) {
            print('Error fetching sender for message: $e');
          }
          
          return MessageModel.fromJson(json);
        }).toList();
      })
      .asyncMap((futures) => Future.wait(futures));
});

// Get conversation with customer details
final conversationByIdProvider = FutureProvider.family<ConversationModel?, String>((ref, conversationId) async {
  try {
    final response = await SupabaseConfig.client
        .from(SupabaseConfig.conversationsTable)
        .select()
        .eq('id', conversationId)
        .single();
    
    // Fetch customer details
    final customerData = await SupabaseConfig.client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('id', response['customer_id'])
        .single();
    
    response['customer'] = customerData;
    
    return ConversationModel.fromJson(response);
  } catch (e) {
    print('Error fetching conversation: $e');
    return null;
  }
});

class ChatController extends StateNotifier<AsyncValue<void>> {
  ChatController() : super(const AsyncValue.data(null));

  Future<void> sendMessage(String conversationId, String senderId, String message) async {
    try {
      await SupabaseConfig.client.from(SupabaseConfig.messagesTable).insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'message': message,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController();
});