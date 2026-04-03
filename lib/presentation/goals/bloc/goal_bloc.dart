import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../../domain/repositories/goal_repository.dart';

// Events
abstract class GoalEvent {}
class GoalFetchRequested extends GoalEvent {
  final int month;
  final int year;
  GoalFetchRequested(this.month, this.year);
}
class GoalAddRequested extends GoalEvent {
  final GoalEntity goal;
  GoalAddRequested(this.goal);
}
class GoalUpdateRequested extends GoalEvent {
  final GoalEntity goal;
  GoalUpdateRequested(this.goal);
}

// States
abstract class GoalState {}
class GoalInitial extends GoalState {}
class GoalLoading extends GoalState {}
class GoalLoaded extends GoalState {
  final List<GoalEntity> goals;
  GoalLoaded(this.goals);
}
class GoalError extends GoalState {
  final String message;
  GoalError(this.message);
}

// Bloc
class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository repository;

  GoalBloc(this.repository) : super(GoalInitial()) {
    on<GoalFetchRequested>((event, emit) async {
      emit(GoalLoading());
      try {
        final goals = await repository.getGoalsByMonth(event.month, event.year);
        emit(GoalLoaded(goals));
      } catch (e) {
        emit(GoalError(e.toString()));
      }
    });

    on<GoalAddRequested>((event, emit) async {
      try {
        await repository.addGoal(event.goal);
        add(GoalFetchRequested(event.goal.month, event.goal.year));
      } catch (e) {
        emit(GoalError(e.toString()));
      }
    });

    on<GoalUpdateRequested>((event, emit) async {
      try {
        await repository.updateGoal(event.goal);
        add(GoalFetchRequested(event.goal.month, event.goal.year));
      } catch (e) {
        emit(GoalError(e.toString()));
      }
    });
  }
}
