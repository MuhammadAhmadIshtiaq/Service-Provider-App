// lib/features/bookings/bookings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/booking_model.dart';
import '../auth/auth_provider.dart';

final bookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final provider = await ref.watch(currentProviderProvider.future);
  if (provider == null) return [];
  
  final response = await SupabaseConfig.client
      .from(SupabaseConfig.bookingsTable)
      .select('''
        *,
        services(*),
        customer:customer_id(id, email, full_name, phone, avatar_url, user_type, created_at, updated_at)
      ''')
      .eq('provider_id', provider.id)
      .order('booking_date', ascending: false);
  
  return response.map((json) => BookingModel.fromJson(json)).toList();
});

// Auto-refresh trigger for live updates (optional - remove if you don't want auto-refresh)
final _refreshTriggerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (count) => count);
});

// Live bookings that auto-refresh (optional - use this if you want auto-refresh)
final liveBookingsProvider = Provider<AsyncValue<List<BookingModel>>>((ref) {
  // Watch the refresh trigger to invalidate every 30 seconds
  ref.watch(_refreshTriggerProvider);
  return ref.watch(bookingsProvider);
});

// Manual refresh method
void refreshBookings(WidgetRef ref) {
  ref.invalidate(bookingsProvider);
  ref.invalidate(todayBookingsProvider);
}

final todayBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final provider = await ref.watch(currentProviderProvider.future);
  if (provider == null) return [];
  
  final today = DateTime.now().toIso8601String().split('T')[0];
  
  final response = await SupabaseConfig.client
      .from(SupabaseConfig.bookingsTable)
      .select('''
        *,
        services(*),
        customer:customer_id(id, email, full_name, phone, avatar_url, user_type, created_at, updated_at)
      ''')
      .eq('provider_id', provider.id)
      .eq('booking_date', today)
      .order('start_time');
  
  return response.map((json) => BookingModel.fromJson(json)).toList();
});

final bookingByIdProvider = FutureProvider.family<BookingModel?, String>((ref, bookingId) async {
  final response = await SupabaseConfig.client
      .from(SupabaseConfig.bookingsTable)
      .select('''
        *,
        services(*),
        customer:customer_id(id, email, full_name, phone, avatar_url, user_type, created_at, updated_at)
      ''')
      .eq('id', bookingId)
      .maybeSingle();
  
  if (response == null) return null;
  return BookingModel.fromJson(response);
});

class BookingsController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  
  BookingsController(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateBookingStatus(String bookingId, String status, String? reason) async {
    state = const AsyncValue.loading();
    
    try {
      await SupabaseConfig.client
          .from(SupabaseConfig.bookingsTable)
          .update({
            'status': status,
            if (status == 'cancelled') 'cancellation_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
      
      // Invalidate bookings to refresh the list
      ref.invalidate(bookingsProvider);
      ref.invalidate(todayBookingsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
  
  Future<void> refreshBookings() async {
    ref.invalidate(bookingsProvider);
    ref.invalidate(todayBookingsProvider);
  }
}

final bookingsControllerProvider =
    StateNotifierProvider<BookingsController, AsyncValue<void>>((ref) {
  return BookingsController(ref);
});











