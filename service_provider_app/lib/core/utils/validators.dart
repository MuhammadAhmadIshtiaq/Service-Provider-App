// lib/core/utils/validators.dart
import 'package:email_validator/email_validator.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  static String? duration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Duration is required';
    }
    final duration = int.tryParse(value);
    if (duration == null || duration <= 0) {
      return 'Please enter a valid duration';
    }
    return null;
  }

  static String? maxLength(String? value, int max, String fieldName) {
    if (value == null) return null;
    if (value.length > max) {
      return '$fieldName must be less than $max characters';
    }
    return null;
  }
}


