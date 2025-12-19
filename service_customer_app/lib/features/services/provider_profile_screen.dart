// ============================================
// lib/features/services/provider_profile_screen.dart
// Enhanced Light Glass UI with Vibrant Color Palette
// ============================================
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:service_customer_app/core/config/supabase_config.dart';
import 'package:service_customer_app/core/errors/app_exception.dart';
import 'package:service_customer_app/core/models/additional_models.dart';
import 'package:service_customer_app/core/models/provider_model.dart';
import 'package:service_customer_app/core/models/service_model.dart';
import 'package:service_customer_app/core/utils/formatters.dart';
import '../chat/chat_provider.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  final String providerId;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
  });

  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  ProviderModel? provider;
  List<ServiceModel> services = [];
  List<ReviewModel> reviews = [];
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadProviderProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderProfile() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final supabase = SupabaseConfig.client;

      final providerResponse = await supabase
          .from('providers')
          .select()
          .eq('id', widget.providerId)
          .single();

      final loadedProvider = ProviderModel.fromJson(providerResponse);

      final servicesResponse = await supabase
          .from('services')
          .select()
          .eq('provider_id', widget.providerId)
          .eq('is_active', true);

      final loadedServices = (servicesResponse as List)
          .map((json) => ServiceModel.fromJson(json))
          .toList();

      final reviewsResponse = await supabase
          .from('reviews')
          .select('*, customer:users!customer_id(*)')
          .eq('provider_id', widget.providerId)
          .order('created_at', ascending: false);

      final loadedReviews = (reviewsResponse as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();

      setState(() {
        provider = loadedProvider;
        services = loadedServices;
        reviews = loadedReviews;
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        error = AppException.getErrorMessage(e);
        isLoading = false;
      });
    }
  }

  Future<void> _contactProvider() async {
    if (provider == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Opening chat...'),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      );

      final conversationId = await ref
          .read(chatProvider.notifier)
          .getOrCreateConversation(provider!.id);

      if (mounted) {
        context.push('/chat/${provider!.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppException.getErrorMessage(e)),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildGradientBackground(),
          if (isLoading)
            _buildLoadingState()
          else if (error != null || provider == null)
            _buildErrorState()
          else
            _buildContent(),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFFEF3C7),
            Color(0xFFF3E8FF),
            Color(0xFFFFEDD5),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -120,
            child: _buildFloatingOrb(350, const Color(0xFF60A5FA), 0.1),
          ),
          Positioned(
            top: 150,
            left: -80,
            child: _buildFloatingOrb(250, const Color(0xFFFBBF24), 0.08),
          ),
          Positioned(
            bottom: 200,
            right: 30,
            child: _buildFloatingOrb(200, const Color(0xFFA78BFA), 0.09),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _buildFloatingOrb(300, const Color(0xFFF472B6), 0.07),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: _buildGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60A5FA)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                Text(
                  error ?? 'Provider not found',
                  style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildGradientButton(
                  onPressed: _loadProviderProfile,
                  label: 'Retry',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          _buildGlassAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactButton(),
                  const SizedBox(height: 24),
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  if (provider!.businessDescription != null) _buildAboutSection(),
                  if (provider!.businessAddress != null ||
                      provider!.businessPhone != null)
                    _buildContactInfo(),
                  _buildServicesSection(),
                  _buildReviewsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildGlassIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildGlassIconButton(
            icon: Icons.chat_bubble_outline,
            onPressed: _contactProvider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildGlassIconButton(
            icon: Icons.favorite_border,
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            provider!.businessName,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            provider!.businessLogoUrl != null
                ? CachedNetworkImage(
                    imageUrl: provider!.businessLogoUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF60A5FA).withOpacity(0.3),
                          const Color(0xFFA78BFA).withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 100,
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.white.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF1F2937)),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return _buildGradientButton(
      onPressed: _contactProvider,
      label: 'Contact Provider',
      icon: Icons.chat,
      gradient: const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            label: 'Rating',
            value: provider!.rating.toStringAsFixed(1),
            gradient: const LinearGradient(
              colors: [Color(0xFFFBBF24), Color(0xFFFCD34D)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.rate_review,
            label: 'Reviews',
            value: provider!.totalReviews.toString(),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_available,
            label: 'Bookings',
            value: provider!.totalBookings.toString(),
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return _buildGlassCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient.createShader(const Rect.fromLTWH(0, 0, 200, 100)) != null
              ? LinearGradient(
                  colors: gradient.colors.map((c) => c.withOpacity(0.1)).toList(),
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              provider!.businessDescription!,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (provider!.businessAddress != null)
                  _buildContactInfoRow(
                    icon: Icons.location_on,
                    text: provider!.businessAddress!,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                    ),
                  ),
                if (provider!.businessAddress != null && provider!.businessPhone != null)
                  const Divider(height: 24),
                if (provider!.businessPhone != null)
                  _buildContactInfoRow(
                    icon: Icons.phone,
                    text: provider!.businessPhone!,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContactInfoRow({
    required IconData icon,
    required String text,
    required Gradient gradient,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Offered',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        ...services.map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildServiceCard(service),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return _buildGlassCard(
      child: InkWell(
        onTap: () => context.push('/service-details/${service.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: service.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: service.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF34D399)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Formatters.formatCurrency(service.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          _buildGlassCard(
            child: const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.rate_review, size: 48, color: Color(0xFFD1D5DB)),
                    SizedBox(height: 12),
                    Text(
                      'No reviews yet',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...reviews.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReviewCard(review),
              )),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFFCD34D)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    review.customer?.fullName ?? 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
            if (review.comment != null) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              Formatters.formatRelativeTime(review.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String label,
    IconData? icon,
    required Gradient gradient,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

