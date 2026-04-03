import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../bloc/transaction_bloc.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../widgets/add_transaction_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
              final user = (state is AuthAuthenticated) ? state.user : null;
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
                final user = (state is AuthAuthenticated) ? state.user : null;
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
                          builder: (context) => const NotificationsScreen(),
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
              Text(
                'Hi,User 👋',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
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
                        '₹42,850.20',
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
                        '₹8,420',
                        Icons.arrow_upward_rounded,
                        colorScheme.secondary,
                        colorScheme.secondary.withOpacity(0.1),
                      ),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        'EXPENSES',
                        '₹3,210',
                        Icons.arrow_downward_rounded,
                        colorScheme.error,
                        colorScheme.error.withOpacity(0.1),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Bento Grid
              _buildBentoGrid(),

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
                    onPressed: () {},
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
              ),
              const SizedBox(height: 16),

              // Horizontal Timeline List
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _buildTransactionCard(
                      'Today',
                      'Apple Store Soho',
                      'Electronics & Gear',
                      '-₹1,299.00',
                      Icons.shopping_bag_rounded,
                      colorScheme.outline,
                      colorScheme.surfaceContainer,
                    ),
                    const SizedBox(width: 16),
                    _buildTransactionCard(
                      'Yesterday',
                      'Monthly Salary',
                      'Primary Income',
                      '+₹6,500.00',
                      Icons.account_balance_rounded,
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.1),
                      isIncome: true,
                    ),
                    const SizedBox(width: 16),
                    _buildTransactionCard(
                      'Oct 24',
                      'Greenhouse Bistro',
                      'Dining & Drinks',
                      '-₹84.50',
                      Icons.restaurant_rounded,
                      colorScheme.outline,
                      colorScheme.surfaceContainer,
                    ),
                    const SizedBox(width: 16),
                    _buildTransactionCard(
                      'Oct 23',
                      'Equinox Member',
                      'Health & Fitness',
                      '-₹250.00',
                      Icons.fitness_center_rounded,
                      colorScheme.outline,
                      colorScheme.surfaceContainer,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
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

  Widget _buildBentoGrid() {
    final colorScheme = Theme.of(context).colorScheme;
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
                      painter: _DonutChartPainter(colorScheme),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹3,210',
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
                      ],
                    ),
                  ],
                ),
              ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(colorScheme.primary, 'Housing (45%)'),
                      _buildLegendItem(colorScheme.secondary, 'Food (20%)'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(colorScheme.tertiary, 'Travel (15%)'),
                      _buildLegendItem(
                        colorScheme.surfaceContainerHighest,
                        'Others (20%)',
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
                      const Text(
                        'New Tesla Model Y',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You\'re only ₹2,400 away from your dream drive. Keep the momentum!',
                        style: TextStyle(
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
                        children: const [
                          Text(
                            '₹12,600',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '82%',
                            style: TextStyle(
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
                          widthFactor: 0.82,
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

  _DonutChartPainter(this.colorScheme);

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

    // Segments simulation (Housing 45, Food 20, Travel 15)
    double startAngle = -3.14159 / 2; // Start from top

    void drawSegment(double percentage, Color color) {
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

    drawSegment(45, colorScheme.primary);
    drawSegment(20, colorScheme.secondary);
    drawSegment(15, colorScheme.tertiary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
