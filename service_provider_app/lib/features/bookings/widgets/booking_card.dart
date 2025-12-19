
// lib/features/bookings/widgets/booking_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/models/booking_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'booking_status_chip.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: onTap,
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
                            if (booking.customer != null)
                              Text(
                                booking.customer!.fullName ?? booking.customer!.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      BookingStatusChip(status: booking.status),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF06b6d4).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
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
                          size: 13,
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
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06b6d4).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 13,
                          color: Color(0xFF06b6d4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${booking.startTime} - ${booking.endTime}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                          size: 15,
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
                  if (booking.customerNotes != null && booking.customerNotes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06b6d4).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF06b6d4).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06b6d4).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.note,
                              size: 12,
                              color: Color(0xFF06b6d4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking.customerNotes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






// // lib/features/bookings/widgets/booking_card.dart
// import 'package:flutter/material.dart';
// import '../../../core/models/booking_model.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/utils/formatters.dart';
// import 'booking_status_chip.dart'; // <-- Add this

// class BookingCard extends StatelessWidget {
//   final BookingModel booking;
//   final VoidCallback? onTap;

//   const BookingCard({
//     super.key,
//     required this.booking,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           booking.service?.title ?? 'Service',
//                           style: Theme.of(context).textTheme.labelLarge,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         if (booking.customer != null)
//                           Text(
//                             booking.customer!.fullName ?? booking.customer!.email,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                       ],
//                     ),
//                   ),
//                   BookingStatusChip(status: booking.status),
//                 ],
//               ),
//               const Divider(height: 24),
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 16, color: AppColors.grey600),
//                   const SizedBox(width: 8),
//                   Text(
//                     Formatters.date(booking.bookingDate),
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   const SizedBox(width: 16),
//                   Icon(Icons.access_time, size: 16, color: AppColors.grey600),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${booking.startTime} - ${booking.endTime}',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(Icons.attach_money, size: 16, color: AppColors.success),
//                   Text(
//                     Formatters.currency(booking.totalPrice),
//                     style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                           color: AppColors.success,
//                         ),
//                   ),
//                 ],
//               ),
//               if (booking.customerNotes != null && booking.customerNotes!.isNotEmpty) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.grey100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(Icons.note, size: 16, color: AppColors.grey600),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           booking.customerNotes!,
//                           style: Theme.of(context).textTheme.bodySmall,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
