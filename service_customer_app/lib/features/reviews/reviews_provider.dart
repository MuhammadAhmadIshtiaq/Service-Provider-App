// ============================================
// FILE 1: lib/features/reviews/reviews_provider.dart
// ============================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/errors/app_exception.dart';

class ReviewsNotifier extends StateNotifier<AsyncValue<void>> {
  ReviewsNotifier() : super(const AsyncValue.data(null));

  final _supabase = SupabaseConfig.client;

  Future<void> createReview({
    required String bookingId,
    required String providerId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      await _supabase.from('reviews').insert({
        'booking_id': bookingId,
        'customer_id': userId,
        'provider_id': providerId,
        'rating': rating,
        'comment': comment,
      });

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(AppException.getErrorMessage(e), stack);
      rethrow;
    }
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, AsyncValue<void>>((ref) {
  return ReviewsNotifier();
});