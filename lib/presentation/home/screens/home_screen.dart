import 'dart:io';
import 'dart:ui';

import 'package:finova/core/theme/app_colors.dart';
import 'package:finova/domain/entities/goal_entity.dart';
import 'package:finova/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../goals/bloc/goal_bloc.dart';
import '../../goals/screens/goals_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/add_transaction_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<GoalBloc>().add(GoalFetchRequested(now.month, now.year));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Content
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboardContent(),
              const TransactionsScreen(),
              const GoalsScreen(),
              const InsightsScreen(),
            ],
          ),

          // Custom Bottom Navigation Bar Shell
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: colorScheme.brightness == Brightness.light
                    ? const Color(0x0F191C1D)
                    : Colors.black26,
                offset: const Offset(0, -10),
                blurRadius: 40,
              ),
            ],
          ),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 24,
            top: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(
                1,
                Icons.account_balance_wallet_rounded,
                'Transact',
              ),

              // Floating Action Button Placeholder (Centered, Raised)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x663525CD), // rgba(53,37,205,0.4)
                        offset: Offset(0, 10),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showAddTransactionBottomSheet(context),
                      borderRadius: BorderRadius.circular(32),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              _buildNavItem(2, Icons.emoji_events_rounded, 'Goals'),
              _buildNavItem(3, Icons.bar_chart_rounded, 'Insights'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final colorScheme = Theme.of(context).colorScheme;
    final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txnState) {
        return BlocBuilder<GoalBloc, GoalState>(
          builder: (context, goalState) {
            List<TransactionEntity> transactions = [];
            if (txnState is TransactionLoaded) {
              transactions = txnState.transactions;
            }

            double totalIncome = 0.0;
            double totalExpense = 0.0;
            double thisMonthExpense = 0.0;
            Map<String, double> categoryTotals = {};
            final now = DateTime.now();

            for (var tx in transactions) {
              if (tx.type == DomainTransactionType.income) {
                totalIncome += tx.amount;
              } else {
                totalExpense += tx.amount;
                if (tx.date.month == now.month && tx.date.year == now.year) {
                  thisMonthExpense += tx.amount;
                  categoryTotals[tx.category] =
                      (categoryTotals[tx.category] ?? 0) + tx.amount;
                }
              }
            }
            double netWorth = totalIncome - totalExpense;

            List<MapEntry<String, double>> topCats =
                categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

            topCats = topCats.take(3).toList();
            double topCatsTotal = topCats.fold(
              0.0,
              (sum, item) => sum + item.value,
            );
            double othersNum = thisMonthExpense - topCatsTotal;
            if (othersNum < 0) othersNum = 0.0;

            String cat1Name = topCats.isNotEmpty ? topCats[0].key : 'None';
            double cat1Pct = thisMonthExpense > 0 && topCats.isNotEmpty
                ? topCats[0].value / thisMonthExpense * 100
                : 0;

            String cat2Name = topCats.length > 1 ? topCats[1].key : 'None';
            double cat2Pct = thisMonthExpense > 0 && topCats.length > 1
                ? topCats[1].value / thisMonthExpense * 100
                : 0;

            String cat3Name = topCats.length > 2 ? topCats[2].key : 'None';
            double cat3Pct = thisMonthExpense > 0 && topCats.length > 2
                ? topCats[2].value / thisMonthExpense * 100
                : 0;

            double othersPct = thisMonthExpense > 0
                ? othersNum / thisMonthExpense * 100
                : 0;

            GoalEntity? currentGoal;
            if (goalState is GoalLoaded && goalState.goals.isNotEmpty) {
              currentGoal = goalState.goals.first as GoalEntity?;
            }

            return CustomScrollView(
              slivers: [
                // Sticky Header Layer
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
                                color: colorScheme.surfaceContainer,
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
                            style: TextStyle(
                              fontFamily: 'Manrope',
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
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final user = (state is AuthAuthenticated)
                            ? state.user
                            : null;
                        return Padding(
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
                        );
                      },
                    ),
                  ],
                ),

                // Body Content
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 16,
                    bottom: 120,
                  ), // bottom padding for nav bar overlay
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. Hero Greeting & Balance
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final user = (state is AuthAuthenticated)
                              ? state.user
                              : null;
                          return Text(
                            'Hi, ${user?.name?.split(' ').first ?? "User"}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 8),

                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatCurrency.format(netWorth),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'TOTAL NET WORTH',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.0,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildSummaryCard(
                                'INCOME',
                                formatCurrency.format(totalIncome),
                                Icons.arrow_upward_rounded,
                                colorScheme.secondary,
                                colorScheme.secondary.withOpacity(0.1),
                              ),
                              const SizedBox(width: 16),
                              _buildSummaryCard(
                                'EXPENSES',
                                formatCurrency.format(totalExpense),
                                Icons.arrow_downward_rounded,
                                colorScheme.error,
                                colorScheme.error.withOpacity(0.1),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 32),

                      // 2. Bento Grid
                      _buildBentoGrid(
                        thisMonthExpense,
                        cat1Name,
                        cat1Pct,
                        cat2Name,
                        cat2Pct,
                        cat3Name,
                        cat3Pct,
                        othersPct,
                        currentGoal,
                        netWorth,
                      ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),

                      const SizedBox(height: 32),

                      // 3. Recent Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentIndex = 1;
                              });
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 16),

                      // Horizontal Timeline List
                      SizedBox(
                        height: 160,
                        child: transactions.isEmpty
                            ? Center(
                                child: Text(
                                  'No recent activity',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                children: transactions.take(5).map((tx) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: _buildTransactionCard(
                                      DateFormat('MMM d').format(tx.date),
                                      tx.category,
                                      tx.notes ?? 'Transaction',
                                      formatCurrency.format(tx.amount),
                                      tx.type == DomainTransactionType.income
                                          ? Icons.account_balance_rounded
                                          : Icons.shopping_bag_rounded,
                                      tx.type == DomainTransactionType.income
                                          ? colorScheme.secondary
                                          : colorScheme.outline,
                                      tx.type == DomainTransactionType.income
                                          ? colorScheme.secondary.withOpacity(
                                              0.1,
                                            )
                                          : colorScheme.surfaceContainer,
                                      isIncome:
                                          tx.type ==
                                          DomainTransactionType.income,
                                    ),
                                  );
                                }).toList(),
                              ),
                      ).animate().fade(duration: 400.ms, delay: 400.ms).slideY(begin: 0.05, end: 0),
                    ]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    String amount,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(
    double thisMonthExpense,
    String cat1Name,
    double cat1Pct,
    String cat2Name,
    double cat2Pct,
    String cat3Name,
    double cat3Pct,
    double othersPct,
    GoalEntity? currentGoal,
    double totalSavings,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analytics Card
            Container(
              width: isWide
                  ? constraints.maxWidth * 0.58 - 12
                  : double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.brightness == Brightness.light
                        ? const Color(0x0F191C1D)
                        : Colors.black26,
                    offset: const Offset(0, 10),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Spending Allocation',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'This Month',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: _DonutChartPainter(
                            colorScheme,
                            cat1Pct,
                            cat2Pct,
                            cat3Pct,
                            othersPct,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatCurrency.format(thisMonthExpense),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'TOTAL SPENT',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final user = (state is AuthAuthenticated) ? state.user : null;
                                final budget = user?.monthlyBudget ?? 0.0;
                                if (budget <= 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'of ${formatCurrency.format(budget)}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(
                        colorScheme.primary,
                        '$cat1Name (${cat1Pct.toStringAsFixed(0)}%)',
                      ),
                      _buildLegendItem(
                        colorScheme.secondary,
                        '$cat2Name (${cat2Pct.toStringAsFixed(0)}%)',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(
                        Colors.orange,
                        '$cat3Name (${cat3Pct.toStringAsFixed(0)}%)',
                      ),
                      _buildLegendItem(
                        colorScheme.error,
                        'Others (${othersPct.toStringAsFixed(0)}%)',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isWide)
              const SizedBox(width: 24)
            else
              const SizedBox(height: 24),

            // Goals Card
            Container(
              width: isWide
                  ? constraints.maxWidth * 0.42 - 12
                  : double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    offset: const Offset(0, 10),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentGoal != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const Text(
                              'ACTIVE GOAL',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          currentGoal.title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re only ${formatCurrency.format(currentGoal.targetAmount - totalSavings > 0 ? currentGoal.targetAmount - totalSavings : 0)} away from your dream drive. Keep the momentum!',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatCurrency.format(totalSavings),
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${currentGoal.targetAmount > 0 ? (totalSavings / currentGoal.targetAmount * 100).clamp(0, 100).toStringAsFixed(0) : 0}%',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: currentGoal.targetAmount > 0
                                ? (totalSavings / currentGoal.targetAmount)
                                      .clamp(0.0, 1.0)
                                : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x66FFFFFF),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Active Goals',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
    String time,
    String title,
    String category,
    String amount,
    IconData icon,
    Color iconColor,
    Color iconBgColor, {
    bool isIncome = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 256,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.brightness == Brightness.light
                ? const Color(0x08000000)
                : Colors.black26,
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                time.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                category,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isIncome ? colorScheme.secondary : colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final ColorScheme colorScheme;
  final double p1;
  final double p2;
  final double p3;
  final double p4;

  _DonutChartPainter(this.colorScheme, this.p1, this.p2, this.p3, this.p4);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 12.0;
    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width / 2) - strokeWidth,
    );

    // Background Circle
    canvas.drawArc(
      rect,
      0,
      3.14159 * 2,
      false,
      Paint()
        ..color = colorScheme.surfaceVariant.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    double startAngle = -3.14159 / 2; // Start from top

    void drawSegment(double percentage, Color color) {
      if (percentage <= 0) return;
      double sweepAngle = (percentage / 100) * 3.14159 * 2;
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweepAngle;
    }

    drawSegment(p1, colorScheme.primary);
    drawSegment(p2, colorScheme.secondary);
    drawSegment(p3, Colors.orange);
    drawSegment(p4, colorScheme.error);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return p1 != oldDelegate.p1 ||
        p2 != oldDelegate.p2 ||
        p3 != oldDelegate.p3 ||
        p4 != oldDelegate.p4;
  }
}
