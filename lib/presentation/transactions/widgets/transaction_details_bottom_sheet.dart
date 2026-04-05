import 'package:finova/core/theme/app_colors.dart';
import 'package:finova/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../home/bloc/transaction_bloc.dart';
import '../../home/widgets/add_transaction_bottom_sheet.dart';

void showTransactionDetailsBottomSheet(BuildContext context, TransactionEntity tx, IconData icon) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
    builder: (context) => TransactionDetailsBottomSheet(tx: tx, displayIcon: icon),
  );
}

class TransactionDetailsBottomSheet extends StatelessWidget {
  final TransactionEntity tx;
  final IconData displayIcon;

  const TransactionDetailsBottomSheet({super.key, required this.tx, required this.displayIcon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isIncome = tx.type == DomainTransactionType.income;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.light ? AppColors.surfaceContainerLowest : AppColors.darkSurfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.brightness == Brightness.light ? const Color(0x1F191C1D) : Colors.black54,
            offset: const Offset(0, -20),
            blurRadius: 60,
          )
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 32, right: 32, bottom: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Transaction Header
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(displayIcon, size: 36, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tx.notes != null && tx.notes!.isNotEmpty ? tx.notes! : tx.category,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.normal, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${isIncome ? '+' : '-'}₹${tx.amount.toStringAsFixed(2)}",
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -2.0, color: isIncome ? colorScheme.secondary : colorScheme.error),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Details Bento List
              Column(
                children: [
                  _buildDetailRow(context, Icons.category_rounded, 'Category', tx.category),
                  const SizedBox(height: 4),
                  _buildDetailRow(context, Icons.calendar_today_rounded, 'Date', DateFormat('MMM d, yyyy').format(tx.date)),
                  const SizedBox(height: 4),
                  if (tx.notes != null && tx.notes!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.brightness == Brightness.light ? AppColors.surfaceContainerLowest : AppColors.darkSurfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.description_rounded, color: colorScheme.primary),
                              ),
                              const SizedBox(width: 16),
                              Text('Notes', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 56, top: 4),
                            child: Text(tx.notes!, style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: colorScheme.onSurface, height: 1.4)),
                          )
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),

              // Actions
              Container(
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primaryContainer]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.35), offset: const Offset(0, 10), blurRadius: 20)],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context); // Close details sheet
                      showAddTransactionBottomSheet(context, transaction: tx);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Edit Transaction', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      context.read<TransactionBloc>().add(TransactionDeleteRequested(tx.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Transaction Deleted"),
                          backgroundColor: colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_rounded, color: colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Text('Delete', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.error)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.brightness == Brightness.light ? AppColors.surfaceContainerLowest : AppColors.darkSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
