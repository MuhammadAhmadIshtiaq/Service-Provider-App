// lib/features/availability/widgets/add_slot_dialog.dart
import 'package:flutter/material.dart';
import 'package:service_provider_app/core/config/app_constants.dart';
import 'package:service_provider_app/core/theme/app_colors.dart';
import 'dart:ui';

typedef OnAddSlot = Future<void> Function(int dayOfWeek, TimeOfDay startTime, TimeOfDay endTime);

class AddSlotDialog extends StatefulWidget {
  final OnAddSlot onAdd;

  const AddSlotDialog({super.key, required this.onAdd});

  @override
  State<AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends State<AddSlotDialog> {
  int selectedDay = 1; // Start with Monday (index 1) as default
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF06b6d4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF06b6d4).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06b6d4).withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06b6d4).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF06b6d4).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Color(0xFF06b6d4),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Add Time Slot',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF06b6d4),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF06b6d4).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF06b6d4).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: selectedDay,
                        items: List.generate(
                          7,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(
                              AppConstants.daysOfWeek[index]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) setState(() => selectedDay = value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Day',
                          labelStyle: TextStyle(
                            color: const Color(0xFF06b6d4).withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        dropdownColor: const Color(0xFF1e293b),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: const Color(0xFF06b6d4).withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeButton(
                            context: context,
                            label: 'Start Time',
                            time: startTime,
                            icon: Icons.play_circle_outline,
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime ?? TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF06b6d4),
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF1e293b),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) setState(() => startTime = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTimeButton(
                            context: context,
                            label: 'End Time',
                            time: endTime,
                            icon: Icons.stop_circle_outlined,
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime ?? TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF06b6d4),
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF1e293b),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) setState(() => endTime = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF06b6d4).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF06b6d4).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF06b6d4),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: startTime != null && endTime != null
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF06b6d4).withOpacity(0.8),
                                      const Color(0xFF0891b2).withOpacity(0.8),
                                    ],
                                  )
                                : null,
                            color: startTime == null || endTime == null
                                ? const Color(0xFF06b6d4).withOpacity(0.2)
                                : null,
                            boxShadow: startTime != null && endTime != null
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF06b6d4).withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: startTime != null && endTime != null
                                ? () async {
                                    await widget.onAdd(selectedDay, startTime!, endTime!);
                                    if (context.mounted) Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Add Slot',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton({
    required BuildContext context,
    required String label,
    required TimeOfDay? time,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF06b6d4).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF06b6d4),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: const Color(0xFF06b6d4).withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                time?.format(context) ?? '--:--',
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
    );
  }
}

// // lib/features/availability/widgets/add_slot_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:service_provider_app/core/config/app_constants.dart';
// import 'package:service_provider_app/core/theme/app_colors.dart';

// typedef OnAddSlot = Future<void> Function(int dayOfWeek, TimeOfDay startTime, TimeOfDay endTime);

// class AddSlotDialog extends StatefulWidget {
//   final OnAddSlot onAdd;

//   const AddSlotDialog({super.key, required this.onAdd});

//   @override
//   State<AddSlotDialog> createState() => _AddSlotDialogState();
// }

// class _AddSlotDialogState extends State<AddSlotDialog> {
//   int selectedDay = 0;
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Add Time Slot'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           DropdownButtonFormField<int>(
//             value: selectedDay,
//             items: List.generate(
//               7,
//               (index) => DropdownMenuItem(
//                 value: index,
//                 child: Text(AppConstants.daysOfWeek[index]!),
//               ),
//             ),
//             onChanged: (value) {
//               if (value != null) setState(() => selectedDay = value);
//             },
//             decoration: const InputDecoration(labelText: 'Day'),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () async {
//                     final picked = await showTimePicker(
//                       context: context,
//                       initialTime: TimeOfDay.now(),
//                     );
//                     if (picked != null) setState(() => startTime = picked);
//                   },
//                   child: Text(startTime != null
//                       ? startTime!.format(context)
//                       : 'Start Time'),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () async {
//                     final picked = await showTimePicker(
//                       context: context,
//                       initialTime: TimeOfDay.now(),
//                     );
//                     if (picked != null) setState(() => endTime = picked);
//                   },
//                   child: Text(endTime != null ? endTime!.format(context) : 'End Time'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: startTime != null && endTime != null
//               ? () async {
//                   await widget.onAdd(selectedDay, startTime!, endTime!);
//                   if (context.mounted) Navigator.pop(context);
//                 }
//               : null,
//           child: const Text('Add'),
//         ),
//       ],
//     );
//   }
// }
