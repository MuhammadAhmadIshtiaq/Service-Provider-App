// lib/core/errors/error_handler.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is AuthException) {
      return AuthFailure(_getAuthErrorMessage(error));
    } else if (error is PostgrestException) {
      return ServerFailure(error.message);
    } else if (error is StorageException) {
      return StorageFailure(error.message);
    } else {
      return ServerFailure('An unexpected error occurred: ${error.toString()}');
    }
  }

  static String _getAuthErrorMessage(AuthException error) {
    switch (error.statusCode) {
      case '400':
        return 'Invalid email or password';
      case '401':
        return 'Invalid credentials';
      case '422':
        return 'User already exists';
      case '429':
        return 'Too many requests. Please try again later';
      default:
        return error.message;
    }
  }

  static String getErrorMessage(Failure failure) {
    if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is StorageFailure) {
      return 'Storage error: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}