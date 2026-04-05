import 'dart:io';
import 'dart:ui';

import 'package:finova/core/theme/app_colors.dart';
import 'package:finova/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/goal_entity.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../home/bloc/transaction_bloc.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../bloc/challenge_bloc.dart';
import '../bloc/goal_bloc.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<GoalBloc>().add(GoalFetchRequested(now.month, now.year));
    context.read<ChallengeBloc>().add(ChallengeFetchRequested());
  }

  void _showEditGoalBottomSheet(
    BuildContext context,
    GoalEntity? existingGoal,
  ) {
    final titleController = TextEditingController(
      text: existingGoal?.title ?? '',
    );
    final targetController = TextEditingController(
      text: existingGoal != null
          ? existingGoal.targetAmount.toStringAsFixed(0)
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainerHighest
                  : AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existingGoal == null ? 'Set New Goal' : 'Edit Goal',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'e.g. New Car Fund',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    hintText: 'e.g. 2000',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final target =
                        double.tryParse(targetController.text.trim()) ?? 0.0;
                    if (title.isNotEmpty && target > 0) {
                      final now = DateTime.now();
                      final newGoal = GoalEntity(
                        id: existingGoal?.id,
                        title: title,
                        targetAmount: target,
                        month: now.month,
                        year: now.year,
                        createdAt: existingGoal?.createdAt ?? now,
                      );

                      if (existingGoal == null) {
                        context.read<GoalBloc>().add(GoalAddRequested(newGoal));
                      } else {
                        context.read<GoalBloc>().add(
                          GoalUpdateRequested(newGoal),
                        );
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    'Save Goal',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');

    return MultiBlocListener(
      listeners: [
        BlocListener<GoalBloc, GoalState>(listener: (context, state) {}),
      ],
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, txnState) {
          BlocBuilder<GoalBloc, GoalState>;
          return BlocBuilder<GoalBloc, GoalState>(
            builder: (context, goalState) {
              // Calculate Dynamic Totals
              double totalSavings = 0.0;
              if (txnState is TransactionLoaded) {
                double income = 0;
                double expense = 0;
                for (var tx in txnState.transactions) {
                  if (tx.type == DomainTransactionType.income)
                    income += tx.amount;
                  if (tx.type == DomainTransactionType.expense)
                    expense += tx.amount;
                }
                totalSavings = income - expense;
              }

              GoalEntity? currentGoal;
              if (goalState is GoalLoaded && goalState.goals.isNotEmpty) {
                currentGoal = goalState.goals.first;
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: colorScheme.background.withOpacity(0.8),
                    elevation: 0,
                    toolbarHeight: 72,
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    title: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final user = (state is AuthAuthenticated)
                            ? state.user
                            : null;
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                                child: ClipOval(
                                  child:
                                      user?.profileImagePath != null &&
                                          user!.profileImagePath!.isNotEmpty
                                      ? Image.file(
                                          File(user.profileImagePath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.person,
                                            color: colorScheme.outline,
                                          ),
                                        )
                                      : Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuArMfGM7cUNMmy0YHaP3-2aKk72tMn3fSdjYLwdLQC5yeV8xFYCTie5QBYUck9q84r1Z7qMdIq4DDIKSOZib4SKcTXO6ugNv62Bfxa4jcdz4wljYWB4KTovSPyBepLxxWiHjM2POtuNqIjeGW3RCjbM_YPpXKcXqd_zMV8kOyNOeA7pE620TN0SbRS8bLLA7nrc3FYtIkvZ9Wmq_AXZC_hMCVvJ7wbo4cwMJWyEJATXUrQoxZZeAN5EFWGwpm-OLykDk6pnyQzKtTc',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.person,
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Finova',
                              style: GoogleFonts.manrope(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_rounded,
                            color: colorScheme.outline,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen(),
                              ),
                            );
                          },
                          splashRadius: 24,
                        ),
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: 120,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Hero Balance Section
                        Text(
                          'TOTAL SAVINGS',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              formatCurrency.format(totalSavings),
                              style: GoogleFonts.manrope(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Monthly Goal Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Monthly Goal',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (currentGoal != null)
                              GestureDetector(
                                onTap: () => _showEditGoalBottomSheet(
                                  context,
                                  currentGoal,
                                ),
                                child: Text(
                                  'Edit Goal',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildMonthlyGoalCard(
                          currentGoal,
                          totalSavings,
                          colorScheme,
                          isDark,
                          context,
                        ),
                        const SizedBox(height: 40),

                        // Active Challenges Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Active Challenges',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildActiveChallengeCard(colorScheme, isDark),
                        const SizedBox(height: 40),

                        // Suggested Challenges
                        Text(
                          'Recommended for You',
                          style: GoogleFonts.manrope(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSuggestedChallengeCard(
                                'Coffee Free Month',
                                'Save up to ₹120',
                                Icons.local_cafe_rounded,
                                colorScheme,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSuggestedChallengeCard(
                                'Walk to Work',
                                'Save on fuel & health',
                                Icons.directions_walk_rounded,
                                colorScheme,
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthlyGoalCard(
    GoalEntity? goal,
    double totalSavings,
    ColorScheme colorScheme,
    bool isDark,
    BuildContext context,
  ) {
    if (goal == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceContainerLowest
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191C1D).withOpacity(0.06),
              offset: const Offset(0, 10),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.flag_rounded,
              size: 48,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No goal set for this month.',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adding a target amount effectively prevents overspending.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _showEditGoalBottomSheet(context, null),
              child: const Text('Add Goal'),
            ),
          ],
        ),
      );
    }

    final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');
    final progress = goal.targetAmount > 0
        ? (totalSavings / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final progressPct = (progress * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLowest
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withOpacity(0.06),
            offset: const Offset(0, 10),
            blurRadius: 40,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$progressPct% Achieved',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: progress >= 1.0
                            ? Colors.green
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatCurrency.format(
                        totalSavings > 0 ? totalSavings : 0,
                      ),
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'of ${formatCurrency.format(goal.targetAmount)} target',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Progress Bar
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: progress >= 1.0
                              ? [Colors.green, Colors.greenAccent.shade700]
                              : [
                                  colorScheme.primary,
                                  colorScheme.primaryContainer,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Footer
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            progress >= 1.0
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                            color: progress >= 1.0
                                ? Colors.green
                                : const Color(0xFFF59E0B),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            progress >= 1.0 ? 'Goal Reached!' : 'Keep going!',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (progress >= 1.0
                                      ? Colors.green
                                      : const Color(0xFFF59E0B))
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          progress >= 1.0
                              ? '"Amazing Job!"'
                              : '"You\'re crushing it!"',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: progress >= 1.0
                                ? Colors.green.shade800
                                : const Color(0xFF684000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChallengeCard(ColorScheme colorScheme, bool isDark) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now();
    // weekday Mon=1…Sun=7, so index in our list = weekday - 1
    final todayIndex = today.weekday - 1;

    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        final isLoaded = state is ChallengeLoaded;
        final challenge = isLoaded ? (state).challenge : null;
        final weekDays = isLoaded ? (state).weekDays : List.filled(7, false);
        final streak = isLoaded ? (state).currentStreak : 0;
        final isActive = challenge != null;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainerLowest
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF191C1D).withOpacity(0.06),
                offset: const Offset(0, 10),
                blurRadius: 40,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ── Banner ─────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? [const Color(0xFF4338CA), const Color(0xFF312E81)]
                        : [colorScheme.surfaceVariant, colorScheme.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Spend Challenge',
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isActive
                                ? 'Keep it up — no unnecessary purchases!'
                                : 'Start today and track your no-spend streak.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isActive
                                  ? Colors.indigo.shade100
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Active badge OR Start button
                    if (isActive)
                      GestureDetector(
                        onTap: () => context
                            .read<ChallengeBloc>()
                            .add(ChallengeStopRequested(challenge!.id!)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'STOP',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.red.shade200,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: () => context
                            .read<ChallengeBloc>()
                            .add(ChallengeStartRequested()),
                        child: const Text('START'),
                      ),
                  ],
                ),
              ),

              // ── Body ───────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT STREAK',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              streak == 1 ? '1 Day 🔥' : '$streak Days ${streak > 1 ? "🔥" : ""}',
                              style: GoogleFonts.manrope(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: streak > 0
                                    ? const Color(0xFFF59E0B)
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'STATUS',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              isActive ? 'Active ✅' : 'Inactive',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.green
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Weekly tracker ─────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        if (i > todayIndex) {
                          return _buildDayTrackerFuture(dayLabels[i], colorScheme);
                        } else if (i == todayIndex) {
                          return _buildDayTrackerCurrent(
                            dayLabels[i],
                            colorScheme,
                            achieved: weekDays.length > i && weekDays[i],
                          );
                        } else {
                          return _buildDayTracker(
                            dayLabels[i],
                            weekDays.length > i && weekDays[i],
                            colorScheme,
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDayTracker(String day, bool completed, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: completed
                ? colorScheme.secondary
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: completed
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
      ],
    );
  }

  Widget _buildDayTrackerCurrent(String day, ColorScheme colorScheme, {bool achieved = false}) {
    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: achieved ? colorScheme.secondary : colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: achieved ? colorScheme.secondary : Colors.transparent,
            border: achieved ? null : Border.all(
              color: colorScheme.primary,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: achieved
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : Icon(Icons.circle_outlined, color: colorScheme.primary, size: 20),
        ),
      ],
    );
  }

  Widget _buildDayTrackerFuture(String day, ColorScheme colorScheme) {
    return Opacity(
      opacity: 0.3,
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedChallengeCard(
    String title,
    String subtitle,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
