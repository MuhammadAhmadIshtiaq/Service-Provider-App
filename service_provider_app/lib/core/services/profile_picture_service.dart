// ============================================
// UPDATED: lib/core/services/profile_picture_service.dart
// Supports both users (avatar_url) and providers (business_logo_url)
// ============================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../errors/app_exception.dart' hide AuthException;

enum ProfileType {
  user,      // Uses users.avatar_url
  provider,  // Uses providers.business_logo_url
}

class ProfilePictureService {
  static final _supabase = SupabaseConfig.client;
  static final _picker = ImagePicker();
  static const String _bucketName = 'avatars';

  /// Pick image from gallery or camera
  static Future<File?> pickImage({
    required ImageSource source,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw AppException('Failed to pick image: ${e.toString()}');
    }
  }

  /// Resize image to specified dimensions
  static Future<Uint8List> resizeImage(
    File imageFile, {
    int maxWidth = 512,
    int maxHeight = 512,
  }) async {
    try {
      print('📸 Resizing image...');

      // Read image file
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw AppException('Failed to decode image');
      }

      print('   Original size: ${image.width}x${image.height}');

      // Calculate new dimensions maintaining aspect ratio
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxWidth || image.height > maxHeight) {
        final aspectRatio = image.width / image.height;

        if (aspectRatio > 1) {
          // Landscape
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          // Portrait
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      print('   New size: ${newWidth}x${newHeight}');

      // Resize image
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode as JPEG with compression
      final resizedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: 85),
      );

      print('   Original: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
      print('   Resized: ${(resizedBytes.length / 1024).toStringAsFixed(2)} KB');
      print('✅ Image resized successfully');

      return resizedBytes;
    } catch (e) {
      print('❌ Error resizing image: $e');
      throw AppException('Failed to resize image: ${e.toString()}');
    }
  }

  /// Get the file path for avatar/logo
  static String _getAvatarPath(String userId) {
    return '$userId/avatar.jpg';
  }

  /// Upload avatar/logo to Supabase Storage
  static Future<String> uploadAvatar(
    File imageFile, {
    ProfileType profileType = ProfileType.user,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      print('📤 Uploading ${profileType.name} image for user: $userId');

      // Resize image first
      final resizedBytes = await resizeImage(imageFile);

      // Generate filename: {user_id}/avatar.jpg
      final filePath = _getAvatarPath(userId);

      print('   Uploading to: $_bucketName/$filePath');

      // CRITICAL: Delete old image first
      try {
        final files = await _supabase.storage
            .from(_bucketName)
            .list(path: userId);
        
        if (files.isNotEmpty) {
          print('   Found ${files.length} existing file(s), deleting...');
          
          await _supabase.storage
              .from(_bucketName)
              .remove([filePath]);
          
          print('   ✓ Deleted old image');
          
          // Wait for deletion to complete
          await Future.delayed(const Duration(milliseconds: 800));
        } else {
          print('   ℹ️ No existing files (first upload)');
        }
      } catch (e) {
        print('   ⚠️ Delete operation: $e');
        // Continue anyway - might be first upload
      }

      // Upload to Supabase Storage with upsert=true
      try {
        await _supabase.storage
            .from(_bucketName)
            .uploadBinary(
              filePath,
              resizedBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                cacheControl: '0', // Disable caching
                upsert: true,
              ),
            );
        
        print('✅ Image uploaded successfully');
      } catch (uploadError) {
        print('❌ Upload failed: $uploadError');
        throw AppException('Failed to upload: ${uploadError.toString()}');
      }

      // Get public URL (clean, no timestamp)
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('   Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Error in uploadAvatar: $e');
      rethrow;
    }
  }

  /// Delete avatar/logo from Supabase Storage and update database
  static Future<void> deleteAvatar({
    ProfileType profileType = ProfileType.user,
    String? providerId, // Required for provider type
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      print('🗑️ Deleting ${profileType.name} image for user: $userId');

      final filePath = _getAvatarPath(userId);

      // Delete from storage
      try {
        await _supabase.storage
            .from(_bucketName)
            .remove([filePath]);
        print('✅ Image deleted from storage');
      } catch (e) {
        print('⚠️ Storage delete: $e (file may not exist)');
      }

      // Update database based on profile type
      if (profileType == ProfileType.user) {
        // Update users table - avatar_url
        await _supabase.from('users').update({
          'avatar_url': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        
        print('✅ User avatar_url set to null');
      } else {
        // Update providers table - business_logo_url
        if (providerId == null) {
          throw AppException('Provider ID is required for provider profile');
        }
        
        await _supabase.from(SupabaseConfig.providersTable).update({
          'business_logo_url': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', providerId);
        
        print('✅ Provider business_logo_url set to null');
      }
    } catch (e) {
      print('❌ Error deleting avatar: $e');
      rethrow;
    }
  }

  /// Update profile with new avatar/logo URL in database
  static Future<void> updateProfileAvatar(
    String avatarUrl, {
    ProfileType profileType = ProfileType.user,
    String? providerId, // Required for provider type
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw AuthException('Not authenticated');
      }

      print('💾 Updating ${profileType.name} profile with new image URL');

      // Store clean URL in database (no query params)
      final cleanUrl = avatarUrl.split('?')[0];

      if (profileType == ProfileType.user) {
        // Update users table - avatar_url
        await _supabase.from('users').update({
          'avatar_url': cleanUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        
        print('✅ User avatar_url updated: $cleanUrl');
      } else {
        // Update providers table - business_logo_url
        if (providerId == null) {
          throw AppException('Provider ID is required for provider profile');
        }
        
        await _supabase.from(SupabaseConfig.providersTable).update({
          'business_logo_url': cleanUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', providerId);
        
        print('✅ Provider business_logo_url updated: $cleanUrl');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  /// Complete flow: Pick, resize, upload, and update profile
  /// Returns the clean avatar/logo URL (no timestamp)
  static Future<String> pickAndUploadAvatar({
    required ImageSource source,
    ProfileType profileType = ProfileType.user,
    String? providerId, // Required for provider type
  }) async {
    print('🚀 Starting ${profileType.name} image upload flow...');
    
    // Pick image
    final imageFile = await pickImage(source: source);
    if (imageFile == null) {
      throw AppException('No image selected');
    }

    // Upload (includes resize and deletion of old image)
    final avatarUrl = await uploadAvatar(imageFile, profileType: profileType);

    // Update profile in database
    await updateProfileAvatar(
      avatarUrl,
      profileType: profileType,
      providerId: providerId,
    );

    print('✅ ${profileType.name} image upload flow completed successfully');

    // Return clean URL
    return avatarUrl;
  }
}