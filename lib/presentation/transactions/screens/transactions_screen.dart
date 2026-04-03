import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../home/bloc/transaction_bloc.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/transaction_details_bottom_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Groceries',
    'Rent',
    'Salary',
    'Transport',
    'Dining',
  ];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(TransactionFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Sticky Top App Bar
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
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCHWxCbhafR9KHeS7GVvZjyTVBlBIoQ52vJg1WNKIXjP-kQ9eCy2iAoOQUfJkAtR0Pt3E951HCizLzxe-Evvj4K_mNPmv4tom6_Zj9Wc-FMBJuMgiKzaxqlY7Cu1pXqDoDsF1B7vGW27yNj3rzZ3QX1-gqWvMQZ2s1TPrZGAKQ5UzPtBd_MIPc8BEjArG8fQXDQhatGRljSkKg03kLOJ1HjqXNJTd_PvjTi7vHKIpgZ4ClP_VGxl-e2z0A_gFM_nmBqekQ4EG3rCDQ',
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
                      'Activity',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.file_download_rounded,
                  color: colorScheme.outline,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Transaction history exported!'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                splashRadius: 24,
              ),
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
                // Search & Filters
                _buildSearchAndFilters(),
                const SizedBox(height: 32),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Transactions',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Transactions List
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is TransactionLoaded) {
                      return _buildTransactionList(state.transactions);
                    } else if (state is TransactionError) {
                      return Center(
                        child: Text(
                          'Error: ${state.error}',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('No Transactions Found.'),
                      );
                    }
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.brightness == Brightness.light ? const Color(0x0A191C1D) : Colors.black26,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search transactions',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: colorScheme.outline,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildFilterChip('All'),
              _buildFilterChip('Income'),
              _buildFilterChip('Expense'),
              _buildCategoryChip(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip() {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = _selectedCategory != null && _selectedCategory != 'All';
    String label = isSelected ? _selectedCategory! : 'Category';

    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedCategory = value == 'All' ? null : value;
          if (_selectedCategory != null) {
            _selectedFilter = 'Category';
          } else if (_selectedFilter == 'Category') {
            _selectedFilter = 'All';
          }
        });
      },
      itemBuilder: (BuildContext context) {
        return _categories.map((String category) {
          return PopupMenuItem<String>(
            value: category,
            child: Text(
              category,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
            ),
          );
        }).toList();
      },
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected || _selectedFilter == 'Category'
              ? colorScheme.primary
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isSelected || _selectedFilter == 'Category'
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: isSelected || _selectedFilter == 'Category'
                    ? Colors.white
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected || _selectedFilter == 'Category'
                  ? Colors.white
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool hasDropdown = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = _selectedFilter == label && _selectedCategory == null;
    return GestureDetector(
      onTap: () {
        if (!hasDropdown) {
          setState(() {
            _selectedFilter = label;
            _selectedCategory = null;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionEntity> allTx) {
    final colorScheme = Theme.of(context).colorScheme;
    if (allTx.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No recent activity.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    var filtered = allTx;
    if (_selectedFilter == 'Income') {
      filtered = filtered
          .where((t) => t.type == DomainTransactionType.income)
          .toList();
    } else if (_selectedFilter == 'Expense') {
      filtered = filtered
          .where((t) => t.type == DomainTransactionType.expense)
          .toList();
    } else if (_selectedCategory != null) {
      filtered = filtered
          .where(
            (t) => t.category.toLowerCase() == _selectedCategory!.toLowerCase(),
          )
          .toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No matching transactions.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    Map<String, List<TransactionEntity>> grouped = {};
    for (var tx in filtered) {
      DateTime txDate = tx.date;
      DateTime now = DateTime.now();
      String header;
      if (txDate.year == now.year &&
          txDate.month == now.month &&
          txDate.day == now.day) {
        header = "TODAY, ${DateFormat('MMM d').format(txDate).toUpperCase()}";
      } else if (txDate.year == now.year &&
          txDate.month == now.month &&
          txDate.day == now.day - 1) {
        header =
            "YESTERDAY, ${DateFormat('MMM d').format(txDate).toUpperCase()}";
      } else {
        header = DateFormat('MMM d, yyyy').format(txDate).toUpperCase();
      }

      if (!grouped.containsKey(header)) grouped[header] = [];
      grouped[header]!.add(tx);
    }

    List<Widget> children = [];
    grouped.forEach((dateString, transactions) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            dateString,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );

      for (var tx in transactions) {
        children.add(_buildTransactionCard(tx));
        children.add(const SizedBox(height: 12));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildTransactionCard(TransactionEntity tx) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isIncome = tx.type == DomainTransactionType.income;
    IconData icon;
    switch (tx.category.toLowerCase()) {
      case 'groceries':
        icon = Icons.shopping_basket_rounded;
        break;
      case 'dining':
        icon = Icons.restaurant_rounded;
        break;
      case 'transport':
        icon = Icons.directions_car_rounded;
        break;
      case 'salary':
        icon = Icons.payments_rounded;
        break;
      case 'rent':
        icon = Icons.home_rounded;
        break;
      default:
        icon = Icons.receipt_long_rounded;
        break;
    }

    return GestureDetector(
      onTap: () {
        showTransactionDetailsBottomSheet(context, tx, icon);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.brightness == Brightness.light ? const Color(0x0F191C1D) : Colors.black26,
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isIncome
                        ? colorScheme.secondaryContainer.withOpacity(0.2)
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isIncome ? colorScheme.secondary : Colors.blueGrey,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.notes != null && tx.notes!.isNotEmpty
                          ? tx.notes!
                          : tx.category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${tx.category} • ${DateFormat('h:mm a').format(tx.createdAt)}",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              "${isIncome ? '+' : '-'}₹${tx.amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isIncome ? colorScheme.secondary : colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
