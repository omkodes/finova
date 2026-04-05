import 'package:sqflite/sqflite.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/sqflite_database_service.dart';
import '../../domain/models/app_notification.dart';
import 'notification_repository_impl.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final db = await SqfliteDatabaseService.database;
    await db.insert(
      'transactions',
      {
        'amount': transaction.amount,
        'type': transaction.type == DomainTransactionType.income ? 1 : 0,
        'category': transaction.category,
        'date': transaction.date.toIso8601String(),
        'notes': transaction.notes,
        'createdAt': transaction.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    String action = transaction.type == DomainTransactionType.income ? 'received' : 'spent';
    await NotificationRepositoryImpl().insertNotification(
      AppNotification(
        title: 'Transaction alert',
        description: 'Successfully $action ₹${transaction.amount.toStringAsFixed(2)} for ${transaction.category}.',
        type: 'transaction',
        createdAt: DateTime.now(),
      )
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final db = await SqfliteDatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => TransactionEntity(
      id: map['id'] as int,
      amount: map['amount'] as double,
      type: map['type'] == 1 ? DomainTransactionType.income : DomainTransactionType.expense,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    )).toList();
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final db = await SqfliteDatabaseService.database;
    await db.update(
      'transactions',
      {
        'amount': transaction.amount,
        'type': transaction.type == DomainTransactionType.income ? 1 : 0,
        'category': transaction.category,
        'date': transaction.date.toIso8601String(),
        'notes': transaction.notes,
        'createdAt': transaction.createdAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final db = await SqfliteDatabaseService.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
