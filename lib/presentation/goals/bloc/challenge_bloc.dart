import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/challenge_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/challenge_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────
abstract class ChallengeEvent {}

class ChallengeFetchRequested extends ChallengeEvent {}

class ChallengeStartRequested extends ChallengeEvent {}

class ChallengeStopRequested extends ChallengeEvent {
  final int challengeId;
  ChallengeStopRequested(this.challengeId);
}

// ── States ───────────────────────────────────────────────────────────────────
abstract class ChallengeState {}

class ChallengeInitial extends ChallengeState {}

class ChallengeLoading extends ChallengeState {}

class ChallengeLoaded extends ChallengeState {
  /// The raw entity (null = no active challenge)
  final ChallengeEntity? challenge;

  /// True for each of the 7 days of the current week (Mon=0 … Sun=6).
  /// true  = no-spend day achieved (past day with zero expenses)
  /// false = expense was logged that day OR day not yet reached
  final List<bool> weekDays;

  /// Consecutive days from today going backwards with no expenses
  final int currentStreak;

  ChallengeLoaded({
    required this.challenge,
    required this.weekDays,
    required this.currentStreak,
  });
}

class ChallengeError extends ChallengeState {
  final String message;
  ChallengeError(this.message);
}

// ── Bloc ─────────────────────────────────────────────────────────────────────
class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  final ChallengeRepository challengeRepository;
  final TransactionRepository transactionRepository;

  ChallengeBloc({
    required this.challengeRepository,
    required this.transactionRepository,
  }) : super(ChallengeInitial()) {
    on<ChallengeFetchRequested>(_onFetch);
    on<ChallengeStartRequested>(_onStart);
    on<ChallengeStopRequested>(_onStop);
  }

  Future<void> _onFetch(
    ChallengeFetchRequested event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(ChallengeLoading());
    try {
      final challenge = await challengeRepository.getActiveChallenge();
      final allTxns = await transactionRepository.getTransactions();

      // Build a Set of date strings where expenses occurred  e.g. "2024-04-03"
      final expenseDays = <String>{};
      for (final tx in allTxns) {
        if (tx.type == DomainTransactionType.expense) {
          expenseDays.add(_dateKey(tx.date));
        }
      }

      // ── Week days (Mon-Sun of the current calendar week) ─────────────────
      final today = DateTime.now();
      // weekday: Mon=1, Tue=2 … Sun=7
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final weekDays = List.generate(7, (i) {
        final day = startOfWeek.add(Duration(days: i));
        if (day.isAfter(today)) return false; // future → not achieved yet
        if (day.year == today.year &&
            day.month == today.month &&
            day.day == today.day) {
          // Today: achieved only if no expenses yet today
          return !expenseDays.contains(_dateKey(day));
        }
        // Past day: achieved if no expenses that day
        return !expenseDays.contains(_dateKey(day));
      });

      // ── Current streak: consecutive no-spend days ending today ───────────
      int streak = 0;
      DateTime cursor = today;
      while (true) {
        if (expenseDays.contains(_dateKey(cursor))) break;
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
        // Don't count before the challenge started (if active)
        if (challenge != null && cursor.isBefore(challenge.startDate)) break;
        // Safety: don't go back more than 365 days
        if (streak > 365) break;
      }

      // If no active challenge just show the computed streak for context
      emit(ChallengeLoaded(
        challenge: challenge,
        weekDays: weekDays,
        currentStreak: streak,
      ));
    } catch (e) {
      emit(ChallengeError('Failed to load challenge: $e'));
    }
  }

  Future<void> _onStart(
    ChallengeStartRequested event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      final newChallenge = ChallengeEntity(
        type: ChallengeType.noSpend,
        startDate: DateTime.now(),
        streakCount: 0,
        isActive: true,
      );
      await challengeRepository.startChallenge(newChallenge);
      add(ChallengeFetchRequested());
    } catch (e) {
      emit(ChallengeError('Failed to start challenge: $e'));
    }
  }

  Future<void> _onStop(
    ChallengeStopRequested event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      await challengeRepository.stopChallenge(event.challengeId);
      add(ChallengeFetchRequested());
    } catch (e) {
      emit(ChallengeError('Failed to stop challenge: $e'));
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
