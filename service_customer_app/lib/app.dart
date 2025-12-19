import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/models/service_model.dart';
import 'core/models/provider_model.dart';
import 'core/models/booking_model.dart';
import 'features/auth/auth_provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/home/home_screen.dart';
import 'features/services/services_list_screen.dart';
import 'features/services/service_details_screen.dart';
import 'features/services/provider_profile_screen.dart';
import 'features/bookings/booking_flow_screen.dart';
import 'features/bookings/bookings_list_screen.dart';
import 'features/bookings/booking_details_screen.dart';
import 'features/chat/conversations_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/reviews/write_review_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/support/help_support_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/change_password_screen.dart'; // NEW IMPORT

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isOnSplash = state.matchedLocation == '/';
      final isOnAuth = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/signup';
      
      // Show splash while checking authentication status
      if (authState.isLoading) {
        return isOnSplash ? null : '/';
      }

      final isAuthenticated = authState.isAuthenticated;

      // If authenticated and on splash/auth screens, go to home
      if (isAuthenticated && (isOnSplash || isOnAuth)) {
        return '/home';
      }

      // If not authenticated and not on auth screens, go to login
      if (!isAuthenticated && !isOnAuth && !isOnSplash) {
        return '/login';
      }

      return null;
    },
    routes: [
      // ================================================
      // SPLASH ROUTE
      // ================================================
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ================================================
      // AUTH ROUTES
      // ================================================
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ================================================
      // HOME ROUTE
      // ================================================
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ================================================
      // SERVICES ROUTES
      // ================================================
      GoRoute(
        path: '/services',
        name: 'services',
        builder: (context, state) => const ServicesListScreen(),
      ),
      GoRoute(
        path: '/service-details/:serviceId',
        name: 'service-details',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return ServiceDetailsScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/provider-profile/:providerId',
        name: 'provider-profile',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return ProviderProfileScreen(providerId: providerId);
        },
      ),

      // ================================================
      // BOOKINGS ROUTES
      // ================================================
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const BookingsListScreen(),
      ),
      GoRoute(
        path: '/booking-flow',
        name: 'booking-flow',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingFlowScreen(
            service: extra['service'] as ServiceModel,
            provider: extra['provider'] as ProviderModel,
          );
        },
      ),
      GoRoute(
        path: '/booking-details/:bookingId',
        name: 'booking-details',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingDetailsScreen(bookingId: bookingId);
        },
      ),

      // ================================================
      // CHAT ROUTES
      // ================================================
      GoRoute(
        path: '/chat',
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:providerId',
        name: 'chat-screen',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return ChatScreen(providerId: providerId);
        },
      ),

      // ================================================
      // REVIEWS ROUTES
      // ================================================
      GoRoute(
        path: '/write-review/:bookingId',
        name: 'write-review-id',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return WriteReviewScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/write-review',
        name: 'write-review',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WriteReviewScreen(
            bookingId: (extra['booking'] as BookingModel).id,
          );
        },
      ),

      // ================================================
      // NOTIFICATIONS ROUTE
      // ================================================
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // ================================================
      // PROFILE & SETTINGS ROUTES
      // ================================================
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/help-support',
        name: 'help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // NEW ROUTE: Change Password
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],

    // ================================================
    // ERROR HANDLING
    // ================================================
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
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Service Customer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'core/theme/app_theme.dart';
// import 'core/models/service_model.dart';
// import 'core/models/provider_model.dart';
// import 'core/models/booking_model.dart';
// import 'features/auth/auth_provider.dart';
// import 'features/splash/splash_screen.dart';
// import 'features/auth/login_screen.dart';
// import 'features/auth/signup_screen.dart';
// import 'features/home/home_screen.dart';
// import 'features/services/services_list_screen.dart';
// import 'features/services/service_details_screen.dart';
// import 'features/services/provider_profile_screen.dart';
// import 'features/bookings/booking_flow_screen.dart';
// import 'features/bookings/bookings_list_screen.dart';
// import 'features/bookings/booking_details_screen.dart';
// import 'features/chat/conversations_screen.dart';
// import 'features/chat/chat_screen.dart';
// import 'features/reviews/write_review_screen.dart';
// import 'features/notifications/notifications_screen.dart';
// import 'features/profile/profile_screen.dart';
// import 'features/profile/edit_profile_screen.dart';
// import 'features/support/help_support_screen.dart';
// import 'features/settings/settings_screen.dart';

// final routerProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authProvider);

//   return GoRouter(
//     initialLocation: '/',
//     redirect: (context, state) {
//       final isOnSplash = state.matchedLocation == '/';
//       final isOnAuth = state.matchedLocation == '/login' || 
//                        state.matchedLocation == '/signup';
      
//       // Show splash while checking authentication status
//       if (authState.isLoading) {
//         return isOnSplash ? null : '/';
//       }

//       final isAuthenticated = authState.isAuthenticated;

//       // If authenticated and on splash/auth screens, go to home
//       if (isAuthenticated && (isOnSplash || isOnAuth)) {
//         return '/home';
//       }

//       // If not authenticated and not on auth screens, go to login
//       if (!isAuthenticated && !isOnAuth && !isOnSplash) {
//         return '/login';
//       }

//       return null;
//     },
//     routes: [
//       // ================================================
//       // SPLASH ROUTE
//       // ================================================
//       GoRoute(
//         path: '/',
//         name: 'splash',
//         builder: (context, state) => const SplashScreen(),
//       ),

//       // ================================================
//       // AUTH ROUTES
//       // ================================================
//       GoRoute(
//         path: '/login',
//         name: 'login',
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: '/signup',
//         name: 'signup',
//         builder: (context, state) => const SignupScreen(),
//       ),

//       // ================================================
//       // HOME ROUTE
//       // ================================================
//       GoRoute(
//         path: '/home',
//         name: 'home',
//         builder: (context, state) => const HomeScreen(),
//       ),

//       // ================================================
//       // SERVICES ROUTES
//       // ================================================
//       GoRoute(
//         path: '/services',
//         name: 'services',
//         builder: (context, state) => const ServicesListScreen(),
//       ),
//       GoRoute(
//         path: '/service-details/:serviceId',
//         name: 'service-details',
//         builder: (context, state) {
//           final serviceId = state.pathParameters['serviceId']!;
//           return ServiceDetailsScreen(serviceId: serviceId);
//         },
//       ),
//       GoRoute(
//         path: '/provider-profile/:providerId',
//         name: 'provider-profile',
//         builder: (context, state) {
//           final providerId = state.pathParameters['providerId']!;
//           return ProviderProfileScreen(providerId: providerId);
//         },
//       ),

//       // ================================================
//       // BOOKINGS ROUTES
//       // ================================================
//       GoRoute(
//         path: '/bookings',
//         name: 'bookings',
//         builder: (context, state) => const BookingsListScreen(),
//       ),
//       GoRoute(
//         path: '/booking-flow',
//         name: 'booking-flow',
//         builder: (context, state) {
//           final extra = state.extra as Map<String, dynamic>;
//           return BookingFlowScreen(
//             service: extra['service'] as ServiceModel,
//             provider: extra['provider'] as ProviderModel,
//           );
//         },
//       ),
//       GoRoute(
//         path: '/booking-details/:bookingId',
//         name: 'booking-details',
//         builder: (context, state) {
//           final bookingId = state.pathParameters['bookingId']!;
//           return BookingDetailsScreen(bookingId: bookingId);
//         },
//       ),

//       // ================================================
//       // CHAT ROUTES
//       // ================================================
//       GoRoute(
//         path: '/chat',
//         name: 'conversations',
//         builder: (context, state) => const ConversationsScreen(),
//       ),
//       GoRoute(
//         path: '/chat/:providerId',
//         name: 'chat-screen',
//         builder: (context, state) {
//           final providerId = state.pathParameters['providerId']!;
//           return ChatScreen(providerId: providerId);
//         },
//       ),

//       // ================================================
//       // REVIEWS ROUTES
//       // ================================================
//       GoRoute(
//         path: '/write-review/:bookingId',
//         name: 'write-review-id',
//         builder: (context, state) {
//           final bookingId = state.pathParameters['bookingId']!;
//           return WriteReviewScreen(bookingId: bookingId);
//         },
//       ),
//       GoRoute(
//         path: '/write-review',
//         name: 'write-review',
//         builder: (context, state) {
//           final extra = state.extra as Map<String, dynamic>;
//           return WriteReviewScreen(
//             bookingId: (extra['booking'] as BookingModel).id,
//           );
//         },
//       ),

//       // ================================================
//       // NOTIFICATIONS ROUTE
//       // ================================================
//       GoRoute(
//         path: '/notifications',
//         name: 'notifications',
//         builder: (context, state) => const NotificationsScreen(),
//       ),

//       // ================================================
//       // PROFILE & SETTINGS ROUTES
//       // ================================================
//       GoRoute(
//         path: '/profile',
//         name: 'profile',
//         builder: (context, state) => const ProfileScreen(),
//       ),
//       GoRoute(
//         path: '/edit-profile',
//         name: 'edit-profile',
//         builder: (context, state) => const EditProfileScreen(),
//       ),
//       GoRoute(
//         path: '/help-support',
//         name: 'help-support',
//         builder: (context, state) => const HelpSupportScreen(),
//       ),
//       GoRoute(
//         path: '/settings',
//         name: 'settings',
//         builder: (context, state) => const SettingsScreen(),
//       ),
//     ],

//     // ================================================
//     // ERROR HANDLING
//     // ================================================
//     errorBuilder: (context, state) => Scaffold(
//       appBar: AppBar(
//         title: const Text('Error'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Page not found',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               state.uri.toString(),
//               style: TextStyle(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => context.go('/home'),
//               child: const Text('Go Home'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// });

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(routerProvider);

//     return MaterialApp.router(
//       title: 'Service Customer',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       routerConfig: router,
//     );
//   }
// }



