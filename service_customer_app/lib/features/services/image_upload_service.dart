import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:service_customer_app/core/config/supabase_config.dart';
import 'package:service_customer_app/core/errors/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  final _supabase = SupabaseConfig.client;
  final _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw AppException('Failed to pick image: ${e.toString()}');
    }
  }

  /// Compress image to reduce file size
  Future<Uint8List> compressImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: 85,
        format: CompressFormat.jpeg,
      );
      
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      // If compression fails, return original bytes
      return await imageFile.readAsBytes();
    }
  }

  /// Upload profile picture to Supabase Storage
  Future<String> uploadProfilePicture({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      // Compress the image
      final compressedBytes = await compressImage(imageFile);

      // Define the storage path
      final fileName = '$userId.jpg';
      final storagePath = 'profiles/$fileName';

      // Check if file already exists and remove it
      try {
        final existingFiles = await _supabase.storage
            .from('service-images')
            .list(path: 'profiles');
        
        final fileExists = existingFiles.any((file) => file.name == fileName);
        
        if (fileExists) {
          await _supabase.storage
              .from('service-images')
              .remove(['profiles/$fileName']);
        }
      } catch (e) {
        // File doesn't exist, continue with upload
      }

      // Upload the new image
      final uploadPath = await _supabase.storage
          .from('service-images')
          .uploadBinary(
            storagePath,
            compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // This allows overwriting
            ),
          );

      // Get the public URL
      final publicUrl = _supabase.storage
          .from('service-images')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      throw AppException('Failed to upload image: ${e.toString()}');
    }
  }

  /// Delete profile picture from Supabase Storage
  Future<void> deleteProfilePicture(String userId) async {
    try {
      final fileName = '$userId.jpg';
      final storagePath = 'profiles/$fileName';

      await _supabase.storage
          .from('service-images')
          .remove([storagePath]);
    } catch (e) {
      throw AppException('Failed to delete image: ${e.toString()}');
    }
  }
}