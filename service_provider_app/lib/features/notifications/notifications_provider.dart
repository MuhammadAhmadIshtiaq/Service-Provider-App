// ============================================
// lib/features/notifications/notifications_provider.dart
// ============================================
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/notification_model.dart';
import '../../core/errors/app_exception.dart' hide AuthException;
import '../../core/services/notification_service.dart';

class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(NotificationsState());

  final _supabase = SupabaseConfig.client;
  final _notificationService = NotificationService();
  StreamSubscription? _notificationSubscription;

  /// Initialize and load notifications
  Future<void> initialize() async {
    if (state.isInitialized) return;

    await loadNotifications();
  }

  /// Load notifications from database
  Future<void> loadNotifications() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      // Fetch notifications
      final notifications = await _notificationService.fetchNotifications();

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        isInitialized: true,
      );

      // Subscribe to real-time updates
      _subscribeToNotifications(userId);
    } catch (e) {
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  /// Subscribe to real-time notification updates
  void _subscribeToNotifications(String userId) {
    // Cancel existing subscription
    _notificationSubscription?.cancel();

    try {
      // Subscribe to notifications table changes for this user
      _notificationSubscription = _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .listen(
            (data) {
              try {
                final notifications = data
                    .map((json) => NotificationModel.fromJson(json))
                    .toList();
                
                // Update state with new notifications
                state = state.copyWith(notifications: notifications);
              } catch (e) {
                // Handle parsing errors silently
                print('Error parsing notification: $e');
              }
            },
            onError: (error) {
              print('Notification stream error: $error');
              state = state.copyWith(error: 'Real-time updates interrupted');
            },
          );
    } catch (e) {
      print('Failed to subscribe to notifications: $e');
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Optimistically update UI
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);

      // Update in database
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      // Revert on error and reload
      await loadNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Optimistically update UI
      final updatedNotifications = state.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);

      // Update in database
      await _notificationService.markAllAsRead();
    } catch (e) {
      // Revert on error and reload
      await loadNotifications();
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Optimistically remove from UI
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();

      state = state.copyWith(notifications: updatedNotifications);

      // Delete from database
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      // Revert on error and reload
      await loadNotifications();
    }
  }

  /// Refresh notifications (for pull-to-refresh)
  Future<void> refresh() async {
    await loadNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}

/// Main notifications provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final notifier = NotificationsNotifier();
  
  // Auto-initialize when provider is created
  notifier.initialize();
  
  return notifier;
});

/// Provider for unread count only (for badges)
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsProvider);
  return notificationsState.unreadCount;
});