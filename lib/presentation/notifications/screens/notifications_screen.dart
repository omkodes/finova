import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sticky App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: colorScheme.background.withOpacity(0.8),
                elevation: 0,
                toolbarHeight: 64,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Section
                    Text(
                      'Stay Updated',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                        letterSpacing: -1.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your progress, secure your account,\nand manage your spending.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Today Section
                    _buildSectionHeader(context, 'Today'),
                    const SizedBox(height: 24),
                    _buildSimpleNotification(
                      context,
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: colorScheme.primary,
                      iconBg: colorScheme.primaryContainer,
                      title: 'Transaction alert',
                      time: '4h ago',
                      description: 'Successfully spent ₹45.20 at Whole Foods.',
                    ),
                    const SizedBox(height: 48),

                    // Earlier Section
                    _buildSectionHeader(context, 'Earlier'),
                    const SizedBox(height: 24),
                    _buildSimpleNotification(
                      context,
                      icon: Icons.shield_rounded,
                      iconColor: colorScheme.error,
                      iconBg: colorScheme.errorContainer,
                      title: 'Security alert',
                      time: 'Yesterday',
                      description: 'New login detected on a Chrome browser.',
                      isUnread: true,
                    ),
                    const SizedBox(height: 16),
                    _buildSimpleNotification(
                      context,
                      icon: Icons.timer_rounded,
                      iconColor: colorScheme.tertiary,
                      iconBg: colorScheme.tertiaryContainer,
                      title: 'Challenge reminder',
                      time: '2 days ago',
                      description: 'Don\'t forget: Your "No Food Delivery" challenge ends in 2 days.',
                    ),
                    const SizedBox(height: 48),

                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleNotification(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
    required String description,
    bool isUnread = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.light ? AppColors.surfaceContainerLowest : AppColors.darkSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.brightness == Brightness.light ? const Color(0x0A191C1D) : Colors.black26,
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconContainer(icon, iconColor, iconBg),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color, Color bg) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
