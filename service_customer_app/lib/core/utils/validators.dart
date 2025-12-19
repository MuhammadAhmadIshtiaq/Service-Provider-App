import 'package:email_validator/email_validator.dart';
import '../config/app_constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and dashes
    final phoneNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (phoneNumber.length < 10) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Rating validation
  static String? validateRating(int? value) {
    if (value == null || value < 1 || value > 5) {
      return 'Please select a rating';
    }
    return null;
  }

  // Review comment validation
  static String? validateReviewComment(String? value) {
    if (value != null && value.length > AppConstants.maxReviewLength) {
      return 'Review must be less than ${AppConstants.maxReviewLength} characters';
    }
    return null;
  }
}