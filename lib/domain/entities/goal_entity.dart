import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentSaved;
  final int month;
  final int year;
  final DateTime createdAt;

  const GoalEntity({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentSaved = 0.0,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  GoalEntity copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentSaved,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSaved: currentSaved ?? this.currentSaved,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentSaved': currentSaved,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalEntity.fromMap(Map<String, dynamic> map) {
    return GoalEntity(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      currentSaved: map['currentSaved']?.toDouble() ?? 0.0,
      month: map['month']?.toInt() ?? 1,
      year: map['year']?.toInt() ?? 2024,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        targetAmount,
        currentSaved,
        month,
        year,
        createdAt,
      ];
}
