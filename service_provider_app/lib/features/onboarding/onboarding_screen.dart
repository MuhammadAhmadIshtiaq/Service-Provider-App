import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/config/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../auth/auth_provider.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final List<String> _selectedCategories = [];

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      _showGlassSnackBar('Please select at least one category');
      return;
    }

    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    await ref.read(onboardingControllerProvider.notifier).createProviderProfile(
          userId: user.id,
          businessName: _businessNameController.text.trim(),
          businessDescription: _descriptionController.text.trim(),
          businessAddress: _addressController.text.trim(),
          businessPhone: _phoneController.text.trim(),
          serviceCategories: _selectedCategories,
        );

    if (context.mounted) {
      context.go('/dashboard');
    }
  }

  void _showGlassSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1e293b),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _GlassIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Setup Your Business',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header Section
                  _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF06b6d4).withOpacity(0.3),
                                  const Color(0xFF0891b2).withOpacity(0.2),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF06b6d4).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.business_center,
                              size: 48,
                              color: Color(0xFF06b6d4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tell us about your business',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Help customers find and connect with you',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Fields
                  _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GlassTextField(
                            controller: _businessNameController,
                            labelText: 'Business Name',
                            hintText: 'Enter your business name',
                            icon: Icons.business,
                            validator: (value) => Validators.required(value, 'Business name'),
                          ),
                          const SizedBox(height: 20),
                          
                          _GlassTextField(
                            controller: _descriptionController,
                            labelText: 'Business Description',
                            hintText: 'Describe what you do',
                            icon: Icons.description,
                            maxLines: 4,
                            validator: (value) => Validators.required(value, 'Description'),
                          ),
                          const SizedBox(height: 20),
                          
                          _GlassTextField(
                            controller: _addressController,
                            labelText: 'Business Address',
                            hintText: 'Enter your business location',
                            icon: Icons.location_on,
                            validator: (value) => Validators.required(value, 'Address'),
                          ),
                          const SizedBox(height: 20),
                          
                          _GlassTextField(
                            controller: _phoneController,
                            labelText: 'Business Phone',
                            hintText: 'Enter contact number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) => Validators.required(value, 'Phone'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Categories Section
                  _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                                ),
                                child: const Icon(
                                  Icons.category,
                                  color: Color(0xFF06b6d4),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Service Categories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select all that apply',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: AppConstants.serviceCategories.map((category) {
                              final isSelected = _selectedCategories.contains(category);
                              return _GlassChip(
                                label: category,
                                isSelected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCategories.add(category);
                                    } else {
                                      _selectedCategories.remove(category);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  _GlassButton(
                    onPressed: onboardingState.isLoading ? null : _handleSubmit,
                    isLoading: onboardingState.isLoading,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Complete Setup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
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
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF06b6d4).withOpacity(0.1),
                const Color(0xFF06b6d4).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Glass Icon Button
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF06b6d4).withOpacity(0.2),
                const Color(0xFF06b6d4).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Glass Text Field
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            labelText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF06b6d4),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF06b6d4).withOpacity(0.05),
                    const Color(0xFF06b6d4).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                ),
              ),
              child: TextFormField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                validator: validator,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: const Color(0xFF06b6d4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorStyle: const TextStyle(
                    color: Color(0xFFef4444),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Glass Chip
class _GlassChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _GlassChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      const Color(0xFF06b6d4).withOpacity(0.3),
                      const Color(0xFF0891b2).withOpacity(0.2),
                    ]
                  : [
                      const Color(0xFF06b6d4).withOpacity(0.05),
                      const Color(0xFF06b6d4).withOpacity(0.02),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF06b6d4).withOpacity(0.6)
                  : const Color(0xFF06b6d4).withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF06b6d4).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(!isSelected),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF06b6d4),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
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

// Glass Button
class _GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  const _GlassButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: onPressed != null
                ? const LinearGradient(
                    colors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF64748b).withOpacity(0.5),
                      const Color(0xFF475569).withOpacity(0.5),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: const Color(0xFF06b6d4).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}




