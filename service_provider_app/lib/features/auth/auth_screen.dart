
// lib/features/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import 'auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  late AnimationController _floatingController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);

    if (_isLogin) {
      await authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
        next.when(
          data: (_) {},
          loading: () {},
          error: (error, _) {
            if (mounted) {
              _showErrorSnackBar(error.toString());
            }
          },
        );
      });
    } else {
      await authController.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _fullNameController.text.trim(),
      );

      ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
        next.when(
          data: (_) {
            if (mounted) {
              _showSignupSuccessDialog();
            }
          },
          loading: () {},
          error: (error, _) {
            if (mounted) {
              _showErrorSnackBar(error.toString());
            }
          },
        );
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSignupSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0f172a).withOpacity(0.9),
                  const Color(0xFF1e293b).withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF06b6d4).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF06b6d4).withOpacity(0.3),
                              const Color(0xFF06b6d4).withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06b6d4).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 64,
                          color: Color(0xFF06b6d4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your account has been successfully created.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06b6d4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF06b6d4).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Color(0xFF06b6d4),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Start exploring and booking services near you!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06b6d4),
                            foregroundColor: const Color(0xFF0f172a),
                            elevation: 0,
                            shadowColor: const Color(0xFF06b6d4).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Start Exploring',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0f172a),
              Color(0xFF1e293b),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background orbs
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Positioned(
                  top: 100 + (_floatingController.value * 30),
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF06b6d4).withOpacity(0.15),
                          const Color(0xFF06b6d4).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Positioned(
                  bottom: 150 - (_floatingController.value * 30),
                  left: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF06b6d4).withOpacity(0.1),
                          const Color(0xFF06b6d4).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glass morphism card
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF06b6d4).withOpacity(0.1),
                              const Color(0xFF06b6d4).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFF06b6d4).withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06b6d4).withOpacity(0.1),
                              blurRadius: 40,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Logo with glow effect
                                    AnimatedBuilder(
                                      animation: _glowController,
                                      builder: (context, child) {
                                        return Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Color.lerp(
                                                  const Color(0xFF06b6d4).withOpacity(0.3),
                                                  const Color(0xFF06b6d4).withOpacity(0.1),
                                                  _glowController.value,
                                                )!,
                                                Colors.transparent,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF06b6d4).withOpacity(
                                                  0.3 + (_glowController.value * 0.2),
                                                ),
                                                blurRadius: 40,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month_rounded,
                                            size: 64,
                                            color: Color(0xFF06b6d4),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Title
                                    Text(
                                      _isLogin ? 'Welcome Back' : 'Join Us',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Subtitle
                                    Text(
                                      _isLogin
                                          ? 'Sign in to book your next service'
                                          : 'Create an account to start booking',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Full Name Field
                                    if (!_isLogin) ...[
                                      _buildGlassTextField(
                                        controller: _fullNameController,
                                        label: 'Full Name',
                                        icon: Icons.person_outline,
                                        validator: (value) => Validators.required(value, 'Full name'),
                                        textInputAction: TextInputAction.next,
                                        textCapitalization: TextCapitalization.words,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    
                                    // Email Field
                                    _buildGlassTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: Validators.email,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Password Field
                                    _buildGlassTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      icon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      validator: Validators.password,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleSubmit(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: const Color(0xFF06b6d4).withOpacity(0.7),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    
                                    if (!_isLogin) ...[
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          'Password must be at least 6 characters',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ],
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Submit Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: authState.isLoading ? null : _handleSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF06b6d4),
                                          foregroundColor: const Color(0xFF0f172a),
                                          disabledBackgroundColor: const Color(0xFF06b6d4).withOpacity(0.5),
                                          elevation: 0,
                                          shadowColor: const Color(0xFF06b6d4).withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: authState.isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  color: Color(0xFF0f172a),
                                                ),
                                              )
                                            : Text(
                                                _isLogin ? 'Sign In' : 'Create Account',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Toggle Sign In/Up
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isLogin
                                              ? "Don't have an account? "
                                              : 'Already have an account? ',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isLogin = !_isLogin;
                                              _formKey.currentState?.reset();
                                            });
                                          },
                                          child: Text(
                                            _isLogin ? 'Sign Up' : 'Sign In',
                                            style: const TextStyle(
                                              color: Color(0xFF06b6d4),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Forgot Password
                                    if (_isLogin)
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black87,
                                            builder: (context) => _ResetPasswordDialog(),
                                          );
                                        },
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    TextCapitalization? textCapitalization,
    bool obscureText = false,
    void Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: const Color(0xFF06b6d4).withOpacity(0.7)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}

// Reset Password Dialog
class _ResetPasswordDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<_ResetPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0f172a).withOpacity(0.9),
                const Color(0xFF1e293b).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06b6d4).withOpacity(0.2),
                blurRadius: 40,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter your email address and we\'ll send you a link to reset your password.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF06b6d4).withOpacity(0.2),
                          ),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          enabled: !_isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: const Color(0xFF06b6d4).withOpacity(0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isLoading = true);
                                        
                                        await ref.read(authControllerProvider.notifier).resetPassword(
                                              _emailController.text.trim(),
                                            );
                                        
                                        if (mounted) {
                                          setState(() => _isLoading = false);
                                          Navigator.of(context).pop();
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(Icons.check_circle, color: Colors.white),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      'Password reset link sent! Check your email.',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: const Color(0xFF06b6d4),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              duration: const Duration(seconds: 5),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF06b6d4),
                                foregroundColor: const Color(0xFF0f172a),
                                disabledBackgroundColor: const Color(0xFF06b6d4).withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF0f172a),
                                      ),
                                    )
                                  : const Text(
                                      'Send Link',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
