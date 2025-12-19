// ============================================
// lib/features/services/service_details_screen.dart
// Enhanced Light Glass UI with Green, Blue, Purple, Orange theme
// Updated: Price moved to badge row
// ============================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/service_model.dart';
import '../../core/models/provider_model.dart';
import '../../core/models/review_model.dart';
import '../../core/utils/formatters.dart';
import '../../core/errors/app_exception.dart';
import '../chat/chat_provider.dart';

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen>
    with SingleTickerProviderStateMixin {
  ServiceModel? service;
  ProviderModel? provider;
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
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadServiceDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final supabase = SupabaseConfig.client;

      final serviceResponse = await supabase
          .from('services')
          .select('*, providers(*)')
          .eq('id', widget.serviceId)
          .single();

      final loadedService = ServiceModel.fromJson(serviceResponse);
      final loadedProvider = loadedService.provider;

      if (loadedProvider != null) {
        final reviewsResponse = await supabase
            .from('reviews')
            .select('*, customer:users!customer_id(*)')
            .eq('provider_id', loadedProvider.id)
            .order('created_at', ascending: false)
            .limit(10);

        final loadedReviews = (reviewsResponse as List)
            .map((json) => ReviewModel.fromJson(json))
            .toList();

        setState(() {
          reviews = loadedReviews;
        });
      }

      setState(() {
        service = loadedService;
        provider = loadedProvider;
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
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildGradientBackground(),
          
          if (isLoading)
            _buildLoadingState()
          else if (error != null || service == null)
            _buildErrorState()
          else
            _buildContent(),
        ],
      ),
      bottomNavigationBar: (!isLoading && error == null && service != null)
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F9FF),
            Color(0xFFFFF5F7),
            Color(0xFFF5F3FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _buildFloatingOrb(300, const Color(0xFF10B981), 0.08),
          ),
          Positioned(
            top: 200,
            left: -50,
            child: _buildFloatingOrb(200, const Color(0xFF8B5CF6), 0.08),
          ),
          Positioned(
            bottom: 100,
            right: 50,
            child: _buildFloatingOrb(250, const Color(0xFFFF7A59), 0.06),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _buildFloatingOrb(280, const Color(0xFF3B82F6), 0.06),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
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
                const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF7A59)),
                const SizedBox(height: 16),
                Text(
                  error ?? 'Service not found',
                  style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildGlassButton(
                  onPressed: _loadServiceDetails,
                  label: 'Retry',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
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
                  _buildServiceHeader(),
                  const SizedBox(height: 20),
                  _buildCategoryChips(),
                  const SizedBox(height: 24),
                  if (service!.description != null) _buildDescription(),
                  if (provider != null) _buildProviderCard(),
                  if (reviews.isNotEmpty) _buildReviewsSection(),
                  const SizedBox(height: 100),
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
      expandedHeight: 300,
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
        if (provider != null)
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: service!.imageUrl ?? '',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.2),
                      const Color(0xFF10B981).withOpacity(0.2),
                    ],
                  ),
                ),
                child: const Icon(Icons.image, size: 80, color: Color(0xFFE5E7EB)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                    Colors.white.withOpacity(0.7),
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
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
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

  Widget _buildServiceHeader() {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          service!.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildGlassChip(
          label: service!.category,
          icon: Icons.category,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          ),
        ),
        _buildGlassChip(
          label: Formatters.formatDuration(service!.durationMinutes),
          icon: Icons.access_time,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
        _buildGlassChip(
          label: Formatters.formatCurrency(service!.price),
          icon: Icons.payments,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF34D399)],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassChip({
    required String label,
    required IconData icon,
    required Gradient gradient,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
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
              service!.description!,
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

  Widget _buildProviderCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Provider',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        _buildGlassCard(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.push('/provider-profile/${provider!.id}');
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7A59), Color(0xFFFF9A76)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF7A59).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.transparent,
                            backgroundImage: provider!.businessLogoUrl != null
                                ? CachedNetworkImageProvider(provider!.businessLogoUrl!)
                                : null,
                            child: provider!.businessLogoUrl == null
                                ? Text(
                                    provider!.businessName[0],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider!.businessName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 18, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider!.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${provider!.totalReviews} reviews',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGlassButton(
                      onPressed: _contactProvider,
                      label: 'Contact Provider',
                      icon: Icons.chat,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        ...reviews.take(3).map((review) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < review.rating ? Icons.star : Icons.star_border,
                              size: 18,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            review.customer?.fullName ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
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
              ),
            )),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
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

  Widget _buildGlassButton({
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
              color: gradient.colors.first.withOpacity(0.3),
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

  Widget _buildBottomBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildGlassButton(
                      onPressed: _contactProvider,
                      label: 'Contact',
                      icon: Icons.chat,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildGlassButton(
                      onPressed: () {
                        context.push('/booking-flow', extra: {
                          'service': service,
                          'provider': provider,
                        });
                      },
                      label: 'Book Now',
                      icon: Icons.calendar_today,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7A59), Color(0xFFFF9A76)],
                      ),
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


