// ============================================
// lib/core/errors/app_exception.dart
// ============================================
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;

  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    // Convert error to string for checking
    final errorString = error.toString().toLowerCase();

    // Handle Supabase specific errors
    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid email or password')) {
      return 'Invalid email or password';
    }

    if (errorString.contains('email not confirmed')) {
      return 'Please verify your email address';
    }

    if (errorString.contains('user already registered') ||
        errorString.contains('already registered')) {
      return 'This email is already registered';
    }

    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Network error. Please check your connection';
    }

    if (errorString.contains('jwt expired') ||
        errorString.contains('token expired')) {
      return 'Your session has expired. Please login again';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again';
    }

    if (errorString.contains('not found')) {
      return 'Resource not found';
    }

    // Default error message
    return 'Something went wrong. Please try again';
  }
}

// Specific exception types
class AuthException extends AppException {
  AuthException(
    super.message, {
    super.code,
    super.originalException,
  });
}

class NetworkException extends AppException {
  NetworkException(
    super.message, {
    super.code,
    super.originalException,
  });
}

class ValidationException extends AppException {
  ValidationException(
    super.message, {
    super.code,
    super.originalException,
  });
}

class BookingException extends AppException {
  BookingException(
    super.message, {
    super.code,
    super.originalException,
  });
}

class NotFoundException extends AppException {
  NotFoundException(
    super.message, {
    super.code,
    super.originalException,
  });
}