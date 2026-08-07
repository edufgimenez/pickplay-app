import 'package:uuid/uuid.dart';

class RaffleHistoryRecord {
  final String id;
  final String title;
  final String category;
  final String monthKey;
  final DateTime drawnAt;
  String? notes;
  bool isCompleted;

  RaffleHistoryRecord({
    String? id,
    required this.title,
    required this.category,
    required this.monthKey,
    DateTime? drawnAt,
    this.notes,
    this.isCompleted = false,
  })  : id = id ?? const Uuid().v4(),
        drawnAt = drawnAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'monthKey': monthKey,
      'drawnAt': drawnAt.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory RaffleHistoryRecord.fromJson(Map<String, dynamic> json) {
    return RaffleHistoryRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      monthKey: json['monthKey'] as String,
      drawnAt: DateTime.tryParse(json['drawnAt'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
