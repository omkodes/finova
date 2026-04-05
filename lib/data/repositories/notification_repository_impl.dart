import 'package:sqflite/sqflite.dart';
import '../../domain/models/app_notification.dart';
import '../datasources/sqflite_database_service.dart';

class NotificationRepositoryImpl {
  Future<Database> get _db async => await SqfliteDatabaseService.database;

  Future<int> insertNotification(AppNotification notification) async {
    final db = await _db;
    return await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppNotification>> getNotifications() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return AppNotification.fromMap(maps[i]);
    });
  }

  Future<void> markAsRead(int id) async {
    final db = await _db;
    await db.update(
      'notifications',
      {'isUnread': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUnreadCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) FROM notifications WHERE isUnread = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
