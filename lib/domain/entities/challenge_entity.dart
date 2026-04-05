import 'package:equatable/equatable.dart';

enum ChallengeType { noSpend }

class ChallengeEntity extends Equatable {
  final int? id;
  final ChallengeType type;
  final double? limitAmount;
  final DateTime startDate;
  final int streakCount;
  final bool isActive;

  const ChallengeEntity({
    this.id,
    required this.type,
    this.limitAmount,
    required this.startDate,
    required this.streakCount,
    required this.isActive,
  });

  ChallengeEntity copyWith({
    int? id,
    ChallengeType? type,
    double? limitAmount,
    DateTime? startDate,
    int? streakCount,
    bool? isActive,
  }) {
    return ChallengeEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      limitAmount: limitAmount ?? this.limitAmount,
      startDate: startDate ?? this.startDate,
      streakCount: streakCount ?? this.streakCount,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'limitAmount': limitAmount,
      'startDate': startDate.toIso8601String(),
      'streakCount': streakCount,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory ChallengeEntity.fromMap(Map<String, dynamic> map) {
    return ChallengeEntity(
      id: map['id']?.toInt(),
      type: ChallengeType.values[map['type'] ?? 0],
      limitAmount: map['limitAmount']?.toDouble(),
      startDate: DateTime.parse(map['startDate']),
      streakCount: map['streakCount']?.toInt() ?? 0,
      isActive: (map['isActive'] ?? 1) == 1,
    );
  }

  @override
  List<Object?> get props => [id, type, limitAmount, startDate, streakCount, isActive];
}
