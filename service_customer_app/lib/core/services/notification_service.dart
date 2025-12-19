// ============================================
// lib/core/services/notification_service.dart
// ============================================
import 'package:service_customer_app/core/errors/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/notification_model.dart';
import '../config/supabase_config.dart';

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

  /// Fetch unread notifications only
  Future<List<NotificationModel>> fetchUnreadNotifications() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Failed to fetch unread notifications: ${e.toString()}');
    }
  }

  /// Fetch notifications by type
  Future<List<NotificationModel>> fetchNotificationsByType(String type) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('type', type)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Failed to fetch notifications by type: ${e.toString()}');
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

  /// Create a new notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'reference_id': referenceId,
        'is_read': false,
      });
    } catch (e) {
      throw AppException('Failed to create notification: ${e.toString()}');
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

  /// Delete all notifications for the current user
  Future<void> deleteAllNotifications() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw AppException('Failed to delete all notifications: ${e.toString()}');
    }
  }

  /// Delete read notifications only
  Future<void> deleteReadNotifications() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true);
    } catch (e) {
      throw AppException('Failed to delete read notifications: ${e.toString()}');
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
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('id', notificationId)
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Stream notifications for real-time updates
  Stream<List<NotificationModel>> streamNotifications() {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => NotificationModel.fromJson(json))
            .toList());
  }

  /// Stream unread notification count for real-time updates
  Stream<int> streamUnreadCount() {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) {
      return Stream.value(0);
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .eq('is_read', false)
        .map((data) => data.length);
  }

  /// Create booking notification
  Future<void> createBookingNotification({
    required String userId,
    required String bookingId,
    required String status,
    required String serviceTitle,
  }) async {
    String title;
    String body;
    String type = 'booking';

    switch (status) {
      case 'pending':
        title = 'Booking Pending';
        body = 'Your booking for $serviceTitle is pending confirmation.';
        break;
      case 'confirmed':
        title = 'Booking Confirmed';
        body = 'Your booking for $serviceTitle has been confirmed!';
        break;
      case 'cancelled':
        title = 'Booking Cancelled';
        body = 'Your booking for $serviceTitle has been cancelled.';
        break;
      case 'completed':
        title = 'Booking Completed';
        body = 'Your booking for $serviceTitle is complete. Please leave a review!';
        break;
      default:
        title = 'Booking Update';
        body = 'Your booking for $serviceTitle has been updated.';
    }

    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
      referenceId: bookingId,
    );
  }

  /// Create message notification
  Future<void> createMessageNotification({
    required String userId,
    required String conversationId,
    required String senderName,
    required String messagePreview,
  }) async {
    await createNotification(
      userId: userId,
      title: 'New Message from $senderName',
      body: messagePreview,
      type: 'message',
      referenceId: conversationId,
    );
  }

  /// Create review notification
  Future<void> createReviewNotification({
    required String userId,
    required String bookingId,
    required String customerName,
    required int rating,
  }) async {
    await createNotification(
      userId: userId,
      title: 'New Review',
      body: '$customerName left you a $rating-star review!',
      type: 'review',
      referenceId: bookingId,
    );
  }

  /// Create payment notification
  Future<void> createPaymentNotification({
    required String userId,
    required String bookingId,
    required String status,
    required double amount,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'completed':
        title = 'Payment Successful';
        body = 'Payment of \$${amount.toStringAsFixed(2)} was successful.';
        break;
      case 'failed':
        title = 'Payment Failed';
        body = 'Payment of \$${amount.toStringAsFixed(2)} failed. Please try again.';
        break;
      case 'refunded':
        title = 'Payment Refunded';
        body = 'Payment of \$${amount.toStringAsFixed(2)} has been refunded.';
        break;
      default:
        title = 'Payment Update';
        body = 'Payment status has been updated.';
    }

    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: 'payment',
      referenceId: bookingId,
    );
  }
}

extension on SupabaseStreamBuilder {
  eq(String s, bool bool) {}
}
