// ============================================
// ENHANCED: lib/features/reviews/write_review_screen.dart
// Ultra-modern review interface with advanced animations
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/booking_model.dart';
import 'reviews_provider.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const WriteReviewScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  int _hoveredStar = 0;
  BookingModel? _booking;
  bool _isLoading = true;
  bool _isSubmitting = false;

  late AnimationController _starController;
  late AnimationController _cardController;
  late Animation<double> _starScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _loadBooking();
    _setupAnimations();
  }

  void _setupAnimations() {
    _starController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _starScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.elasticOut),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _cardController.forward();
  }

  Future<void> _loadBooking() async {
    try {
      final supabase = SupabaseConfig.client;
      final response = await supabase
          .from('bookings')
          .select('*, providers(*), services(*)')
          .eq('id', widget.bookingId)
          .single();

      if (mounted) {
        setState(() {
          _booking = BookingModel.fromJson(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error loading booking: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _starController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_booking == null || _isSubmitting) return;
    
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.star_border_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select a rating'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(reviewsProvider.notifier).createReview(
            bookingId: widget.bookingId,
            providerId: _booking!.providerId,
            rating: _rating,
            comment: _commentController.text.trim().isNotEmpty
                ? _commentController.text.trim()
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Review submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/bookings');
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(e.toString())),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading booking details...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_booking == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking not found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to load booking details',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text(
          'Write Review',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Header
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber[600]!,
                  Colors.orange[500]!,
                  Colors.deepOrange[400]!,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: SlideTransition(
                position: _cardSlideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Info Card
                      if (_booking!.service != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange[400]!,
                                      Colors.deepOrange[500]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.design_services_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _booking!.service!.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    if (_booking!.provider != null)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.store_rounded,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              _booking!.provider!.businessName,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 28),

                      // Rating Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Rate Your Experience',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            
                            // Star Rating - Fixed overflow with proper spacing
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(5, (index) {
                                final isSelected = index < _rating;
                                final isHovered = index < _hoveredStar;
                                
                                return Flexible(
                                  child: MouseRegion(
                                    onEnter: (_) => setState(() => _hoveredStar = index + 1),
                                    onExit: (_) => setState(() => _hoveredStar = 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() => _rating = index + 1);
                                        _starController.forward(from: 0.0);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        child: ScaleTransition(
                                          scale: _rating == index + 1
                                              ? _starScaleAnimation
                                              : const AlwaysStoppedAnimation(1.0),
                                          child: Icon(
                                            isSelected || isHovered
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            size: 46,
                                            color: isSelected || isHovered
                                                ? Colors.amber[600]
                                                : Colors.grey[300],
                                            shadows: isSelected
                                                ? [
                                                    Shadow(
                                                      color: Colors.amber.withOpacity(0.5),
                                                      blurRadius: 20,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Rating Text with enhanced design
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: _rating > 0
                                  ? Container(
                                      key: ValueKey(_rating),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getRatingColor(_rating).withOpacity(0.15),
                                            _getRatingColor(_rating).withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getRatingColor(_rating).withOpacity(0.4),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getRatingColor(_rating).withOpacity(0.2),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getRatingIcon(_rating),
                                            color: _getRatingColor(_rating),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            _getRatingText(_rating),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _getRatingColor(_rating),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(height: 48),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Comment Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.blue[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Share Your Feedback',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Optional',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Tell us about your experience...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
                                ),
                                contentPadding: const EdgeInsets.all(20),
                              ),
                              maxLines: 6,
                              maxLength: 500,
                              style: const TextStyle(fontSize: 15, height: 1.5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button with enhanced design
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: _isSubmitting
                              ? null
                              : LinearGradient(
                                  colors: [
                                    Colors.blue[600]!,
                                    Colors.blue[500]!,
                                  ],
                                ),
                          boxShadow: _isSubmitting
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSubmitting ? Colors.grey[300] : Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded, size: 22),
                                    SizedBox(width: 12),
                                    Text(
                                      'Submit Review',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor Experience';
      case 2:
        return 'Could Be Better';
      case 3:
        return 'Good Service';
      case 4:
        return 'Great Experience';
      case 5:
        return 'Outstanding!';
      default:
        return '';
    }
  }

  IconData _getRatingIcon(int rating) {
    switch (rating) {
      case 1:
        return Icons.sentiment_very_dissatisfied_rounded;
      case 2:
        return Icons.sentiment_dissatisfied_rounded;
      case 3:
        return Icons.sentiment_neutral_rounded;
      case 4:
        return Icons.sentiment_satisfied_rounded;
      case 5:
        return Icons.sentiment_very_satisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
