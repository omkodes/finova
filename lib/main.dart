import 'package:finova/presentation/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/sqflite_database_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/challenge_repository_impl.dart';
import 'data/repositories/goal_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/screens/login_screen.dart';
import 'presentation/goals/bloc/challenge_bloc.dart';
import 'presentation/goals/bloc/goal_bloc.dart';
import 'presentation/home/bloc/transaction_bloc.dart';
import 'presentation/insights/bloc/insights_bloc.dart';
import 'presentation/onboarding/screens/onboarding_screen.dart';
import 'presentation/theme/theme_cubit.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyTenPMNotification();

  // Pre-initialize standard connection to Sqflite
  await SqfliteDatabaseService.database;

  runApp(const FinovaApp());
}

class FinovaApp extends StatelessWidget {
  const FinovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepositoryImpl()),
        RepositoryProvider(create: (context) => TransactionRepositoryImpl()),
        RepositoryProvider(create: (context) => GoalRepositoryImpl()),
        RepositoryProvider(create: (context) => ChallengeRepositoryImpl()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepositoryImpl>())
                  ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) =>
                TransactionBloc(context.read<TransactionRepositoryImpl>())
                  ..add(TransactionFetchRequested()),
          ),
          BlocProvider(
            create: (context) => GoalBloc(context.read<GoalRepositoryImpl>()),
          ),
          BlocProvider(
            create: (context) => ChallengeBloc(
              challengeRepository: context.read<ChallengeRepositoryImpl>(),
              transactionRepository: context.read<TransactionRepositoryImpl>(),
            )..add(ChallengeFetchRequested()),
          ),
          BlocProvider(
            create: (context) =>
                InsightsBloc(context.read<TransactionRepositoryImpl>()),
          ),
          BlocProvider(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Finova',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              home: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) {
                  return current is AuthAuthenticated ||
                      current is AuthUnauthenticated;
                },
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    if (!state.user.hasCompletedOnboarding) {
                      return const OnboardingScreen();
                    }
                    return const HomeScreen();
                  }
                  return const LoginScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
