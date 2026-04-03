import 'package:equatable/equatable.dart'; // Recommended for Blocs
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';

// --- Events ---
sealed class InsightsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InsightsFetchRequested extends InsightsEvent {
  final int month;
  final int year;

  InsightsFetchRequested({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

// --- States ---
sealed class InsightsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsLoaded extends InsightsState {
  final double totalSpent;
  final String biggestCategory;
  final double weeklyAvg;
  final Map<String, double> categoryTotals;

  InsightsLoaded({
    required this.totalSpent,
    required this.biggestCategory,
    required this.weeklyAvg,
    required this.categoryTotals,
  });

  @override
  List<Object?> get props => [
    totalSpent,
    biggestCategory,
    weeklyAvg,
    categoryTotals,
  ];
}

class InsightsError extends InsightsState {
  final String message;
  InsightsError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final TransactionRepository transactionRepository;

  InsightsBloc(this.transactionRepository) : super(InsightsInitial()) {
    on<InsightsFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    InsightsFetchRequested event,
    Emitter<InsightsState> emit,
  ) async {
    emit(InsightsLoading());

    try {
      final transactions = await transactionRepository.getTransactions();

      double totalSpent = 0;
      final categoryTotals = <String, double>{};

      for (final tx in transactions) {
        // Ensure we only calculate expenses
        if (tx.type == DomainTransactionType.expense) {
          totalSpent += tx.amount;
          categoryTotals[tx.category] =
              (categoryTotals[tx.category] ?? 0) + tx.amount;
        }
      }

      // Find the biggest category
      String biggestCat = 'None';
      double maxAmount = 0;

      if (categoryTotals.isNotEmpty) {
        final entry = categoryTotals.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        biggestCat = entry.key;
        maxAmount = entry.value;
      }

      // Accurate Weekly Average Calculation
      // Logic: (Total / Days in Month) * 7
      final daysInMonth = DateTime(event.year, event.month + 1, 0).day;
      final weeklyAvg = totalSpent > 0 ? (totalSpent / daysInMonth) * 7 : 0.0;

      emit(
        InsightsLoaded(
          totalSpent: totalSpent,
          biggestCategory: biggestCat,
          weeklyAvg: weeklyAvg,
          categoryTotals: categoryTotals,
        ),
      );
    } catch (e) {
      emit(InsightsError("Failed to calculate insights: ${e.toString()}"));
    }
  }
}
