// lib/core/models/availability_slot_model.dart
class AvailabilitySlotModel {
  final String id;
  final String providerId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;
  final DateTime createdAt;

  AvailabilitySlotModel({
    required this.id,
    required this.providerId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    required this.createdAt,
  });

  factory AvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotModel(
      id: json['id'],
      providerId: json['provider_id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AvailabilitySlotModel copyWith({
    String? id,
    String? providerId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AvailabilitySlotModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

