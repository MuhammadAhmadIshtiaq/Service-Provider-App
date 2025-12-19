class AppConstants {
  // Service Categories
  static const List<String> serviceCategories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Carpentry',
    'Painting',
    'HVAC',
    'Landscaping',
    'Pest Control',
    'Moving',
    'Auto Repair',
    'Beauty & Wellness',
    'Fitness',
    'Tutoring',
    'Photography',
    'Event Planning',
    'Other',
  ];
  
  // Booking Status
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusCancelled = 'cancelled';
  static const String bookingStatusCompleted = 'completed';
  
  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';
  
  // Days of Week
  static const Map<int, String> daysOfWeek = {
    0: 'Sunday',
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
  };
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxServiceTitleLength = 100;
  static const int maxServiceDescriptionLength = 500;
  static const int maxBusinessNameLength = 100;
  static const int maxBusinessDescriptionLength = 1000;
  
  // Image Upload
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  
  // Pagination
  static const int defaultPageSize = 20;
}