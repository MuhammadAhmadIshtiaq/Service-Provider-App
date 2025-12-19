// lib/features/notifications/notifications_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/notification_model.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0f172a).withOpacity(0.8),
                    const Color(0xFF1e293b).withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          if (notificationsState.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  ref.read(notificationsProvider.notifier).markAllAsRead();
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF06b6d4),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0f172a),
              Color(0xFF1e293b),
              Color(0xFF0f172a),
            ],
          ),
        ),
        child: _buildBody(context, notificationsState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state) {
    if (state.isLoading && !state.isInitialized) {
      return Center(
        child: _GlassContainer(
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.error!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _GlassButton(
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).refresh();
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Color(0xFF06b6d4)),
                        SizedBox(width: 8),
                        Text(
                          'Retry',
                          style: TextStyle(
                            color: Color(0xFF06b6d4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationsProvider.notifier).refresh();
      },
      color: const Color(0xFF06b6d4),
      backgroundColor: const Color(0xFF1e293b),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationTile(context, notification),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: _GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF06b6d4).withOpacity(0.2),
                      const Color(0xFF06b6d4).withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF06b6d4).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 64,
                  color: const Color(0xFF06b6d4).withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No notifications',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'re all caught up!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.transparent, Colors.red],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: _GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Delete notification',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Are you sure you want to delete this notification?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _GlassButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _GlassButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            gradient: const LinearGradient(
                              colors: [Colors.red, Color(0xFFdc2626)],
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: const Color(0xFF1e293b),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: _GlassContainer(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: notification.isRead
                  ? LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.2),
                        Colors.grey.withOpacity(0.1),
                      ],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
                    ),
              border: Border.all(
                color: notification.isRead
                    ? Colors.grey.withOpacity(0.3)
                    : const Color(0xFF06b6d4).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: notification.isRead
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: notification.isRead
                  ? Colors.grey.withOpacity(0.6)
                  : Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: const Color(0xFF06b6d4).withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatRelativeTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF06b6d4).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
          trailing: notification.isRead
              ? null
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06b6d4).withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
          onTap: () => _handleNotificationTap(context, notification),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    if (notification.type == 'new_message' || notification.type == 'message') {
      return;
    }

    if (notification.referenceId != null) {
      switch (notification.type) {
        case 'booking_update':
        case 'booking_created':
        case 'booking_confirmed':
        case 'booking_cancelled':
        case 'booking_completed':
          context.push('/bookings/${notification.referenceId}');
          break;
        case 'review':
        case 'new_review':
          context.push('/bookings/${notification.referenceId}');
          break;
        case 'payment_update':
        case 'payment_completed':
        case 'payment_failed':
          context.push('/bookings/${notification.referenceId}');
          break;
        case 'service_inquiry':
          context.push('/chat');
          break;
        default:
          _showNotificationDetails(context, notification);
      }
    } else {
      _showNotificationDetails(context, notification);
    }
  }

  void _showNotificationDetails(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: _GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: const Color(0xFF06b6d4).withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        Formatters.formatRelativeTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF06b6d4).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _GlassButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFF06b6d4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_update':
      case 'booking_created':
      case 'booking_confirmed':
      case 'booking_cancelled':
      case 'booking_completed':
        return Icons.event_rounded;
      case 'new_message':
      case 'message':
        return Icons.message_rounded;
      case 'review':
      case 'new_review':
        return Icons.star_rounded;
      case 'payment_update':
      case 'payment_completed':
      case 'payment_failed':
        return Icons.payment_rounded;
      case 'service_inquiry':
        return Icons.help_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;

  const _GlassContainer({
    required this.child,
    this.blur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF06b6d4).withOpacity(0.1),
                const Color(0xFF06b6d4).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Gradient? gradient;

  const _GlassButton({
    required this.onPressed,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: gradient ??
                    LinearGradient(
                      colors: [
                        const Color(0xFF06b6d4).withOpacity(0.15),
                        const Color(0xFF06b6d4).withOpacity(0.08),
                      ],
                    ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: gradient != null
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF06b6d4).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}