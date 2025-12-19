import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/config/supabase_config.dart';
import '../../core/config/app_constants.dart';
import '../../core/models/service_model.dart';
import '../../core/models/provider_model.dart';
import '../../core/utils/formatters.dart';
import '../../core/errors/app_exception.dart';
import 'bookings_provider.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final ServiceModel service;
  final ProviderModel provider;

  const BookingFlowScreen({
    super.key,
    required this.service,
    required this.provider,
  });

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _currentStep = 0;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final _notesController = TextEditingController();
  List<String> _availableTimeSlots = [];
  bool _isLoadingSlots = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    try {
      setState(() {
        _isLoadingSlots = true;
      });

      final supabase = SupabaseConfig.client;
      final dayOfWeek = _selectedDate!.weekday % 7;
      final dateString = _selectedDate!.toIso8601String().split('T')[0];

      final availabilityResponse = await supabase
          .from('availability_slots')
          .select()
          .eq('provider_id', widget.provider.id)
          .eq('day_of_week', dayOfWeek)
          .eq('is_active', true);

      if ((availabilityResponse as List).isEmpty) {
        setState(() {
          _availableTimeSlots = [];
          _isLoadingSlots = false;
        });
        return;
      }

      final bookingsResponse = await supabase
          .from('bookings')
          .select('start_time, end_time')
          .eq('provider_id', widget.provider.id)
          .eq('booking_date', dateString)
          .inFilter('status', [
        AppConstants.bookingStatusPending,
        AppConstants.bookingStatusConfirmed,
      ]);

      final allSlots = List<String>.from(AppConstants.timeSlots);
      final bookedSlots = (bookingsResponse as List)
          .map((b) => b['start_time'] as String)
          .toList();

      final available =
          allSlots.where((slot) => !bookedSlots.contains(slot)).toList();

      setState(() {
        _availableTimeSlots = available;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSlots = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(AppException.getErrorMessage(e))),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');
    final startHour = int.parse(parts[0]);
    final startMinute = int.parse(parts[1]);

    final totalMinutes = startHour * 60 + startMinute + durationMinutes;
    final endHour = totalMinutes ~/ 60;
    final endMinute = totalMinutes % 60;

    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select date and time'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      final endTime =
          _calculateEndTime(_selectedTimeSlot!, widget.service.durationMinutes);

      await ref.read(bookingsProvider.notifier).createBooking(
            providerId: widget.provider.id,
            serviceId: widget.service.id,
            bookingDate: _selectedDate!,
            startTime: _selectedTimeSlot!,
            endTime: endTime,
            totalPrice: widget.service.price,
            customerNotes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      if (mounted) {
        context.go('/bookings');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Booking created successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(AppException.getErrorMessage(e))),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo[600]!,
                    Colors.indigo[400]!,
                    Colors.blue[400]!,
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Book Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                height: 1.2,
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

          // Progress Indicator
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Date', Icons.calendar_today_rounded),
                  _buildStepConnector(0),
                  _buildStepIndicator(1, 'Time', Icons.access_time_rounded),
                  _buildStepConnector(1),
                  _buildStepIndicator(2, 'Review', Icons.check_circle_rounded),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_currentStep == 0) _buildDateStep(),
                  if (_currentStep == 1) _buildTimeStep(),
                  if (_currentStep == 2) _buildReviewStep(),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.indigo[600],
                              side: BorderSide(color: Colors.indigo[200]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: _currentStep > 0 ? 1 : 2,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo[600]!,
                                Colors.blue[400]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentStep == 0) {
                                if (_selectedDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.error_outline,
                                              color: Colors.white),
                                          SizedBox(width: 12),
                                          Text('Please select a date'),
                                        ],
                                      ),
                                      backgroundColor: Colors.red[600],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _currentStep = 1;
                                });
                              } else if (_currentStep == 1) {
                                if (_selectedTimeSlot == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.error_outline,
                                              color: Colors.white),
                                          SizedBox(width: 12),
                                          Text('Please select a time slot'),
                                        ],
                                      ),
                                      backgroundColor: Colors.red[600],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _currentStep = 2;
                                });
                              } else if (_currentStep == 2) {
                                _confirmBooking();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _currentStep == 2 ? 'Confirm' : 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isComplete = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [Colors.indigo[600]!, Colors.blue[400]!],
                  )
                : null,
            color: isActive ? null : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isComplete ? Icons.check_rounded : icon,
            color: isActive ? Colors.white : Colors.grey[400],
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.indigo[600] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = _currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [Colors.indigo[600]!, Colors.blue[400]!],
                )
              : null,
          color: isActive ? null : Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildDateStep() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.indigo[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a date for your booking',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedTimeSlot = null;
                  _availableTimeSlots = [];
                });
                _loadAvailableTimeSlots();
              },
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.indigo[600], size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Selected: ${Formatters.formatDate(_selectedDate!)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeStep() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: Colors.indigo[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an available time slot',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoadingSlots)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_availableTimeSlots.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_rounded,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No available time slots for this date',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableTimeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = slot;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.indigo[600]!,
                                  Colors.blue[400]!,
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.indigo[600]!
                              : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        Formatters.formatTime(slot),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      children: [
        // Service Summary Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.indigo[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.design_services_rounded, 'Service',
                    widget.service.title),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.business_rounded, 'Provider',
                    widget.provider.businessName),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.payments_rounded, 'Price',
                    Formatters.formatCurrency(widget.service.price)),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.timer_rounded, 'Duration',
                    Formatters.formatDuration(widget.service.durationMinutes)),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today_rounded, 'Date',
                      Formatters.formatDate(_selectedDate!)),
                ],
                if (_selectedTimeSlot != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time_rounded, 'Time',
                      Formatters.formatTime(_selectedTimeSlot!)),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),

        // Notes Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.note_rounded,
                        color: Colors.indigo[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Must Fill Information *',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Must Provide your complete address and contact number here...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                    maxLength: 500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}





