import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isPositive = transaction.isIncome;
    final amountColor = isPositive ? Colors.green : Colors.red;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getTypeColor(transaction.type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          transaction.typeIcon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      title: Text(
        _getTitle(),
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.storageAccount?.name ?? 'Unknown wallet',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (transaction.goal != null)
            Text(
              '→ ${transaction.goal!.title}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
              ),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isPositive ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
          Text(
            transaction.date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      isThreeLine: transaction.goal != null,
    );
  }

  String _getTitle() {
    if (transaction.notes != null && transaction.notes!.isNotEmpty) {
      return transaction.notes!;
    }
    return transaction.typeDisplayName;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'deposit':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'withdrawal':
        return Colors.orange;
      case 'adjustment':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
