import 'package:equatable/equatable.dart';

enum DomainTransactionType { income, expense }

class TransactionEntity extends Equatable {
  final int id;
  final double amount;
  final DomainTransactionType type;
  final String category;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  TransactionEntity copyWith({
    int? id,
    double? amount,
    DomainTransactionType? type,
    String? category,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        category,
        date,
        notes,
        createdAt,
      ];
}
