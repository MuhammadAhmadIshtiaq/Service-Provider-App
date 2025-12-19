// lib/features/bookings/widgets/booking_status_chip.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BookingStatusChip extends StatelessWidget {
  final String status;

  const BookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import '../../../core/theme/app_colors.dart';

// class BookingStatusChip extends StatelessWidget {
//   final String status;

//   const BookingStatusChip({super.key, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor;
//     Color textColor;
//     IconData icon;

//     switch (status.toLowerCase()) {
//       case 'pending':
//         backgroundColor = AppColors.warning.withOpacity(0.2);
//         textColor = AppColors.warning;
//         icon = Icons.schedule;
//         break;
//       case 'confirmed':
//         backgroundColor = AppColors.info.withOpacity(0.2);
//         textColor = AppColors.info;
//         icon = Icons.check_circle;
//         break;
//       case 'completed':
//         backgroundColor = AppColors.success.withOpacity(0.2);
//         textColor = AppColors.success;
//         icon = Icons.done_all;
//         break;
//       case 'cancelled':
//         backgroundColor = AppColors.error.withOpacity(0.2);
//         textColor = AppColors.error;
//         icon = Icons.cancel;
//         break;
//       default:
//         backgroundColor = AppColors.grey200;
//         textColor = AppColors.grey700;
//         icon = Icons.help;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: textColor),
//           const SizedBox(width: 4),
//           Text(
//             status.toUpperCase(),
//             style: TextStyle(
//               color: textColor,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
