import 'package:equatable/equatable.dart';

class UserAccount extends Equatable {
  final int id;
  final String email;
  final String name;
  final double startingBalance;
  final double monthlyBudget;
  final bool hasCompletedOnboarding;
  final String? profileImagePath;

  const UserAccount({
    required this.id,
    required this.email,
    required this.name,
    this.startingBalance = 0.0,
    this.monthlyBudget = 0.0,
    this.hasCompletedOnboarding = false,
    this.profileImagePath,
  });

  UserAccount copyWith({
    int? id,
    String? email,
    String? name,
    double? startingBalance,
    double? monthlyBudget,
    bool? hasCompletedOnboarding,
    String? profileImagePath,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      startingBalance: startingBalance ?? this.startingBalance,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        startingBalance,
        monthlyBudget,
        hasCompletedOnboarding,
        profileImagePath,
      ];
}
