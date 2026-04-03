import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/sqflite_database_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  static const String _sessionKey = 'current_user_email';

  @override
  Future<UserAccount> signUp(String email, String password, String name) async {
    final db = await SqfliteDatabaseService.database;

    // Check if user exists
    final List<Map<String, dynamic>> existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('User already exists');
    }

    final id = await db.insert(
      'users',
      {
        'email': email,
        'name': name,
        'password': password, // Real-world apps should hash this
        'startingBalance': 0.0,
        'monthlyBudget': 0.0,
        'hasCompletedOnboarding': 0, // 0 for false in SQLite
      },
    );

    // Return the created user without saving the session (forces manual login)
    return UserAccount(
      id: id,
      email: email,
      name: name,
      startingBalance: 0.0,
      monthlyBudget: 0.0,
      hasCompletedOnboarding: false,
      profileImagePath: null,
    );
  }

  @override
  Future<UserAccount> login(String email, String password) async {
    final db = await SqfliteDatabaseService.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isEmpty || users.first['password'] != password) {
      throw Exception('Invalid email or password');
    }

    await _saveSession(email);

    final user = users.first;
    return UserAccount(
      id: user['id'] as int,
      email: user['email'] as String,
      name: user['name'] as String,
      startingBalance: user['startingBalance'] as double,
      monthlyBudget: user['monthlyBudget'] as double,
      hasCompletedOnboarding: (user['hasCompletedOnboarding'] as int) == 1,
      profileImagePath: user['profileImagePath'] as String?,
    );
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  @override
  Future<UserAccount?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;

    final db = await SqfliteDatabaseService.database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isEmpty) return null;

    final user = users.first;
    return UserAccount(
      id: user['id'] as int,
      email: user['email'] as String,
      name: user['name'] as String,
      startingBalance: user['startingBalance'] as double,
      monthlyBudget: user['monthlyBudget'] as double,
      hasCompletedOnboarding: (user['hasCompletedOnboarding'] as int) == 1,
      profileImagePath: user['profileImagePath'] as String?,
    );
  }

  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  @override
  Future<UserAccount> completeOnboarding(String email, double balance, double budget) async {
    final db = await SqfliteDatabaseService.database;

    await db.update(
      'users',
      {
        'startingBalance': balance,
        'monthlyBudget': budget,
        'hasCompletedOnboarding': 1,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isEmpty) throw Exception('User not found after update');

    final user = users.first;
    return UserAccount(
      id: user['id'] as int,
      email: user['email'] as String,
      name: user['name'] as String,
      startingBalance: user['startingBalance'] as double,
      monthlyBudget: user['monthlyBudget'] as double,
      hasCompletedOnboarding: (user['hasCompletedOnboarding'] as int) == 1,
      profileImagePath: user['profileImagePath'] as String?,
    );
  }

  @override
  Future<UserAccount> updateUserProfile({
    required String email,
    String? name,
    double? monthlyBudget,
    String? profileImagePath,
  }) async {
    final db = await SqfliteDatabaseService.database;

    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (monthlyBudget != null) updates['monthlyBudget'] = monthlyBudget;
    if (profileImagePath != null) updates['profileImagePath'] = profileImagePath;

    if (updates.isNotEmpty) {
      await db.update(
        'users',
        updates,
        where: 'email = ?',
        whereArgs: [email],
      );
    }

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isEmpty) throw Exception('User not found after update');

    final user = users.first;
    return UserAccount(
      id: user['id'] as int,
      email: user['email'] as String,
      name: user['name'] as String,
      startingBalance: user['startingBalance'] as double,
      monthlyBudget: user['monthlyBudget'] as double,
      hasCompletedOnboarding: (user['hasCompletedOnboarding'] as int) == 1,
      profileImagePath: user['profileImagePath'] as String?,
    );
  }

  @override
  Future<void> deleteAccount(String email) async {
    final db = await SqfliteDatabaseService.database;
    await logout(); // Clear session first
    await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
