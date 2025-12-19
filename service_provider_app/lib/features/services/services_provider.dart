// lib/features/services/services_provider.dart
// SIMPLE WORKING VERSION

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/service_model.dart';
import '../auth/auth_provider.dart';

final servicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final providerProfile = ref.watch(currentProviderProvider);
  
  return providerProfile.when(
    data: (provider) {
      if (provider == null) return Stream.value([]);
      
      return SupabaseConfig.client
          .from(SupabaseConfig.servicesTable)
          .stream(primaryKey: ['id'])
          .eq('provider_id', provider.id)
          .order('created_at', ascending: false)
          .map((data) => data.map((json) => ServiceModel.fromJson(json)).toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class ServicesController extends StateNotifier<AsyncValue<void>> {
  ServicesController() : super(const AsyncValue.data(null));

  // SIMPLE UPLOAD METHOD
  Future<String?> uploadServiceImageSimple(File imageFile) async {
    try {
      print('🚀 === STARTING IMAGE UPLOAD ===');
      print('📁 File path: ${imageFile.path}');
      
      // 1. Check if file exists
      if (!await imageFile.exists()) {
        print('❌ File does not exist!');
        return null;
      }
      print('✅ File exists');
      
      // 2. Read file bytes
      final bytes = await imageFile.readAsBytes();
      print('✅ Read ${bytes.length} bytes');
      
      // 3. Check size
      if (bytes.length > 5 * 1024 * 1024) {
        print('❌ File too large: ${bytes.length} bytes');
        throw Exception('Image must be less than 5MB');
      }
      
      // 4. Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last.toLowerCase();
      final fileName = 'service_$timestamp.$extension';
      print('💾 Filename: $fileName');
      
      // 5. Upload to Supabase
      print('📤 Uploading to Supabase...');
      
      await Supabase.instance.client.storage
          .from('service-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$extension',
            ),
          );
      
      print('✅ Upload successful!');
      
      // 6. Get public URL
      final url = Supabase.instance.client.storage
          .from('service-images')
          .getPublicUrl(fileName);
      
      print('✅ URL: $url');
      print('🎉 === UPLOAD COMPLETE ===\n');
      
      return url;
      
    } on StorageException catch (e) {
      print('❌ Storage Exception: ${e.message}');
      print('   Status: ${e.statusCode}');
      print('   Error: ${e.error}');
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  Future<void> createService({
    required String providerId,
    required String title,
    required String description,
    required String category,
    required double price,
    required int durationMinutes,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      print('➕ Creating service: $title');
      
      await SupabaseConfig.client.from(SupabaseConfig.servicesTable).insert({
        'provider_id': providerId,
        'title': title,
        'description': description.isEmpty ? null : description,
        'category': category,
        'price': price,
        'duration_minutes': durationMinutes,
        'image_url': imageUrl,
        'is_active': true,
      });
      
      print('✅ Service created\n');
      state = const AsyncValue.data(null);
    } catch (e) {
      print('❌ Error creating service: $e\n');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateService({
    required String serviceId,
    required String title,
    required String description,
    required String category,
    required double price,
    required int durationMinutes,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      print('✏️ Updating service: $serviceId');
      
      await SupabaseConfig.client
          .from(SupabaseConfig.servicesTable)
          .update({
            'title': title,
            'description': description.isEmpty ? null : description,
            'category': category,
            'price': price,
            'duration_minutes': durationMinutes,
            'image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', serviceId);
      
      print('✅ Service updated\n');
      state = const AsyncValue.data(null);
    } catch (e) {
      print('❌ Error updating service: $e\n');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    state = const AsyncValue.loading();
    
    try {
      await SupabaseConfig.client
          .from(SupabaseConfig.servicesTable)
          .delete()
          .eq('id', serviceId);
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      await SupabaseConfig.client
          .from(SupabaseConfig.servicesTable)
          .update({'is_active': isActive})
          .eq('id', serviceId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

final servicesControllerProvider =
    StateNotifierProvider<ServicesController, AsyncValue<void>>((ref) {
  return ServicesController();
});

final serviceByIdProvider = FutureProvider.family<ServiceModel?, String>((ref, serviceId) async {
  final response = await SupabaseConfig.client
      .from(SupabaseConfig.servicesTable)
      .select()
      .eq('id', serviceId)
      .single();
  
  return ServiceModel.fromJson(response);
});