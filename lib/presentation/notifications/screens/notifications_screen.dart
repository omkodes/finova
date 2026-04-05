import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/app_notification.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_state.dart';

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

                    BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        if (state is NotificationLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is NotificationError) {
                          return Center(child: Text(state.message, style: TextStyle(color: colorScheme.error)));
                        } else if (state is NotificationLoaded) {
                          if (state.notifications.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No notifications right now',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            );
                          }
                          
                          final now = DateTime.now();
                          final todayNotifications = state.notifications.where((n) => 
                              n.createdAt.year == now.year &&
                              n.createdAt.month == now.month &&
                              n.createdAt.day == now.day).toList();
                              
                          final earlierNotifications = state.notifications.where((n) => 
                              !(n.createdAt.year == now.year &&
                              n.createdAt.month == now.month &&
                              n.createdAt.day == now.day)).toList();

                          return Column(
                            key: const ValueKey('notification_list'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (todayNotifications.isNotEmpty) ...[
                                _buildSectionHeader(context, 'Today'),
                                const SizedBox(height: 24),
                                ...todayNotifications.map((n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildNotificationCard(context, n),
                                )).toList(),
                                const SizedBox(height: 32),
                              ],
                              
                              if (earlierNotifications.isNotEmpty) ...[
                                _buildSectionHeader(context, 'Earlier'),
                                const SizedBox(height: 24),
                                ...earlierNotifications.map((n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildNotificationCard(context, n),
                                )).toList(),
                                const SizedBox(height: 48),
                              ],
                            ],
                          );
                        }
                        
                        return const SizedBox.shrink();
                      },
                    ),

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

  Widget _buildNotificationCard(BuildContext context, AppNotification notification) {
    final colorScheme = Theme.of(context).colorScheme;
    
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (notification.type) {
      case 'transaction':
        icon = Icons.account_balance_wallet_rounded;
        iconColor = colorScheme.primary;
        iconBg = colorScheme.primaryContainer;
        break;
      case 'security':
        icon = Icons.shield_rounded;
        iconColor = colorScheme.error;
        iconBg = colorScheme.errorContainer;
        break;
      case 'reminder':
        icon = Icons.timer_rounded;
        iconColor = colorScheme.tertiary;
        iconBg = colorScheme.tertiaryContainer;
        break;
      case 'system':
      default:
        icon = Icons.notifications_rounded;
        iconColor = colorScheme.secondary;
        iconBg = colorScheme.secondaryContainer;
        break;
    }

    String timeText = _getTimeText(notification.createdAt);

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeText,
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
                  notification.description,
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
          if (notification.isUnread) ...[
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

  String _getTimeText(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      if (difference.inMinutes <= 1) return 'Just now';
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && now.day == createdAt.day) {
      return '${difference.inHours}h ago';
    } else if (difference.inHours < 48 && (now.day - createdAt.day).abs() == 1) { // simple yesterday
      return 'Yesterday';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
