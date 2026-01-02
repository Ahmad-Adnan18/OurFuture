// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    DashboardData(
      totalAssets: (json['total_assets'] as num).toDouble(),
      unallocatedFunds: (json['unallocated_funds'] as num).toDouble(),
      activeGoals: (json['active_goals'] as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentTransactions: (json['recent_transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardDataToJson(DashboardData instance) =>
    <String, dynamic>{
      'total_assets': instance.totalAssets,
      'unallocated_funds': instance.unallocatedFunds,
      'active_goals': instance.activeGoals,
      'recent_transactions': instance.recentTransactions,
    };
