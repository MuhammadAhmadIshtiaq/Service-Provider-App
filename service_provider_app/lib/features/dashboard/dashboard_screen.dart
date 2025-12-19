// lib/features/dashboard/dashboard_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/error_view.dart';
import '../auth/auth_provider.dart';
import '../bookings/bookings_provider.dart';
import '../notifications/widgets/notification_badge.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  Widget _buildUserAvatar(BuildContext context, dynamic user, dynamic provider) {
    final initial = user?.fullName?.substring(0, 1).toUpperCase() ?? 'P';
    final avatarUrl = provider?.businessLogoUrl;
    
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      final displayUrl = '$avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: displayUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF06b6d4).withOpacity(0.2),
                    const Color(0xFF06b6d4).withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFF06b6d4),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF06b6d4).withOpacity(0.2),
                      const Color(0xFF06b6d4).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                ),
              );
            },
            httpHeaders: {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF06b6d4).withOpacity(0.2),
            const Color(0xFF06b6d4).withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 35,
        backgroundColor: Colors.transparent,
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF06b6d4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final providerAsync = ref.watch(currentProviderProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final todayBookingsAsync = ref.watch(todayBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: NotificationBadge(
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF06b6d4).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF06b6d4).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF06b6d4),
                    size: 20,
                  ),
                  onPressed: () => context.push('/notifications'),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF06b6d4).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF06b6d4).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF06b6d4),
                  size: 20,
                ),
              ),
              onPressed: () => context.push('/profile'),
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
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: RefreshIndicator(
          color: const Color(0xFF06b6d4),
          backgroundColor: const Color(0xFF1e293b),
          onRefresh: () async {
            ref.invalidate(currentProviderProvider);
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(todayBookingsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card with Avatar
                userAsync.when(
                  data: (user) => providerAsync.when(
                    data: (provider) => _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            _buildUserAvatar(context, user, provider),
                            const SizedBox(width: 20),
                            Expanded(
                                                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()},',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.fullName ?? 'Provider',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Provider Business Card
                providerAsync.when(
                  data: (provider) {
                    if (provider == null) {
                      return _GlassCard(
                        glowColor: const Color(0xFFfbbf24),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFfbbf24).withOpacity(0.2),
                                      const Color(0xFFfbbf24).withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.business,
                                  size: 48,
                                  color: Color(0xFFfbbf24),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Complete Your Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Set up your business information to start receiving bookings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _GlowButton(
                                onPressed: () => context.push('/onboarding'),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Setup Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.businessName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (provider.businessDescription != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                provider.businessDescription!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 20),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF06b6d4).withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatCard(
                                  icon: Icons.star,
                                  value: provider.rating.toStringAsFixed(1),
                                  label: 'Rating',
                                  color: const Color(0xFFfbbf24),
                                ),
                                _StatCard(
                                  icon: Icons.rate_review,
                                  value: '${provider.totalReviews}',
                                  label: 'Reviews',
                                  color: const Color(0xFF06b6d4),
                                ),
                                _StatCard(
                                  icon: Icons.calendar_today,
                                  value: '${provider.totalBookings}',
                                  label: 'Bookings',
                                  color: const Color(0xFF10b981),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 28),

                // Stats Overview
                statsAsync.when(
                  data: (stats) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickStatCard(
                              icon: Icons.inventory_2,
                              value: '${stats.totalServices}',
                              label: 'Services',
                              color: const Color(0xFF06b6d4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickStatCard(
                              icon: Icons.pending_actions,
                              value: '${stats.pendingBookings}',
                              label: 'Pending',
                              color: const Color(0xFFfbbf24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickStatCard(
                              icon: Icons.check_circle,
                              value: '${stats.confirmedBookings}',
                              label: 'Confirmed',
                              color: const Color(0xFF06b6d4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickStatCard(
                              icon: Icons.attach_money,
                              value: Formatters.currency(stats.totalEarnings),
                              label: 'Earned',
                              color: const Color(0xFF10b981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 28),
              
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  padding: EdgeInsets.zero,
                  children: [
                    _ActionCard(
                      icon: Icons.inventory_2,
                      label: 'Services',
                      color: const Color(0xFF06b6d4),
                      onTap: () => context.push('/services'),
                    ),
                    _ActionCard(
                      icon: Icons.calendar_month,
                      label: 'Bookings',
                      color: const Color(0xFF06b6d4),
                      onTap: () => context.push('/bookings'),
                    ),
                    _ActionCard(
                      icon: Icons.schedule,
                      label: 'Availability',
                      color: const Color(0xFF8b5cf6),
                      onTap: () => context.push('/availability'),
                    ),
                    _ActionCard(
                      icon: Icons.chat,
                      label: 'Messages',
                      color: const Color(0xFF10b981),
                      onTap: () => context.push('/chat'),
                    ),
                    _ActionCard(
                      icon: Icons.payments,
                      label: 'Earnings',
                      color: const Color(0xFF10b981),
                      onTap: () => context.push('/earnings'),
                    ),
                    _ActionCard(
                      icon: Icons.star,
                      label: 'Reviews',
                      color: const Color(0xFFfbbf24),
                      onTap: () => context.push('/reviews'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              
                // Today's Bookings
                const Text(
                  'Today\'s Bookings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              
                todayBookingsAsync.when(
                  data: (bookings) {
                    if (bookings.isEmpty) {
                      return _GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF06b6d4).withOpacity(0.2),
                                        const Color(0xFF06b6d4).withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.event_available,
                                    size: 48,
                                    color: const Color(0xFF06b6d4).withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No bookings for today',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  
                    return Column(
                      children: bookings.map((booking) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GlassCard(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatusColor(booking.status).withOpacity(0.3),
                                      _getStatusColor(booking.status).withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  _getStatusIcon(booking.status),
                                  color: _getStatusColor(booking.status),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                booking.service?.title ?? 'Service',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${booking.startTime} - ${booking.endTime}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatusColor(booking.status).withOpacity(0.3),
                                      _getStatusColor(booking.status).withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: _getStatusColor(booking.status).withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  booking.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(booking.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              onTap: () => context.push('/bookings/${booking.id}'),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                  error: (_, __) => _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ErrorView(
                        message: 'Failed to load today\'s bookings',
                        onRetry: () {
                          ref.invalidate(todayBookingsProvider);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFfbbf24);
      case 'confirmed':
        return const Color(0xFF06b6d4);
      case 'completed':
        return const Color(0xFF10b981);
      case 'cancelled':
        return const Color(0xFFef4444);
      default:
        return const Color(0xFF64748b);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;

  const _GlassCard({
    required this.child,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? const Color(0xFF06b6d4)).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      glowColor: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      glowColor: color,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _GlowButton({
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06b6d4).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06b6d4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}

