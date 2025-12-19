// lib/features/availability/availability_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../auth/auth_provider.dart';
import 'availability_provider.dart';
import 'widgets/availability_slot_card.dart';
import 'widgets/add_slot_dialog.dart';

class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(availabilitySlotsProvider);

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
            'Availability',
            style: TextStyle(
              color: Color(0xFF06b6d4),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF06b6d4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF06b6d4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF06b6d4),
                  size: 20,
                ),
                onPressed: () => _showAddSlotDialog(context, ref),
                tooltip: 'Add Time Slot',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        body: slotsAsync.when(
          data: (slots) {
            if (slots.isEmpty) {
              return _buildEmptyView(context, ref);
            }

            // Group slots by day of week
            final groupedSlots = <int, List<dynamic>>{};
            for (final slot in slots) {
              groupedSlots.putIfAbsent(slot.dayOfWeek, () => []).add(slot);
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(availabilitySlotsProvider);
              },
              color: const Color(0xFF06b6d4),
              backgroundColor: const Color(0xFF1e293b),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final dayOfWeek = index;
                  final daySlots = groupedSlots[dayOfWeek] ?? [];

                  return AvailabilitySlotCard(
                    dayOfWeek: dayOfWeek,
                    slots: daySlots,
                    onDelete: (slotId) async {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Delete Time Slot',
                        message: 'Are you sure you want to delete this time slot?',
                        confirmText: 'Delete',
                        isDestructive: true,
                      );

                      if (confirmed == true) {
                        await ref
                            .read(availabilityControllerProvider.notifier)
                            .deleteSlot(slotId);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Time slot deleted'),
                              backgroundColor: const Color(0xFF1e293b),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
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
          error: (error, stack) => ErrorView(
            message: 'Failed to load availability: ${error.toString()}',
            onRetry: () {
              ref.invalidate(availabilitySlotsProvider);
            },
          ),
        ),
        floatingActionButton: slotsAsync.maybeWhen(
          data: (slots) => slots.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF06b6d4).withOpacity(0.8),
                        const Color(0xFF0891b2).withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () => _showAddSlotDialog(context, ref),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    label: const Text(
                      'Add Slot',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : null,
          orElse: () => null,
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, WidgetRef ref) {
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
                  Icons.event_available,
                  size: 48,
                  color: Color(0xFF06b6d4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Availability Set',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06b6d4),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set your available time slots so customers can book your services',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF06b6d4).withOpacity(0.8),
                      const Color(0xFF0891b2).withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06b6d4).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddSlotDialog(context, ref),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Add Time Slot',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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

  void _showAddSlotDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddSlotDialog(
        onAdd: (dayOfWeek, startTime, endTime) async {
          final provider = await ref.read(currentProviderProvider.future);
          if (provider == null) return;

          final startTimeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
          final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

          await ref.read(availabilityControllerProvider.notifier).addSlot(
                providerId: provider.id,
                dayOfWeek: dayOfWeek,
                startTime: startTimeStr,
                endTime: endTimeStr,
              );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added slot for ${AppConstants.daysOfWeek[dayOfWeek]}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF1e293b),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
