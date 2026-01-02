import 'package:json_annotation/json_annotation.dart';
import 'goal.dart';
import 'storage_account.dart';
import 'user.dart';

part 'transaction.g.dart';

enum TransactionType {
  deposit,
  expense,
  withdrawal,
  adjustment,
}

@JsonSerializable()
class Transaction {
  final int id;
  final String type;
  final double amount;
  final String date;
  final String? notes;
  @JsonKey(name: 'storage_account')
  final StorageAccount? storageAccount;
  final Goal? goal;
  final User? user;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
    this.storageAccount,
    this.goal,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  /// Check if transaction is income (adds money)
  bool get isIncome => type == 'deposit' || type == 'adjustment';

  /// Check if transaction is expense (removes money)
  bool get isExpense => type == 'expense' || type == 'withdrawal';

  /// Get color for transaction type
  String get typeColor {
    switch (type) {
      case 'deposit':
        return '#10B981'; // emerald-500
      case 'expense':
        return '#F43F5E'; // rose-500
      case 'withdrawal':
        return '#F59E0B'; // amber-500
      case 'adjustment':
        return '#6B7280'; // gray-500
      default:
        return '#6B7280';
    }
  }

  /// Get icon for transaction type
  String get typeIcon {
    switch (type) {
      case 'deposit':
        return '↗️';
      case 'expense':
        return '↘️';
      case 'withdrawal':
        return '↩️';
      case 'adjustment':
        return '⚙️';
      default:
        return '💰';
    }
  }

  /// Get display name for type
  String get typeDisplayName {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'expense':
        return 'Expense';
      case 'withdrawal':
        return 'Withdrawal';
      case 'adjustment':
        return 'Adjustment';
      default:
        return type;
    }
  }
}
