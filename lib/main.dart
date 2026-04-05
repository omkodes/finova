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
import 'presentation/auth/widgets/biometric_wrapper.dart' as finova_auth;
import 'presentation/goals/bloc/challenge_bloc.dart';
import 'presentation/goals/bloc/goal_bloc.dart';
import 'presentation/home/bloc/transaction_bloc.dart';
import 'presentation/insights/bloc/insights_bloc.dart';
import 'presentation/notifications/bloc/notification_bloc.dart';
import 'presentation/notifications/bloc/notification_event.dart';
import 'presentation/onboarding/screens/onboarding_screen.dart';
import 'presentation/theme/theme_cubit.dart';
import 'services/notification_service.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/models/app_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyTenPMNotification();

  // Pre-initialize standard connection to Sqflite
  await SqfliteDatabaseService.database;

  // App Launch Check: Evaluate if the 10 PM daily reminder should be appended to the DB
  final now = DateTime.now();
  if (now.hour >= 22) {
    final notificationRepo = NotificationRepositoryImpl();
    final notifications = await notificationRepo.getNotifications();
    
    // Check if we already have a reminder for today
    final hasTodayReminder = notifications.any((n) => 
        n.type == 'reminder' && 
        n.createdAt.year == now.year && 
        n.createdAt.month == now.month && 
        n.createdAt.day == now.day);
        
    if (!hasTodayReminder) {
      await notificationRepo.insertNotification(
        AppNotification(
          title: 'Daily Expense Reminder',
          description: 'It\'s past 10 PM! Don\'t forget to log today\'s expenses and stay on track with your goals.',
          type: 'reminder',
          createdAt: DateTime(now.year, now.month, now.day, 22, 0),
        )
      );
    }
  }

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
        RepositoryProvider(create: (context) => NotificationRepositoryImpl()),
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
          BlocProvider(
            create: (context) =>
                NotificationBloc(notificationRepository: context.read<NotificationRepositoryImpl>())
                  ..add(LoadNotifications()),
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
              builder: (context, child) {
                // Clamp text scaling to prevent UI layout issues with large system display settings
                final mediaQueryData = MediaQuery.of(context);
                final textScaler = mediaQueryData.textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.0,
                );
                return MediaQuery(
                  data: mediaQueryData.copyWith(textScaler: textScaler),
                  child: child!,
                );
              },
              home: const _AuthGate(),
              onGenerateRoute: (settings) {
                if (settings.name == '/') {
                  return MaterialPageRoute(builder: (_) => const _AuthGate());
                }
                return null;
              },
            );
          },
        ),
      ),
    );
  }
}

/// Decides which screen to show based on auth state.
/// Registered as both `home:` and the `'/'` named route so that
/// [Navigator.pushNamedAndRemoveUntil] after a successful login properly
/// resolves here and the [BlocBuilder] reacts to [AuthAuthenticated].
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is AuthAuthenticated || current is AuthUnauthenticated,
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (!state.user.hasCompletedOnboarding) {
            return const OnboardingScreen();
          }
          return const finova_auth.BiometricWrapper(child: HomeScreen());
        }
        return const LoginScreen();
      },
    );
  }
}
