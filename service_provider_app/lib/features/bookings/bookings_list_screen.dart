// lib/features/bookings/bookings_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'bookings_provider.dart';

class BookingsListScreen extends ConsumerStatefulWidget {
  const BookingsListScreen({super.key});

  @override
  ConsumerState<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends ConsumerState<BookingsListScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    // final bookingsAsync = ref.watch(bookingsProvider);
final bookingsAsync = ref.watch(liveBookingsProvider);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0f172a),
            Color(0xFF1e293b),
            Color(0xFF0f172a),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF06b6d4).withOpacity(0.1),
                  const Color(0xFF06b6d4).withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
          title: const Text(
            'Bookings',
            style: TextStyle(
              color: Color(0xFF06b6d4),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    isSelected: _selectedFilter == 'pending',
                    onTap: () => setState(() => _selectedFilter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Confirmed',
                    isSelected: _selectedFilter == 'confirmed',
                    onTap: () => setState(() => _selectedFilter = 'confirmed'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Completed',
                    isSelected: _selectedFilter == 'completed',
                    onTap: () => setState(() => _selectedFilter = 'completed'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bookingsAsync.when(
                data: (bookings) {
                  final filteredBookings = _selectedFilter == 'all'
                      ? bookings
                      : bookings.where((b) => b.status == _selectedFilter).toList();

                  if (filteredBookings.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06b6d4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF06b6d4).withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF06b6d4).withOpacity(0.1),
                                blurRadius: 25,
                                spreadRadius: 3,
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
                                  border: Border.all(
                                    color: const Color(0xFF06b6d4).withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 48,
                                  color: Color(0xFF06b6d4),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Bookings',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF06b6d4),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bookings will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      final customer = booking.customer;
                      final customerName = customer?.fullName ?? 
                                         customer?.email?.split('@').first ?? 
                                         'Customer';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06b6d4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF06b6d4).withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06b6d4).withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: InkWell(
                              onTap: () => context.push('/bookings/${booking.id}'),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                booking.service?.title ?? 'Service',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF06b6d4).withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 12,
                                                      color: Color(0xFF06b6d4),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      customerName,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white.withOpacity(0.7),
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
                                        const SizedBox(width: 8),
                                        _StatusChip(status: booking.status),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF06b6d4).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Color(0xFF06b6d4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          Formatters.date(booking.bookingDate),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF06b6d4).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Color(0xFF06b6d4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${booking.startTime} - ${booking.endTime}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF06b6d4).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF06b6d4).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: Color(0xFF06b6d4),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            Formatters.currency(booking.totalPrice),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF06b6d4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06b6d4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                    ),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06b6d4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.redAccent.withOpacity(0.8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06b6d4).withOpacity(0.2)
              : const Color(0xFF06b6d4).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06b6d4).withOpacity(0.5)
                : const Color(0xFF06b6d4).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF06b6d4).withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF06b6d4)
                : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orangeAccent;
        icon = Icons.schedule;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blueAccent;
        icon = Icons.check_circle;
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.greenAccent;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.redAccent;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = const Color(0xFF06b6d4).withOpacity(0.15);
        textColor = const Color(0xFF06b6d4);
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


