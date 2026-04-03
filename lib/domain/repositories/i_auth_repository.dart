import '../entities/user_account.dart';

abstract class IAuthRepository {
  Future<UserAccount> signUp(String email, String password, String name);
  Future<UserAccount> login(String email, String password);
  Future<void> logout();
  Future<UserAccount?> getCurrentUser();
  Future<UserAccount> completeOnboarding(String email, double balance, double budget);
  Future<UserAccount> updateUserProfile({
    required String email,
    String? name,
    double? monthlyBudget,
    String? profileImagePath,
  });
  Future<void> deleteAccount(String email);
}
