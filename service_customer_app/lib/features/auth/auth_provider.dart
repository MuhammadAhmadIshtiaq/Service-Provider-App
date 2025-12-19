import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/config/app_constants.dart';
import '../../core/models/user_model.dart';
import '../../core/errors/app_exception.dart' hide AuthException;

// Auth state
class AuthState {
  final User? authUser;
  final UserModel? userProfile;
  final bool isLoading;
  final String? error;

  AuthState({
    this.authUser,
    this.userProfile,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? authUser,
    UserModel? userProfile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => authUser != null && userProfile != null;
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  final _supabase = SupabaseConfig.client;

  void _init() {
    print('🔐 Initializing auth state...');
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        print('🔐 Auth state changed, user logged in');
        _loadUserProfile(session.user.id);
      } else {
        print('🔐 Auth state changed, user logged out');
        state = AuthState();
      }
    });

    // Check current session
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      print('🔐 Current user found: ${currentUser.id}');
      _loadUserProfile(currentUser.id);
    } else {
      print('🔐 No current user');
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile(String userId) async {
    try {
      print('📥 Loading user profile for: $userId');
      
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      final userProfile = UserModel.fromJson(response);
      
      print('✅ User profile loaded successfully');
      print('   Name: ${userProfile.fullName}');
      print('   Email: ${userProfile.email}');
      print('   Avatar URL: ${userProfile.avatarUrl ?? "null"}');
      
      state = state.copyWith(
        authUser: _supabase.auth.currentUser,
        userProfile: userProfile,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      print('❌ Error loading user profile: $e');
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  // Public method to refresh profile (used after avatar upload/delete)
  Future<void> refreshProfile() async {
    final userId = state.authUser?.id;
    if (userId != null) {
      print('🔄 Manually refreshing profile...');
      await _loadUserProfile(userId);
    } else {
      print('⚠️ Cannot refresh profile - no user logged in');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      print('📝 Signing up user: $email');
      state = state.copyWith(isLoading: true, error: null);

      // Sign up with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw AuthException('Failed to create account');
      }

      print('✅ Auth account created');

      // Create user profile
      await _supabase.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'user_type': AppConstants.userTypeCustomer,
      });

      print('✅ User profile created');

      await _loadUserProfile(authResponse.user!.id);
    } catch (e) {
      print('❌ Sign up error: $e');
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔑 Signing in user: $email');
      state = state.copyWith(isLoading: true, error: null);

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw AuthException('Failed to sign in');
      }

      print('✅ Sign in successful');

      await _loadUserProfile(authResponse.user!.id);
    } catch (e) {
      print('❌ Sign in error: $e');
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      print('👋 Signing out...');
      await _supabase.auth.signOut();
      state = AuthState();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Sign out error: $e');
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
      );
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      print('💾 Updating profile...');
      print('   Full Name: $fullName');
      print('   Phone: $phone');
      
      state = state.copyWith(isLoading: true, error: null);

      final userId = state.authUser?.id;
      if (userId == null) throw AuthException('Not authenticated');

      await _supabase.from('users').update({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      print('✅ Profile updated in database');

      await _loadUserProfile(userId);
    } catch (e) {
      print('❌ Update profile error: $e');
      state = state.copyWith(
        error: AppException.getErrorMessage(e),
        isLoading: false,
      );
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});