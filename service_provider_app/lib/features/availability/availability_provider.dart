// lib/features/availability/availability_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/availability_slot_model.dart';
import '../auth/auth_provider.dart';

final availabilitySlotsProvider = StreamProvider<List<AvailabilitySlotModel>>((ref) {
  final providerProfile = ref.watch(currentProviderProvider);
  
  return providerProfile.when(
    data: (provider) {
      if (provider == null) return Stream.value([]);
      
      return SupabaseConfig.client
          .from(SupabaseConfig.availabilitySlotsTable)
          .stream(primaryKey: ['id'])
          .eq('provider_id', provider.id)
          .order('day_of_week')
          .map((data) => data.map((json) => AvailabilitySlotModel.fromJson(json)).toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class AvailabilityController extends StateNotifier<AsyncValue<void>> {
  AvailabilityController() : super(const AsyncValue.data(null));

  Future<void> addSlot({
    required String providerId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await SupabaseConfig.client.from(SupabaseConfig.availabilitySlotsTable).insert({
        'provider_id': providerId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
      });
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteSlot(String slotId) async {
    try {
      await SupabaseConfig.client
          .from(SupabaseConfig.availabilitySlotsTable)
          .delete()
          .eq('id', slotId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final availabilityControllerProvider =
    StateNotifierProvider<AvailabilityController, AsyncValue<void>>((ref) {
  return AvailabilityController();
});