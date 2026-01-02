import 'package:json_annotation/json_annotation.dart';

part 'storage_account.g.dart';

enum StorageAccountType {
  bank,
  @JsonValue('e-wallet')
  eWallet,
  investment,
  cash,
}

@JsonSerializable()
class StorageAccount {
  final int id;
  final String name;
  final String type;
  final double balance;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  StorageAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.createdAt,
    this.updatedAt,
  });

  factory StorageAccount.fromJson(Map<String, dynamic> json) =>
      _$StorageAccountFromJson(json);
  Map<String, dynamic> toJson() => _$StorageAccountToJson(this);

  /// Get display icon based on type
  String get typeIcon {
    switch (type) {
      case 'bank':
        return '🏦';
      case 'e-wallet':
        return '📱';
      case 'investment':
        return '📈';
      case 'cash':
        return '💵';
      default:
        return '💰';
    }
  }

  /// Get display name for type
  String get typeDisplayName {
    switch (type) {
      case 'bank':
        return 'Bank';
      case 'e-wallet':
        return 'E-Wallet';
      case 'investment':
        return 'Investment';
      case 'cash':
        return 'Cash';
      default:
        return type;
    }
  }
}
