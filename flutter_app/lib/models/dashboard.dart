import 'package:json_annotation/json_annotation.dart';
import 'goal.dart';
import 'transaction.dart';

part 'dashboard.g.dart';

@JsonSerializable()
class DashboardData {
  @JsonKey(name: 'total_assets')
  final double totalAssets;
  @JsonKey(name: 'unallocated_funds')
  final double unallocatedFunds;
  @JsonKey(name: 'active_goals')
  final List<Goal> activeGoals;
  @JsonKey(name: 'recent_transactions')
  final List<Transaction> recentTransactions;

  DashboardData({
    required this.totalAssets,
    required this.unallocatedFunds,
    required this.activeGoals,
    required this.recentTransactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardDataToJson(this);

  /// Total allocated funds (in goals)
  double get allocatedFunds => totalAssets - unallocatedFunds;

  /// Percentage of funds allocated
  double get allocationPercent {
    if (totalAssets <= 0) return 0;
    return (allocatedFunds / totalAssets) * 100;
  }
}
