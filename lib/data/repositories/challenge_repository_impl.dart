import 'package:sqflite/sqflite.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/sqflite_database_service.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  @override
  Future<ChallengeEntity?> getActiveChallenge() async {
    final db = await SqfliteDatabaseService.database;
    final maps = await db.query(
      'challenges',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'startDate DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ChallengeEntity.fromMap(maps.first);
  }

  @override
  Future<void> startChallenge(ChallengeEntity challenge) async {
    final db = await SqfliteDatabaseService.database;
    // Deactivate any existing challenges first
    await db.update('challenges', {'isActive': 0});
    await db.insert(
      'challenges',
      challenge.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateChallenge(ChallengeEntity challenge) async {
    final db = await SqfliteDatabaseService.database;
    await db.update(
      'challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  @override
  Future<void> stopChallenge(int id) async {
    final db = await SqfliteDatabaseService.database;
    await db.update(
      'challenges',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
