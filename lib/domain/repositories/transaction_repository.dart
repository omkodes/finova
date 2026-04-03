import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(TransactionEntity transaction);
  Future<List<TransactionEntity>> getTransactions();
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(int id);
}
