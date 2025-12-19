import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/service_model.dart';
import '../../core/models/provider_model.dart';
import '../../core/errors/app_exception.dart';

class ServicesState {
  final List<ServiceModel> services;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String? searchQuery;

  ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchQuery,
  });

  ServicesState copyWith({
    List<ServiceModel>? services,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ServicesNotifier extends StateNotifier<ServicesState> {
  ServicesNotifier() : super(ServicesState()) {
    loadServices();
  }

  final _supabase = SupabaseConfig.client;

  Future<void> loadServices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      var query = _supabase
          .from('services')
          .select('*, providers(*)')
          .eq('is_active', true);

      // Apply category filter
      if (state.selectedCategory != null) {
        query = query.eq('category', state.selectedCategory!);
      }

      // Apply search filter
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        query = query.or(
          'title.ilike.%${state.searchQuery}%,description.ilike.%${state.searchQuery}%',
        );
      }

      final response = await query.order('created_at', ascending: false);

      final services = (response as List)
          .map((json) => ServiceModel.fromJson(json))
          .toList();

      state = state.copyWith(services: services, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadServices();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadServices();
  }

  Future<ProviderModel> getProviderDetails(String providerId) async {
    try {
      final response = await _supabase
          .from('providers')
          .select()
          .eq('id', providerId)
          .single();

      return ProviderModel.fromJson(response);
    } catch (e) {
      throw AppException(AppException.getErrorMessage(e));
    }
  }
}

final servicesProvider =
    StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  return ServicesNotifier();
});