class AppConstants {
  // App Info
  static const String appName = 'Service Customer';
  static const String appVersion = '1.0.0';

  // User Types
  static const String userTypeCustomer = 'customer';
  static const String userTypeProvider = 'provider';

  // Booking Statuses
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusCancelled = 'cancelled';
  static const String bookingStatusCompleted = 'completed';

  // Booking Event Types
  static const String eventTypeCreated = 'created';
  static const String eventTypeConfirmed = 'confirmed';
  static const String eventTypeCancelled = 'cancelled';
  static const String eventTypeCompleted = 'completed';

  // Payment Statuses
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';

  // Notification Types
  static const String notificationTypeBookingUpdate = 'booking_update';
  static const String notificationTypeNewMessage = 'new_message';
  static const String notificationTypeReview = 'review';

  // Service Categories
  static const List<String> serviceCategories = [
    'Home Cleaning',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'AC Repair',
    'Pest Control',
    'Gardening',
    'Beauty & Wellness',
    'Tutoring',
    'Photography',
    'Catering',
    'Other',
  ];

  // Time Slots (24-hour format)
  static const List<String> timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
  ];

  // Pagination
  static const int itemsPerPage = 20;

  // Image
  static const int maxImageSizeMB = 5;
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';
  static const String defaultServiceImageUrl = 'https://via.placeholder.com/300x200';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxMessageLength = 1000;
  static const int maxReviewLength = 500;
}