// lib/features/availability/widgets/availability_slot_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';

class AvailabilitySlotCard extends StatelessWidget {
  final int dayOfWeek;
  final List slots;
  final Function(String slotId) onDelete;

  const AvailabilitySlotCard({
    super.key,
    required this.dayOfWeek,
    required this.slots,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF06b6d4).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF06b6d4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06b6d4).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: Color(0xFF06b6d4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _dayName(dayOfWeek),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF06b6d4),
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06b6d4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${slots.length}',
                    style: TextStyle(
                      color: const Color(0xFF06b6d4).withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: slots.map((slot) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06b6d4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06b6d4).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF06b6d4).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Color(0xFF06b6d4),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06b6d4).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    slot.startTime,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: const Color(0xFF06b6d4).withOpacity(0.6),
                                    size: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06b6d4).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    slot.endTime,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              onPressed: () => onDelete(slot.id),
                              tooltip: 'Delete',
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayName(int day) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[day % 7];
  }
}


// // lib/features/availability/widgets/availability_slot_card.dart
// import 'package:flutter/material.dart';
// import '../../../core/theme/app_colors.dart';

// class AvailabilitySlotCard extends StatelessWidget {
//   final int dayOfWeek;
//   final List slots;
//   final Function(String slotId) onDelete;

//   const AvailabilitySlotCard({
//     super.key,
//     required this.dayOfWeek,
//     required this.slots,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (slots.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           _dayName(dayOfWeek),
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Column(
//           children: slots.map((slot) {
//             return Card(
//               color: AppColors.surface,
//               margin: const EdgeInsets.symmetric(vertical: 4),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 title: Text('${slot.startTime} - ${slot.endTime}'),
//                 trailing: IconButton(
//                   icon: Icon(Icons.delete, color: AppColors.error),
//                   onPressed: () => onDelete(slot.id),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   String _dayName(int day) {
//     const days = [
//       'Monday', 'Tuesday', 'Wednesday', 'Thursday',
//       'Friday', 'Saturday', 'Sunday'
//     ];
//     return days[day % 7];
//   }
// }
