// lib/features/profile/profile_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../core/utils/validators.dart';
import '../../core/services/profile_picture_service.dart';
import '../auth/auth_provider.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isUploadingImage = false;
  bool _isSaving = false;
  String? _currentAvatarUrl;
  int _avatarKey = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final provider = await ref.read(currentProviderProvider.future);
    if (provider != null) {
      setState(() {
        _businessNameController.text = provider.businessName;
        _descriptionController.text = provider.businessDescription ?? '';
        _addressController.text = provider.businessAddress ?? '';
        _phoneController.text = provider.businessPhone ?? '';
        _currentAvatarUrl = provider.businessLogoUrl;
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (_isUploadingImage) return;
    
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF06b6d4).withOpacity(0.15),
                      const Color(0xFF06b6d4).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF06b6d4).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06b6d4).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image_rounded,
                        color: Color(0xFF06b6d4),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Choose Image Source',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                    const SizedBox(height: 14),
                    _buildSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (source != null && mounted) {
      await _uploadProfilePicture(source);
    }
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: const Color(0xFF06b6d4).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF06b6d4).withOpacity(0.25),
                            const Color(0xFF06b6d4).withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF06b6d4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: const Color(0xFF06b6d4), size: 24),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture(ImageSource source) async {
    if (_isUploadingImage) return;
    
    setState(() => _isUploadingImage = true);

    try {
      final provider = await ref.read(currentProviderProvider.future);
      if (provider == null) throw Exception('Provider not found');
      
      final newAvatarUrl = await ProfilePictureService.pickAndUploadAvatar(
        source: source,
        profileType: ProfileType.provider,
        providerId: provider.id,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      ref.invalidate(currentProviderProvider);
      await _loadProfile();

      setState(() {
        _currentAvatarUrl = newAvatarUrl;
        _avatarKey++;
        _isUploadingImage = false;
      });

      if (mounted) {
        _showGlassSnackBar('Profile picture updated successfully!', isError: false);
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        _showGlassSnackBar('Failed to upload image: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    if (_isUploadingImage) return;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF06b6d4).withOpacity(0.15),
                      const Color(0xFF06b6d4).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF06b6d4).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.withOpacity(0.25),
                            Colors.red.withOpacity(0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Delete Profile Picture',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure you want to delete your profile picture?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _DialogButton(
                            onPressed: () => Navigator.pop(context, false),
                            text: 'Cancel',
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _DialogButton(
                            onPressed: () => Navigator.pop(context, true),
                            text: 'Delete',
                            isPrimary: true,
                            isDestructive: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isUploadingImage = true);

    try {
      final provider = await ref.read(currentProviderProvider.future);
      if (provider == null) throw Exception('Provider not found');
      
      await ProfilePictureService.deleteAvatar(
        profileType: ProfileType.provider,
        providerId: provider.id,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      ref.invalidate(currentProviderProvider);
      await _loadProfile();

      setState(() {
        _currentAvatarUrl = null;
        _avatarKey++;
        _isUploadingImage = false;
      });

      if (mounted) {
        _showGlassSnackBar('Profile picture deleted successfully!', isError: false);
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        _showGlassSnackBar('Failed to delete image: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.withOpacity(0.2),
                      Colors.red.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.withOpacity(0.35),
                            Colors.red.withOpacity(0.25),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade300,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure you want to permanently delete your account? All your data, bookings, and information will be lost forever.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _DialogButton(
                            onPressed: () => Navigator.pop(context, false),
                            text: 'Cancel',
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _DialogButton(
                            onPressed: () => Navigator.pop(context, true),
                            text: 'Delete',
                            isPrimary: false,
                            isDestructive: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      final provider = await ref.read(currentProviderProvider.future);
      if (provider == null) throw Exception('Provider not found');

      // Delete account through profile controller
      await ref.read(profileControllerProvider.notifier).deleteProviderAccount(
            providerId: provider.id,
            userId: provider.userId,
          );

      // Sign out and redirect to auth
      if (mounted) {
        await ref.read(authControllerProvider.notifier).signOut();
        if (context.mounted) {
          context.go('/auth');
          _showGlassSnackBar('Account deleted successfully', isError: false);
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        _showGlassSnackBar('Failed to delete account: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploadingImage || _isSaving) return;

    final provider = await ref.read(currentProviderProvider.future);
    if (provider == null) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(profileControllerProvider.notifier).updateProviderProfile(
            providerId: provider.id,
            businessName: _businessNameController.text.trim(),
            businessDescription: _descriptionController.text.trim(),
            businessAddress: _addressController.text.trim(),
            businessPhone: _phoneController.text.trim(),
          );

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      
      if (context.mounted) {
        _showGlassSnackBar('Profile updated successfully!', isError: false);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (context.mounted) {
        _showGlassSnackBar('Failed to update profile: ${e.toString()}', isError: true);
      }
    }
  }

  void _showGlassSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError 
            ? Colors.red.withOpacity(0.95)
            : const Color(0xFF06b6d4).withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 0,
      ),
    );
  }

  Widget _buildAvatar() {
    final businessName = _businessNameController.text;
    final initial = businessName.isNotEmpty ? businessName[0].toUpperCase() : 'B';
    
    final displayUrl = _currentAvatarUrl != null 
        ? '$_currentAvatarUrl?t=${DateTime.now().millisecondsSinceEpoch}' 
        : null;

    if (_isUploadingImage) {
      return const CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
      );
    }

    if (displayUrl == null) {
      return Text(
        initial,
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: Color(0xFF06b6d4),
          letterSpacing: -2,
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        key: ValueKey('provider-avatar-$_avatarKey-$displayUrl'),
        imageUrl: displayUrl,
        width: 140,
        height: 140,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          return Text(
            initial,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: Color(0xFF06b6d4),
              letterSpacing: -2,
            ),
          );
        },
        httpHeaders: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      ),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
            ),
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF06b6d4).withOpacity(0.12),
                        const Color(0xFF06b6d4).withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF06b6d4).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Header with Edit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: -1,
                          ),
                        ),
                        if (!_isEditing && !_isUploadingImage && !_isSaving)
                          _GlassIconButton(
                            icon: Icons.edit_rounded,
                            onPressed: () => setState(() => _isEditing = true),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 36),
                    
                    // Avatar Section
                    Stack(
                      children: [
                        // Glow effect
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF06b6d4).withOpacity(0.4),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        
                        // Avatar with glass border
                        GestureDetector(
                          onTap: (_isUploadingImage || _isSaving) 
                              ? null 
                              : _showImageSourceDialog,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF06b6d4).withOpacity(0.25),
                                  const Color(0xFF06b6d4).withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFF06b6d4).withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: Center(child: _buildAvatar()),
                          ),
                        ),

                        // Camera button
                        if (!_isUploadingImage && !_isSaving)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF06b6d4),
                                      Color(0xFF0891b2),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF0f172a),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF06b6d4).withOpacity(0.5),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        // Delete button
                        if (_currentAvatarUrl != null && 
                            !_isUploadingImage && 
                            !_isSaving)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _deleteProfilePicture,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade600,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF0f172a),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Name and Status
                    Text(
                      _businessNameController.text.isEmpty 
                          ? 'Business Name' 
                          : _businessNameController.text,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF06b6d4).withOpacity(0.15),
                            const Color(0xFF06b6d4).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF06b6d4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Service Provider',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF06b6d4).withOpacity(0.95),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    
                    if (_isUploadingImage) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Uploading image...',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF06b6d4).withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Business Information Card
                    _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF06b6d4).withOpacity(0.2),
                                        const Color(0xFF06b6d4).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF06b6d4).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.business_rounded,
                                    size: 22,
                                    color: Color(0xFF06b6d4),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'Business Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.95),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            _GlassTextField(
                              controller: _businessNameController,
                              label: 'Business Name',
                              icon: Icons.store_rounded,
                              enabled: _isEditing && !_isUploadingImage && !_isSaving,
                              validator: (value) => Validators.required(value, 'Business name'),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _GlassTextField(
                              controller: _descriptionController,
                              label: 'Description',
                              icon: Icons.description_rounded,
                              enabled: _isEditing && !_isUploadingImage && !_isSaving,
                              maxLines: 3,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _GlassTextField(
                              controller: _addressController,
                              label: 'Address',
                              icon: Icons.location_on_rounded,
                              enabled: _isEditing && !_isUploadingImage && !_isSaving,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _GlassTextField(
                              controller: _phoneController,
                              label: 'Phone',
                              icon: Icons.phone_rounded,
                              enabled: _isEditing && !_isUploadingImage && !_isSaving,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _GlassButton(
                              onPressed: (_isUploadingImage || _isSaving)
                                  ? null
                                  : () {
                                      setState(() => _isEditing = false);
                                      _loadProfile();
                                    },
                              text: 'Cancel',
                              isPrimary: false,
                              isLoading: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _GlassButton(
                              onPressed: (_isUploadingImage || _isSaving) 
                                  ? null 
                                  : _handleSave,
                              text: 'Save Changes',
                              isPrimary: true,
                              isLoading: _isSaving,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Sign Out Button at Bottom
                    _GlassButton(
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (context.mounted) context.go('/auth');
                      },
                      text: 'Sign Out',
                      isPrimary: false,
                      isDestructive: false,
                      icon: Icons.logout_rounded,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Delete Account Button
                    _GlassButton(
                      onPressed: () => _showDeleteAccountDialog(),
                      text: 'Delete Account',
                      isPrimary: false,
                      isDestructive: true,
                      icon: Icons.delete_forever_rounded,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Glass Card Widget
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF06b6d4).withOpacity(0.12),
                const Color(0xFF06b6d4).withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Glass Icon Button Widget
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDestructive
                  ? [
                      Colors.red.withOpacity(0.15),
                      Colors.red.withOpacity(0.08),
                    ]
                  : [
                      const Color(0xFF06b6d4).withOpacity(0.15),
                      const Color(0xFF06b6d4).withOpacity(0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.3)
                  : const Color(0xFF06b6d4).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF06b6d4).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red.shade300
                      : const Color(0xFF06b6d4),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Glass TextField Widget
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: enabled 
                  ? [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ]
                  : [
                      Colors.white.withOpacity(0.03),
                      Colors.white.withOpacity(0.01),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF06b6d4).withOpacity(0.25)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF06b6d4).withOpacity(0.7),
                size: 24,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Glass Button Widget
class _GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isPrimary;
  final bool isLoading;
  final bool isDestructive;
  final IconData? icon;

  const _GlassButton({
    required this.onPressed,
    required this.text,
    required this.isPrimary,
    this.isLoading = false,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDestructive
                  ? [
                      Colors.red.withOpacity(0.2),
                      Colors.red.withOpacity(0.12),
                    ]
                  : isPrimary
                      ? [
                          const Color(0xFF06b6d4).withOpacity(0.25),
                          const Color(0xFF06b6d4).withOpacity(0.15),
                        ]
                      : [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.4)
                  : isPrimary
                      ? const Color(0xFF06b6d4).withOpacity(0.4)
                      : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(18),
              splashColor: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : isPrimary
                      ? const Color(0xFF06b6d4).withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF06b6d4),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: isDestructive
                                  ? Colors.red.shade300
                                  : isPrimary
                                      ? const Color(0xFF06b6d4)
                                      : Colors.white.withOpacity(0.95),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            text,
                            style: TextStyle(
                              color: isDestructive
                                  ? Colors.red.shade300
                                  : isPrimary
                                      ? const Color(0xFF06b6d4)
                                      : Colors.white.withOpacity(0.95),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog Button Widget
class _DialogButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isPrimary;
  final bool isDestructive;

  const _DialogButton({
    required this.onPressed,
    required this.text,
    required this.isPrimary,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDestructive
                  ? [
                      Colors.red.withOpacity(0.25),
                      Colors.red.withOpacity(0.15),
                    ]
                  : isPrimary
                      ? [
                          const Color(0xFF06b6d4).withOpacity(0.2),
                          const Color(0xFF06b6d4).withOpacity(0.12),
                        ]
                      : [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.4)
                  : isPrimary
                      ? const Color(0xFF06b6d4).withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : isPrimary
                      ? const Color(0xFF06b6d4).withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isDestructive
                        ? Colors.red.shade300
                        : isPrimary
                            ? const Color(0xFF06b6d4)
                            : Colors.white.withOpacity(0.95),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}





