import 'package:finova/core/theme/app_colors.dart';
import 'package:finova/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../goals/bloc/goal_bloc.dart';
import '../../insights/bloc/insights_bloc.dart';
import '../bloc/transaction_bloc.dart';

void showAddTransactionBottomSheet(
  BuildContext context, {
  TransactionEntity? transaction,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AddTransactionBottomSheet(transaction: transaction),
    ),
  );
}

class AddTransactionBottomSheet extends StatefulWidget {
  final TransactionEntity? transaction;
  const AddTransactionBottomSheet({super.key, this.transaction});

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  late bool _isExpense;
  late String _selectedCategory;
  late String _selectedDateStr;
  late DateTime _selectedDate;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Groceries', 'icon': Icons.shopping_cart_rounded},
    {'name': 'Rent', 'icon': Icons.home_rounded},
    {'name': 'Salary', 'icon': Icons.payments_rounded},
    {'name': 'Transport', 'icon': Icons.directions_car_rounded},
    {'name': 'Dining', 'icon': Icons.restaurant_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final tx = widget.transaction!;
      _isExpense = tx.type == DomainTransactionType.expense;
      _selectedCategory = tx.category;
      _selectedDate = tx.date;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _notesController.text = tx.notes ?? '';

      final now = DateTime.now();
      if (tx.date.year == now.year &&
          tx.date.month == now.month &&
          tx.date.day == now.day) {
        _selectedDateStr = 'Today';
      } else if (tx.date.year == now.year &&
          tx.date.month == now.month &&
          tx.date.day == now.day - 1) {
        _selectedDateStr = 'Yesterday';
      } else {
        _selectedDateStr = "${tx.date.day}/${tx.date.month}/${tx.date.year}";
      }
    } else {
      _isExpense = true;
      _selectedCategory = 'Rent';
      _selectedDateStr = 'Today';
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.light
            ? AppColors.surfaceContainerLowest
            : AppColors.darkSurfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.brightness == Brightness.light
                ? const Color(0x1F191C1D)
                : Colors.black54,
            offset: const Offset(0, -20),
            blurRadius: 60,
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Amount Input
              Column(
                children: [
                  Text(
                    'TRANSACTION AMOUNT',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2.0,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Income/Expense Toggle
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpense = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isExpense
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !_isExpense
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: !_isExpense
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpense = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isExpense
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _isExpense
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _isExpense
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Category Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat['name']),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              cat['icon'],
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['name'],
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Date Picker Row
              Text(
                'Date',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDateBtn('Today')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDateBtn('Yesterday')),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              _selectedDateStr != 'Today' &&
                                  _selectedDateStr != 'Yesterday'
                              ? colorScheme.primary.withOpacity(0.1)
                              : colorScheme.surfaceVariant.withOpacity(0.3),
                          border:
                              _selectedDateStr != 'Today' &&
                                  _selectedDateStr != 'Yesterday'
                              ? Border.all(
                                  color: colorScheme.primary.withOpacity(0.2),
                                )
                              : Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color:
                                  _selectedDateStr != 'Today' &&
                                      _selectedDateStr != 'Yesterday'
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedDateStr != 'Today' &&
                                        _selectedDateStr != 'Yesterday'
                                    ? _selectedDateStr
                                    : 'Select Date',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight:
                                      _selectedDateStr != 'Today' &&
                                          _selectedDateStr != 'Yesterday'
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color:
                                      _selectedDateStr != 'Today' &&
                                          _selectedDateStr != 'Yesterday'
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Notes Field
              Text(
                'Notes',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What was this for?',
                    hintStyle: TextStyle(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Primary CTA
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.35),
                      offset: const Offset(0, 10),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final amt =
                          double.tryParse(_amountController.text) ?? 0.0;
                      if (amt > 0) {
                        if (widget.transaction != null) {
                          // Edit Mode
                          final updatedTx = TransactionEntity(
                            id: widget.transaction!.id,
                            amount: amt,
                            type: _isExpense
                                ? DomainTransactionType.expense
                                : DomainTransactionType.income,
                            category: _selectedCategory,
                            date: _selectedDate,
                            notes: _notesController.text.trim().isNotEmpty
                                ? _notesController.text.trim()
                                : null,
                            createdAt: widget.transaction!.createdAt,
                          );
                          context.read<TransactionBloc>().add(
                            TransactionUpdateRequested(updatedTx),
                          );
                        } else {
                          // Add Mode
                          final newTx = TransactionEntity(
                            id: 0,
                            amount: amt,
                            type: _isExpense
                                ? DomainTransactionType.expense
                                : DomainTransactionType.income,
                            category: _selectedCategory,
                            date: _selectedDate,
                            notes: _notesController.text.trim().isNotEmpty
                                ? _notesController.text.trim()
                                : null,
                            createdAt: DateTime.now(),
                          );
                          context.read<TransactionBloc>().add(
                            TransactionAddRequested(newTx),
                          );
                        }

                        // Trigger re-fetch for Insights and Goals dynamically so they update without app restart
                        final now = DateTime.now();
                        context.read<InsightsBloc>().add(
                          InsightsFetchRequested(
                            month: now.month,
                            year: now.year,
                          ),
                        );
                        context.read<GoalBloc>().add(
                          GoalFetchRequested(now.month, now.year),
                        );

                        Navigator.pop(context); // Close bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.transaction != null
                                  ? "Transaction Updated!"
                                  : "Transaction Tracked Successfully!",
                            ),
                            backgroundColor: colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                              bottom: 90,
                              left: 16,
                              right: 16,
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Text(
                        widget.transaction != null
                            ? 'Update Transaction'
                            : 'Save Transaction',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ].animate(interval: 40.ms).fade(duration: 300.ms).slideY(begin: 0.05, end: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBtn(String label) {
    bool isSelected = _selectedDateStr == label;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDateStr = label;
          if (label == 'Today') _selectedDate = DateTime.now();
          if (label == 'Yesterday')
            _selectedDate = DateTime.now().subtract(const Duration(days: 1));
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : colorScheme.surfaceVariant.withOpacity(0.3),
          border: isSelected
              ? Border.all(color: colorScheme.primary.withOpacity(0.2))
              : Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDateStr = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
}
