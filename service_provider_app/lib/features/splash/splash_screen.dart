// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Navigate after delay
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    final authState = await ref.read(authStateProvider.future);
    
    if (!mounted) return;

    if (authState != null) {
      final provider = await ref.read(currentProviderProvider.future);
      
      if (!mounted) return;
      
      if (provider == null) {
        context.go('/onboarding');
      } else {
        context.go('/dashboard');
      }
    } else {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
            ),
          ),
          child: Stack(
            children: [
              // Animated background particles
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ParticlePainter(_particleAnimation.value),
                    size: Size.infinite,
                  );
                },
              ),

              // Main content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glowing glass logo container
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF06b6d4).withOpacity(0.3 * _glowAnimation.value),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Glass morphism container
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFF06b6d4).withOpacity(0.2),
                                            const Color(0xFF06b6d4).withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                          color: const Color(0xFF06b6d4).withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Shine effect
                                          Positioned(
                                            top: 10,
                                            left: 10,
                                            right: 60,
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(0.2),
                                                    Colors.white.withOpacity(0.0),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                          
                                          // Icon
                                          Center(
                                            child: ShaderMask(
                                              shaderCallback: (bounds) => const LinearGradient(
                                                colors: [
                                                  Color(0xFF06b6d4),
                                                  Color(0xFF22d3ee),
                                                ],
                                              ).createShader(bounds),
                                              child: const Icon(
                                                Icons.storefront_rounded,
                                                size: 70,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // App name with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF06b6d4),
                              Color(0xFF22d3ee),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'FixItPro',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tagline in glass container
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF06b6d4).withOpacity(0.1),
                                    const Color(0xFF06b6d4).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Provide Your Best Service',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Animated loading indicator
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF06b6d4).withOpacity(0.4 * _glowAnimation.value),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              
                              // Spinner
                              CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF06b6d4),
                                ),
                                strokeWidth: 3,
                                backgroundColor: const Color(0xFF06b6d4).withOpacity(0.1),
                              ),
                            ],
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
      ),
    );
  }
}

// Custom painter for floating particles
class _ParticlePainter extends CustomPainter {
  final double animationValue;

  _ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i * 0.11)) % size.width;
      final y = ((size.height * (i * 0.17) + animationValue * size.height * 0.5) % size.height);
      final radius = 1.0 + (i % 3);
      
      paint.color = const Color(0xFF06b6d4).withOpacity(0.1 + (i % 3) * 0.05);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
