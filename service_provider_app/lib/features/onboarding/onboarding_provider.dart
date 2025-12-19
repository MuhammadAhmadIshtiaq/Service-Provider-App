import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/provider_model.dart';
import '../auth/auth_provider.dart';

class OnboardingController extends StateNotifier<AsyncValue<void>> {
  OnboardingController() : super(const AsyncValue.data(null));

  Future<void> createProviderProfile({
    required String userId,
    required String businessName,
    required String businessDescription,
    required String businessAddress,
    required String businessPhone,
    required List<String> serviceCategories,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await SupabaseConfig.client.from(SupabaseConfig.providersTable).insert({
        'user_id': userId,
        'business_name': businessName,
        'business_description': businessDescription,
        'business_address': businessAddress,
        'business_phone': businessPhone,
        'service_categories': serviceCategories,
      });
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, AsyncValue<void>>((ref) {
  return OnboardingController();
});