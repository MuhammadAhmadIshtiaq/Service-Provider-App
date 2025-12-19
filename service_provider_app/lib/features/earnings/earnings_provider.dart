// lib/features/earnings/earnings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../auth/auth_provider.dart';

final earningsStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final provider = await ref.watch(currentProviderProvider.future);
  if (provider == null) return {};

  final response = await SupabaseConfig.client
      .from(SupabaseConfig.bookingsTable)
      .select('total_price, status')
      .eq('provider_id', provider.id);

  double totalEarnings = 0;
  double pendingEarnings = 0;
  int completedBookings = 0;

  for (final booking in response) {
    final price = (booking['total_price'] as num).toDouble();
    if (booking['status'] == 'completed') {
      totalEarnings += price;
      completedBookings++;
    } else if (booking['status'] == 'confirmed') {
      pendingEarnings += price;
    }
  }

  return {
    'totalEarnings': totalEarnings,
    'pendingEarnings': pendingEarnings,
    'completedBookings': completedBookings,
  };
});
