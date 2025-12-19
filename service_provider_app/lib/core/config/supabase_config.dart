// lib/core/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  static String? get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id;

  static const String storageImagesBucket = 'service-images';

  // Table names
  static const String usersTable = 'users';
  static const String providersTable = 'providers';
  static const String servicesTable = 'services';
  static const String bookingsTable = 'bookings';
  static const String bookingEventsTable = 'booking_events';
  static const String reviewsTable = 'reviews';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
  static const String notificationsTable = 'notifications';
  static const String availabilitySlotsTable = 'availability_slots';
  static const String paymentsTable = 'payments';
}
