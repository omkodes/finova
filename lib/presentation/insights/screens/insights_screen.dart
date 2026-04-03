import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:finova/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../bloc/insights_bloc.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<InsightsBloc>().add(
      InsightsFetchRequested(month: now.month, year: now.year),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final currentMonthStr = DateFormat('MMMM').format(DateTime.now());

    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (context, state) {
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
                builder: (context, authState) {
                  final user = (authState is AuthAuthenticated)
                      ? authState.user
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
                          builder: (context) => const NotificationsScreen(),
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
                  // Month Selector (Swipeable)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildMonthTab(currentMonthStr, true, colorScheme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Hero: Month Summary
                  Text(
                    '$currentMonthStr Insights',
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state is InsightsLoaded)
                    Text(
                      state.totalSpent > 0
                          ? 'Your spending looks steady this month.'
                          : 'No expenses logged yet. Add some to see insights!',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (state is InsightsLoading || state is InsightsInitial)
                    Text(
                      'Analyzing your spending...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 40),

                  if (state is InsightsLoaded) ...[
                    // Bento Grid Layout
                    // Biggest Expense
                    _buildBiggestExpenseCard(state, colorScheme, isDark),
                    const SizedBox(height: 16),

                    // Spending Heatmap
                    _buildSpendingHeatmapCard(state, colorScheme, isDark),
                    const SizedBox(height: 16),

                    // 2-column row: Weekly Avg & Smart Insight
                    Row(
                      children: [
                        Expanded(
                          child: _buildWeeklyAvgCard(
                            state,
                            colorScheme,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSmartInsightCard(state, colorScheme),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else if (state is InsightsLoading ||
                      state is InsightsInitial) ...[
                    const Center(child: CircularProgressIndicator()),
                  ] else if (state is InsightsError) ...[
                    Center(child: Text('Error: \${state.message}')),
                  ],

                  // Focus Card (Static for Visual Impact)
                  _buildFocusCard(colorScheme, isDark),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthTab(String text, bool isActive, ColorScheme colorScheme) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      );
    }
  }

  Widget _buildBiggestExpenseCard(
    InsightsLoaded state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final formatCurrency = NumberFormat.simpleCurrency();
    final biggestAmount = state.categoryTotals[state.biggestCategory] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BIGGEST EXPENSE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.biggestCategory != 'None'
                ? state.biggestCategory.toUpperCase()
                : 'NO EXPENSES YET',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatCurrency.format(biggestAmount),
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (biggestAmount > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Most active category',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingHeatmapCard(
    InsightsLoaded state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // Determine the max amount among all categories to set 100% height scale.
    double maxAmt = 0;
    if (state.categoryTotals.isNotEmpty) {
      maxAmt = state.categoryTotals.values.reduce(max);
    }

    // Convert to list for mapping
    final categories = state.categoryTotals.entries
        .where((e) => e.value > 0)
        .toList();
    // Sort descending by value so biggest bars are shown
    categories.sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 for the view
    final topCategories = categories.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Heatmap',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: topCategories.isEmpty
                ? Center(
                    child: Text(
                      'Not enough data to map.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: topCategories.map((entry) {
                      final pct = maxAmt == 0 ? 0.0 : entry.value / maxAmt;
                      return _buildHeatmapBar(
                        entry.key.toUpperCase(),
                        pct,
                        colorScheme.primary,
                        colorScheme,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapBar(
    String label,
    double percentage,
    Color fill,
    ColorScheme colorScheme,
  ) {
    // consistently allows a 160px maximum bar.
    final maxHeight = 160.0;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            height: maxHeight,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: maxHeight * percentage,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label.length > 6 ? label.substring(0, 6) : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAvgCard(
    InsightsLoaded state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final formatCurrency = NumberFormat.simpleCurrency();

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY AVG',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatCurrency.format(state.weeklyAvg),
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 4,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 4,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'steady spending',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightCard(InsightsLoaded state, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.lightbulb_rounded,
              size: 72,
              color: colorScheme.onPrimary.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SMART TIP',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.biggestCategory != 'None' && state.totalSpent > 0
                    ? 'Consider setting a budget limit specifically for \${state.biggestCategory}.'
                    : 'Start logging expenses to get personalized tips!',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.savings_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Fund Progress',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.82,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '82%',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
