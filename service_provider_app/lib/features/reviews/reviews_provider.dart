// lib/features/reviews/reviews_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/review_model.dart';
import '../auth/auth_provider.dart';

final reviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  final providerProfile = ref.watch(currentProviderProvider);
  
  return providerProfile.when(
    data: (provider) {
      if (provider == null) return Stream.value([]);
      
      return SupabaseConfig.client
          .from(SupabaseConfig.reviewsTable)
          .stream(primaryKey: ['id'])
          .eq('provider_id', provider.id)
          .order('created_at', ascending: false)
          .map((data) => data.map((json) => ReviewModel.fromJson(json)).toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});