import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifications_provider.dart';

/// A premium badge widget that displays the unread notification count
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
            left: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    badgeColor ?? Colors.red[500]!,
                    badgeColor?.withOpacity(0.8) ?? Colors.red[600]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: (badgeColor ?? Colors.red).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
