// ============================================
// lib/core/config/router_config.dart
// UPDATED with Notifications Route
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/services/services_list_screen.dart';
import '../../features/services/service_form_screen.dart';
import '../../features/bookings/bookings_list_screen.dart';
import '../../features/bookings/booking_details_screen.dart';
import '../../features/availability/availability_screen.dart';
import '../../features/chat/conversations_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/earnings/earnings_screen.dart';
import '../../features/reviews/reviews_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/notifications/notifications_screen.dart'; // 🆕 ADD THIS

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation == '/auth';

      // Allow splash always
      if (isSplash) return null;

      // If NOT logged in → redirect to Auth
      if (!isAuthenticated && !isAuth) {
        return '/auth';
      }

      // If logged in and currently on Auth → go to Dashboard
      if (isAuthenticated && isAuth) {
        return '/dashboard';
      }

      return null;
    },

    routes: [
      // --- SPLASH ROUTE ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // --- AUTH ---
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // --- ONBOARDING ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // --- DASHBOARD ---
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // --- SERVICES ---
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesListScreen(),
      ),
      GoRoute(
        path: '/services/add',
        builder: (context, state) => const ServiceFormScreen(),
      ),
      GoRoute(
        path: '/services/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ServiceFormScreen(serviceId: id);
        },
      ),

      // --- BOOKINGS ---
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const BookingsListScreen(),
      ),
      GoRoute(
        path: '/bookings/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookingDetailsScreen(bookingId: id);
        },
      ),

      // --- AVAILABILITY ---
      GoRoute(
        path: '/availability',
        builder: (context, state) => const AvailabilityScreen(),
      ),

      // --- CHAT ---
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),

      // --- EARNINGS ---
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const EarningsScreen(),
      ),

      // --- REVIEWS ---
      GoRoute(
        path: '/reviews',
        builder: (context, state) => const ReviewsScreen(),
      ),

      // --- PROFILE ---
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // 🆕 --- NOTIFICATIONS ---
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});



