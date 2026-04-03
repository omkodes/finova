part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionOperationSuccess extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  const TransactionLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String error;
  const TransactionError(this.error);
  @override
  List<Object?> get props => [error];
}
