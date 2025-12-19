// ============================================
// lib/core/services/notification_service.dart
// ============================================
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../config/supabase_config.dart';
import '../errors/app_exception.dart' hide AuthException;

class NotificationService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Fetch all notifications for the current user
  Future<List<NotificationModel>> fetchNotifications({int limit = 50}) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Failed to fetch notifications: ${e.toString()}');
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw AppException('Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read for the current user
  Future<void> markAllAsRead() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw AppException('Failed to mark all as read: ${e.toString()}');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw AppException('Failed to delete notification: ${e.toString()}');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      return 0;
    }
  }
}