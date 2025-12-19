// lib/features/services/widgets/empty_services_view.dart
import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/app_colors.dart';

class EmptyServicesView extends StatelessWidget {
  final VoidCallback onAddService;

  const EmptyServicesView({super.key, required this.onAddService});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width > 600 ? 500.0 : size.width * 0.9;
    
    return Container(
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
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glassmorphic container
                  _buildGlassContainer(
                    size: size,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing icon
                        _buildGlowingIcon(size),
                        SizedBox(height: size.width > 600 ? 24 : 20),
                        
                        // Title with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF06b6d4),
                              Color(0xFF67e8f9),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'No Services Yet',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width > 600 ? 28 : 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: size.width > 600 ? 16 : 12),
                        
                        // Description
                        Text(
                          'Add your first service to start receiving bookings',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: size.width > 600 ? 16 : 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.width > 600 ? 32 : 24),
                        
                        // Glass button
                        _buildGlassButton(
                          onAddService: onAddService,
                          size: size,
                        ),
                      ],
                    ),
                  ),
                  
                  // Feature cards
                  const SizedBox(height: 40),
                  _buildFeatureCards(size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Size size, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(size.width > 600 ? 32 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF06b6d4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
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

  Widget _buildGlowingIcon(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF06b6d4).withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06b6d4).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: size.width > 600 ? 64 : 56,
        color: const Color(0xFF06b6d4),
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onAddService,
    required Size size,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddService,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width > 600 ? 40 : 32,
            vertical: size.width > 600 ? 18 : 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: size.width > 600 ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Add Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width > 600 ? 18 : 16,
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

  Widget _buildFeatureCards(Size size) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildFeatureCard(
          icon: Icons.star_outline,
          label: 'Quality',
          size: size,
        ),
        _buildFeatureCard(
          icon: Icons.schedule_outlined,
          label: 'Fast Setup',
          size: size,
        ),
        _buildFeatureCard(
          icon: Icons.trending_up_outlined,
          label: 'Grow',
          size: size,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required Size size,
  }) {
    final cardSize = size.width > 600 ? 110.0 : 90.0;
    final iconSize = size.width > 600 ? 28.0 : 24.0;
    final fontSize = size.width > 600 ? 13.0 : 11.0;
    
    return Container(
      width: cardSize,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF06b6d4).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF06b6d4),
            size: iconSize,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
