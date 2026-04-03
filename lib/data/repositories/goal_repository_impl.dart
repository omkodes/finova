import 'package:sqflite/sqflite.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final Database db;

  GoalRepositoryImpl({required this.db});

  @override
  Future<void> addGoal(GoalEntity goal) async {
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateGoal(GoalEntity goal) async {
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(int id) async {
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<GoalEntity>> getGoalsByMonth(int month, int year) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return GoalEntity.fromMap(maps[i]);
    });
  }

  @override
  Future<List<GoalEntity>> getAllGoals() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return GoalEntity.fromMap(maps[i]);
    });
  }
}
