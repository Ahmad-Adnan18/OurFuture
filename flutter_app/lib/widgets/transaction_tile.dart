import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isPositive = transaction.isIncome;
    // M-banking style usually keeps numbers black/dark, maybe green for income.
    // Red for expense is standard but can be softer.
    final amountColor = isPositive 
        ? const Color(0xFF059669) // Emerald for income
        : colorScheme.onSurface; // Standard text color for expense, purely stylistic choice

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTypeColor(transaction.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  transaction.typeIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(l10n),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                     transaction.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                    fontSize: 15,
                  ),
                ),
                if (transaction.storageAccount?.name != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      transaction.storageAccount!.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    if (transaction.notes != null && transaction.notes!.isNotEmpty) {
      return transaction.notes!;
    }
    // Map types to localized strings
    switch (transaction.type) {
      case 'deposit': return l10n.deposit;
      case 'expense': return l10n.expense;
      case 'withdrawal': return l10n.withdrawal;
      case 'adjustment': return l10n.adjustment;
      default: return transaction.type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'deposit':
        return Colors.green;
      case 'expense':
        return Colors.blue; // Changed to blue to be less aggressive than red
      case 'withdrawal':
        return Colors.orange;
      case 'adjustment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
