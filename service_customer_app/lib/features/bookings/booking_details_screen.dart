// ============================================
// lib/features/bookings/booking_details_screen.dart
// Premium Glass Morphism Design
// ============================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/config/supabase_config.dart';
import '../../core/models/booking_model.dart';
import '../../core/utils/formatters.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  BookingModel? booking;
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _loadBookingDetails();
    _subscribeToBookingEvents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDetails() async {
    try {
      setState(() => isLoading = true);

      final supabase = SupabaseConfig.client;

      final bookingResponse = await supabase
          .from('bookings')
          .select('*, providers(*), services(*)')
          .eq('id', widget.bookingId)
          .single();

      final eventsResponse = await supabase
          .from('booking_events')
          .select('*, triggered_by:users!triggered_by(*)')
          .eq('booking_id', widget.bookingId)
          .order('created_at', ascending: false);

      setState(() {
        booking = BookingModel.fromJson(bookingResponse);
        events = List<Map<String, dynamic>>.from(eventsResponse as List);
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _subscribeToBookingEvents() {
    SupabaseConfig.client
        .from('booking_events:booking_id=eq.${widget.bookingId}')
        .stream(primaryKey: ['id'])
        .listen((data) {
          if (mounted) {
            setState(() {
              events = List<Map<String, dynamic>>.from(data);
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF5F7FA),
      appBar: _buildGlassAppBar(context),
      body: isLoading || booking == null
          ? _buildLoadingState()
          : _buildContent(context),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.5),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Booking Details',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      actions: [
        if (booking != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () {
              context.push('/chat/${booking!.providerId}');
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A0E27),
                  const Color(0xFF1A1F3A),
                  const Color(0xFF0A0E27),
                ]
              : [
                  const Color(0xFFF5F7FA),
                  const Color(0xFFE8EAF6),
                  const Color(0xFFF5F7FA),
                ],
        ),
      ),
      child: Center(
        child: _GlassContainer(
          child: const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A0E27),
                  const Color(0xFF1A1F3A),
                  const Color(0xFF0A0E27),
                ]
              : [
                  const Color(0xFFF5F7FA),
                  const Color(0xFFE8EAF6),
                  const Color(0xFFF5F7FA),
                ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 20),
                if (booking!.service != null) ...[
                  _buildServiceCard(),
                  const SizedBox(height: 20),
                ],
                if (booking!.provider != null) ...[
                  _buildProviderCard(),
                  const SizedBox(height: 20),
                ],
                _buildScheduleCard(),
                const SizedBox(height: 20),
                if (booking!.customerNotes != null) ...[
                  _buildNotesCard(),
                  const SizedBox(height: 20),
                ],
                _buildTimelineSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(booking!.status).withOpacity(0.3),
                            _getStatusColor(booking!.status).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatusIcon(booking!.status),
                        color: _getStatusColor(booking!.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(booking!.status).withOpacity(0.3),
                        _getStatusColor(booking!.status).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(booking!.status).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    Formatters.formatBookingStatus(booking!.status),
                    style: TextStyle(
                      color: _getStatusColor(booking!.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ]
                      : [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.0),
                        ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID',
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    booking!.id.substring(0, 8).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (booking!.service!.imageUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: booking!.service!.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  booking!.service!.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.2),
                        const Color(0xFF4CAF50).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: Color(0xFF6C63FF),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Formatters.formatCurrency(booking!.totalPrice),
                        style: TextStyle(
                          fontSize: 24,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: booking!.provider!.businessLogoUrl != null
                    ? CachedNetworkImageProvider(
                        booking!.provider!.businessLogoUrl!)
                    : null,
                child: booking!.provider!.businessLogoUrl == null
                    ? Text(
                        booking!.provider!.businessName[0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                    'Provider',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black45,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking!.provider!.businessName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          booking!.provider!.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _GlassContainer(
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildScheduleItem(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: Formatters.formatDate(booking!.bookingDate),
              color: const Color(0xFF6C63FF),
            ),
            const SizedBox(height: 16),
            _buildScheduleItem(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value:
                  '${Formatters.formatTime(booking!.startTime)} - ${Formatters.formatTime(booking!.endTime)}',
              color: const Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _GlassContainer(
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.note_alt_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              child: Text(
                booking!.customerNotes!,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Booking Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          return _buildTimelineItem(
            event: event,
            isLast: index == events.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem({
    required Map<String, dynamic> event,
    required bool isLast,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventType = event['event_type'] as String;
    final createdAt = DateTime.parse(event['created_at'] as String);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getEventColor(eventType),
                    _getEventColor(eventType).withOpacity(0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getEventColor(eventType).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getEventIcon(eventType),
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getEventColor(eventType).withOpacity(0.5),
                      isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getEventTitle(eventType),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          Formatters.formatDateTime(createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.black54,
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
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_outlined;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFB300);
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFFF6B6B);
      case 'completed':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'created':
        return Icons.add_circle_outline;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'created':
        return const Color(0xFF2196F3);
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFFF6B6B);
      case 'completed':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String _getEventTitle(String eventType) {
    switch (eventType) {
      case 'created':
        return 'Booking Created';
      case 'confirmed':
        return 'Booking Confirmed';
      case 'cancelled':
        return 'Booking Cancelled';
      case 'completed':
        return 'Booking Completed';
      default:
        return eventType;
    }
  }
}

// ============================================
// Glass Container Widget - Reusable Component
// ============================================
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}

