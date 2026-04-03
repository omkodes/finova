import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<TransactionAddRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        await repository.addTransaction(event.transaction);
        emit(TransactionOperationSuccess());
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<TransactionFetchRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transactions = await repository.getTransactions();
        emit(TransactionLoaded(transactions));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<TransactionUpdateRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        await repository.updateTransaction(event.transaction);
        emit(TransactionOperationSuccess());
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });

    on<TransactionDeleteRequested>((event, emit) async {
      emit(TransactionLoading());
      try {
        await repository.deleteTransaction(event.id);
        emit(TransactionOperationSuccess());
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });
  }
}
