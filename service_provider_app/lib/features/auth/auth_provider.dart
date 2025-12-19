// lib/features/auth/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/user_model.dart';
import '../../core/models/provider_model.dart';
import '../../core/errors/failures.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange.map((data) => data.session?.user);
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  
  if (authState == null) return null;
  
  final response = await SupabaseConfig.client
      .from(SupabaseConfig.usersTable)
      .select()
      .eq('id', authState.id)
      .single();
  
  return UserModel.fromJson(response);
});

// Current provider profile
final currentProviderProvider = FutureProvider<ProviderModel?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  
  if (user == null || user.userType != 'provider') return null;
  
  try {
    final response = await SupabaseConfig.client
        .from(SupabaseConfig.providersTable)
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    
    if (response == null) return null;
    return ProviderModel.fromJson(response);
  } catch (e) {
    return null;
  }
});

// Auth controller
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      final failure = e is AuthException ? AuthFailure(e.message) : ServerFailure(e.toString());
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = const AsyncValue.loading();
    
    try {
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (authResponse.user != null) {
        await SupabaseConfig.client.from(SupabaseConfig.usersTable).insert({
          'id': authResponse.user!.id,
          'email': email,
          'full_name': fullName,
          'user_type': 'provider',
        });
      }
      
      state = const AsyncValue.data(null);
    } catch (e) {
      final failure = e is AuthException ? AuthFailure(e.message) : ServerFailure(e.toString());
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      await SupabaseConfig.client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(ServerFailure(e.toString()), StackTrace.current);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    
    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);
      state = const AsyncValue.data(null);
    } catch (e) {
      final failure = e is AuthException ? AuthFailure(e.message) : ServerFailure(e.toString());
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});
