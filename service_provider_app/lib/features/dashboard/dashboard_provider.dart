// lib/features/dashboard/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../auth/auth_provider.dart';

class DashboardStats {
  final int totalServices;
  final int totalBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int completedBookings;
  final double totalEarnings;
  final double rating;
  final int totalReviews;

  DashboardStats({
    this.totalServices = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.confirmedBookings = 0,
    this.completedBookings = 0,
    this.totalEarnings = 0.0,
    this.rating = 0.0,
    this.totalReviews = 0,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final provider = await ref.watch(currentProviderProvider.future);
  if (provider == null) return DashboardStats();

  try {
    // Get services count
    final servicesResponse = await SupabaseConfig.client
        .from(SupabaseConfig.servicesTable)
        .select('id')
        .eq('provider_id', provider.id);
    
    final totalServices = servicesResponse.length;

    // Get bookings stats
    final bookingsResponse = await SupabaseConfig.client
        .from(SupabaseConfig.bookingsTable)
        .select('status, total_price')
        .eq('provider_id', provider.id);

    int totalBookings = bookingsResponse.length;
    int pendingBookings = 0;
    int confirmedBookings = 0;
    int completedBookings = 0;
    double totalEarnings = 0.0;

    for (final booking in bookingsResponse) {
      final status = booking['status'] as String;
      final price = (booking['total_price'] as num).toDouble();

      switch (status) {
        case 'pending':
          pendingBookings++;
          break;
        case 'confirmed':
          confirmedBookings++;
          break;
        case 'completed':
          completedBookings++;
          totalEarnings += price;
          break;
      }
    }

    return DashboardStats(
      totalServices: totalServices,
      totalBookings: totalBookings,
      pendingBookings: pendingBookings,
      confirmedBookings: confirmedBookings,
      completedBookings: completedBookings,
      totalEarnings: totalEarnings,
      rating: provider.rating,
      totalReviews: provider.totalReviews,
    );
  } catch (e) {
    return DashboardStats();
  }
});