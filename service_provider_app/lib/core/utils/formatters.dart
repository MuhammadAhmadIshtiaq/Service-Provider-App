// ============================================
// lib/core/utils/formatters.dart
// Enhanced version with minor improvements
// ============================================
import 'package:intl/intl.dart';

class Formatters {
  // ============================================
  // Currency Formatting
  // ============================================
  
  /// Format currency with symbol and decimal places
  static String currency(double amount, {String symbol = '\$', int decimals = 2}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: decimals);
    return formatter.format(amount);
  }
  
  /// Legacy currency formatter (kept for backward compatibility)
  static String formatCurrency(double amount) {
    return currency(amount);
  }

  // ============================================
  // Date Formatting
  // ============================================
  
  /// Format DateTime to date string (MMM dd, yyyy)
  static String date(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
  
  /// Legacy date formatter (kept for backward compatibility)
  static String formatDate(DateTime dateTime) {
    return date(dateTime);
  }
  
  /// Format DateTime to time string (hh:mm a)
  static String time(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
  
  /// Parse and format time string
  static String timeFromString(String timeString) {
    try {
      // Try parsing with seconds
      final time = DateFormat('HH:mm:ss').parse(timeString);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      try {
        // Try parsing without seconds
        final time = DateFormat('HH:mm').parse(timeString);
        return DateFormat('hh:mm a').format(time);
      } catch (e2) {
        return timeString; // Return original if parsing fails
      }
    }
  }
  
  /// Legacy time formatter (kept for backward compatibility)
  static String formatTime(DateTime dateTime) {
    return time(dateTime);
  }
  
  /// Format DateTime to date and time
  static String dateWithTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }
  
  /// Legacy date and time formatter (kept for backward compatibility)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  // ============================================
  // Relative Time Formatting
  // ============================================
  
  /// Format DateTime to relative time (e.g., "2 hours ago") - SHORT VERSION
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return DateFormat('MMM dd').format(dateTime);
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
  
  /// Format DateTime to detailed relative time (e.g., "2 hours ago") - DETAILED VERSION
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // ============================================
  // Duration Formatting
  // ============================================
  
  /// Format duration in minutes to readable string
  static String duration(int minutes) {
    if (minutes < 0) return '0 min';
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
    }
    return '$hours ${hours == 1 ? 'hr' : 'hrs'} $mins min';
  }
  
  /// Format duration in seconds to readable string
  static String durationFromSeconds(int seconds) {
    if (seconds < 0) return '0 sec';
    if (seconds < 60) {
      return '$seconds sec';
    }
    return duration((seconds / 60).floor());
  }

  // ============================================
  // Phone Number Formatting
  // ============================================
  
  /// Format phone number (basic formatting)
  static String phoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    
    // Remove any non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // Handle +1 country code
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }
    return phone; // Return original if doesn't match expected format
  }

  // ============================================
  // Number Formatting
  // ============================================
  
  /// Format large numbers with abbreviations (1000 -> 1K, 1000000 -> 1M)
  static String compactNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) {
      final k = (number / 1000).toStringAsFixed(1);
      return '${k.endsWith('.0') ? k.substring(0, k.length - 2) : k}K';
    }
    if (number < 1000000000) {
      final m = (number / 1000000).toStringAsFixed(1);
      return '${m.endsWith('.0') ? m.substring(0, m.length - 2) : m}M';
    }
    final b = (number / 1000000000).toStringAsFixed(1);
    return '${b.endsWith('.0') ? b.substring(0, b.length - 2) : b}B';
  }

  // ============================================
  // Percentage Formatting
  // ============================================
  
  /// Format decimal as percentage (0.75 -> 75%)
  static String percentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // ============================================
  // Text Formatting
  // ============================================
  
  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// Capitalize first letter of each word
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word.toLowerCase())).join(' ');
  }
  
  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

