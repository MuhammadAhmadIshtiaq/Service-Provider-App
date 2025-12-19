// ============================================
// FIX 3: Add auto-conversation creation after booking
// ============================================
// File: lib/features/bookings/bookings_provider.dart
// Update the createBooking method

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/config/app_constants.dart';
import '../../core/models/booking_model.dart';
import '../../core/errors/app_exception.dart';
import '../chat/chat_provider.dart';

class BookingsState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? error;

  BookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingsState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<BookingModel> get upcomingBookings => bookings
      .where((b) =>
          (b.isPending || b.isConfirmed) &&
          b.bookingDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
      .toList();

  List<BookingModel> get pastBookings => bookings
      .where((b) =>
          b.isCompleted ||
          (b.bookingDate.isBefore(DateTime.now()) && !b.isCancelled))
      .toList();

  List<BookingModel> get cancelledBookings =>
      bookings.where((b) => b.isCancelled).toList();
}

class BookingsNotifier extends StateNotifier<BookingsState> {
  BookingsNotifier(this.ref) : super(BookingsState());

  final Ref ref;
  final _supabase = SupabaseConfig.client;

  Future<void> loadBookings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      final response = await _supabase
          .from('bookings')
          .select('*, providers(*), services(*)')
          .eq('customer_id', userId)
          .order('booking_date', ascending: false);

      final bookings = (response as List)
          .map((json) => BookingModel.fromJson(json))
          .toList();

      state = state.copyWith(bookings: bookings, isLoading: false);

      // Setup realtime subscription
      _subscribeToBookingUpdates(userId);
    } catch (e) {
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  void _subscribeToBookingUpdates(String userId) {
    _supabase
        .from('bookings:customer_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen((data) {
          final bookings = data.map((json) => BookingModel.fromJson(json)).toList();
          state = state.copyWith(bookings: bookings);
        });
  }

  Future<void> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
    required double totalPrice,
    String? customerNotes,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      print('📝 Creating booking...');

      // Create booking
      final booking = await _supabase.from('bookings').insert({
        'customer_id': userId,
        'provider_id': providerId,
        'service_id': serviceId,
        'booking_date': bookingDate.toIso8601String().split('T')[0],
        'start_time': startTime,
        'end_time': endTime,
        'total_price': totalPrice,
        'status': AppConstants.bookingStatusPending,
        'customer_notes': customerNotes,
      }).select().single();

      print('✅ Booking created: ${booking['id']}');

      // Create booking event
      await _supabase.from('booking_events').insert({
        'booking_id': booking['id'],
        'event_type': AppConstants.eventTypeCreated,
        'triggered_by': userId,
      });

      print('✅ Booking event created');

      // 🔥 NEW: Auto-create conversation with provider
      try {
        print('💬 Auto-creating conversation with provider...');
        await ref
            .read(chatProvider.notifier)
            .getOrCreateConversation(providerId);
        print('✅ Conversation created/verified');
      } catch (e) {
        // Don't fail the booking if conversation creation fails
        print('⚠️ Could not create conversation (non-critical): $e');
      }

      await loadBookings();
    } catch (e) {
      print('❌ Error creating booking: $e');
      throw BookingException(AppException.getErrorMessage(e));
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      // Update booking status
      await _supabase.from('bookings').update({
        'status': AppConstants.bookingStatusCancelled,
        'cancellation_reason': reason,
      }).eq('id', bookingId);

      // Create booking event
      await _supabase.from('booking_events').insert({
        'booking_id': bookingId,
        'event_type': AppConstants.eventTypeCancelled,
        'triggered_by': userId,
        'notes': reason,
      });

      await loadBookings();
    } catch (e) {
      throw BookingException(AppException.getErrorMessage(e));
    }
  }
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, BookingsState>((ref) {
  return BookingsNotifier(ref)..loadBookings();
});