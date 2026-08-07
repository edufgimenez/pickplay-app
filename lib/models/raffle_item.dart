import 'package:uuid/uuid.dart';

class RaffleItem {
  final String id;
  final String title;
  final String category; // 'movies', 'series', 'games', or custom
  final String monthKey; // Format: "YYYY-MM"
  bool isDrawn;
  bool isCompleted;
  final DateTime createdAt;

  RaffleItem({
    String? id,
    required this.title,
    required this.category,
    required this.monthKey,
    this.isDrawn = false,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'monthKey': monthKey,
      'isDrawn': isDrawn,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RaffleItem.fromJson(Map<String, dynamic> json) {
    return RaffleItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      monthKey: json['monthKey'] as String,
      isDrawn: json['isDrawn'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  RaffleItem copyWith({
    String? title,
    String? category,
    String? monthKey,
    bool? isDrawn,
    bool? isCompleted,
  }) {
    return RaffleItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      monthKey: monthKey ?? this.monthKey,
      isDrawn: isDrawn ?? this.isDrawn,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
