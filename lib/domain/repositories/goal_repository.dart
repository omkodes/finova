import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<void> addGoal(GoalEntity goal);
  Future<void> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(int id);
  Future<List<GoalEntity>> getGoalsByMonth(int month, int year);
  Future<List<GoalEntity>> getAllGoals();
}
