// lib/features/services/service_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../auth/auth_provider.dart';
import 'services_provider.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final String? serviceId;
  
  const ServiceFormScreen({super.key, this.serviceId});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _selectedCategory = AppConstants.serviceCategories.first;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.serviceId != null) {
      _loadService();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadService() async {
    final service = await ref.read(serviceByIdProvider(widget.serviceId!).future);
    if (service != null && mounted) {
      setState(() {
        _titleController.text = service.title;
        _descriptionController.text = service.description ?? '';
        _priceController.text = service.price.toString();
        _durationController.text = service.durationMinutes.toString();
        _selectedCategory = service.category;
        _existingImageUrl = service.imageUrl;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      print('📸 Opening image picker...');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        print('✅ Image picked: ${pickedFile.path}');
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        _showSnackBar('Image selected! Tap Save to upload.', isError: false);
      } else {
        print('❌ No image selected');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final provider = await ref.read(currentProviderProvider.future);
      if (provider == null) throw Exception('Provider not found');

      final controller = ref.read(servicesControllerProvider.notifier);
      
      String? imageUrl = _existingImageUrl;
      
      if (_selectedImage != null) {
        print('📤 Starting upload...');
        imageUrl = await controller.uploadServiceImageSimple(_selectedImage!);
        
        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }
        
        print('✅ Upload complete: $imageUrl');
      }

      if (widget.serviceId == null) {
        await controller.createService(
          providerId: provider.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          price: double.parse(_priceController.text),
          durationMinutes: int.parse(_durationController.text),
          imageUrl: imageUrl,
        );
      } else {
        await controller.updateService(
          serviceId: widget.serviceId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          price: double.parse(_priceController.text),
          durationMinutes: int.parse(_durationController.text),
          imageUrl: imageUrl,
        );
      }

      if (mounted) {
        _showSnackBar('Service saved successfully!', isError: false);
        context.pop();
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFef4444) : const Color(0xFF10b981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
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
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF06b6d4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0f172a).withOpacity(0.9),
                const Color(0xFF1e293b).withOpacity(0.9),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF06b6d4).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF06b6d4).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF06b6d4)),
            onPressed: () => context.pop(),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF67e8f9)],
          ).createShader(bounds),
          child: Text(
            widget.serviceId == null ? 'Add Service' : 'Edit Service',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                16,
                16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Upload Section
                    _buildImageSection(size),
                    const SizedBox(height: 24),
                    
                    // Form Fields
                    _buildGlassCard(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _titleController,
                            label: 'Service Title *',
                            icon: Icons.title,
                            validator: (value) => Validators.required(value, 'Title'),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            icon: Icons.description,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildDropdown(),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _priceController,
                            label: 'Price (\$) *',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validator: Validators.price,
                            prefix: '\$',
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _durationController,
                            label: 'Duration (minutes) *',
                            icon: Icons.access_time,
                            keyboardType: TextInputType.number,
                            validator: Validators.duration,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Loading Overlay
            if (_isUploading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF06b6d4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06b6d4).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildImageSection(Size size) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Service Image',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: _isUploading ? null : _pickImage,
            child: Container(
              height: size.width > 600 ? 250 : 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF06b6d4).withOpacity(0.15),
                    const Color(0xFF0891b2).withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06b6d4).withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildImageWidget(),
              ),
            ),
          ),
          
          if (_selectedImage != null || _existingImageUrl != null) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _isUploading ? null : () {
                  setState(() {
                    _selectedImage = null;
                    _existingImageUrl = null;
                  });
                },
                icon: const Icon(Icons.delete_outline, color: Color(0xFFef4444)),
                label: const Text(
                  'Remove Image',
                  style: TextStyle(color: Color(0xFFef4444)),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: const Color(0xFFef4444).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: const Color(0xFFef4444).withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFF06b6d4)),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Color(0xFF06b6d4)),
        filled: true,
        fillColor: const Color(0xFF06b6d4).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF06b6d4),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFef4444),
          ),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isUploading,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category *',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: const Icon(Icons.category, color: Color(0xFF06b6d4)),
        filled: true,
        fillColor: const Color(0xFF06b6d4).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF06b6d4),
            width: 2,
          ),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF1e293b),
      items: AppConstants.serviceCategories.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(cat, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: _isUploading ? null : (value) {
        setState(() => _selectedCategory = value!);
      },
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isUploading ? null : _handleSubmit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isUploading
                  ? [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)]
                  : [
                      const Color(0xFF06b6d4).withOpacity(0.8),
                      const Color(0xFF0891b2).withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06b6d4).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isUploading
              ? const SizedBox(
                  height: 24,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.serviceId == null ? Icons.add_circle_outline : Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.serviceId == null ? 'Add Service' : 'Update Service',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1e293b),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06b6d4).withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF06b6d4).withOpacity(0.15),
                ),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF06b6d4), Color(0xFF67e8f9)],
                ).createShader(bounds),
                child: const Text(
                  'Saving service...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image file: $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Color(0xFFef4444)),
                const SizedBox(height: 8),
                Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          );
        },
      );
    }
    
    if (_existingImageUrl != null) {
      return Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 48, color: Color(0xFFef4444)),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          );
        },
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF06b6d4).withOpacity(0.15),
          ),
          child: const Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Color(0xFF06b6d4),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to select image',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Recommended: 1920x1080px',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}


