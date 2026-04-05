import 'package:sqflite/sqflite.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/sqflite_database_service.dart';

class GoalRepositoryImpl implements GoalRepository {
  @override
  Future<void> addGoal(GoalEntity goal) async {
    final db = await SqfliteDatabaseService.database;
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateGoal(GoalEntity goal) async {
    final db = await SqfliteDatabaseService.database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(int id) async {
    final db = await SqfliteDatabaseService.database;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<GoalEntity>> getGoalsByMonth(int month, int year) async {
    final db = await SqfliteDatabaseService.database;
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
    final db = await SqfliteDatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return GoalEntity.fromMap(maps[i]);
    });
  }
}
