// ============================================
// lib/features/notifications/widgets/notification_badge.dart
// ============================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifications_provider.dart';

/// A badge widget that displays the unread notification count
class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final Color? badgeColor;
  final Color? textColor;

  const NotificationBadge({
    super.key,
    required this.child,
    this.badgeColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (unreadCount > 0)
          Positioned(
            right: -4,
            top: -0,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (badgeColor ?? const Color(0xFFef4444)).withOpacity(0.9),
                    (badgeColor ?? const Color(0xFFef4444)),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (badgeColor ?? const Color(0xFFef4444)).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

