part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionAddRequested extends TransactionEvent {
  final TransactionEntity transaction;
  const TransactionAddRequested(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionFetchRequested extends TransactionEvent {}

class TransactionUpdateRequested extends TransactionEvent {
  final TransactionEntity transaction;
  const TransactionUpdateRequested(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleteRequested extends TransactionEvent {
  final int id;
  const TransactionDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}
