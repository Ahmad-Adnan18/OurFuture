// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentBalance: (json['current_balance'] as num).toDouble(),
      totalCollected: (json['total_collected'] as num).toDouble(),
      progressPercent: (json['progress_percent'] as num?)?.toDouble(),
      status: json['status'] as String,
      startDate: json['start_date'] as String?,
      estimatedDate: json['estimated_date'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'target_amount': instance.targetAmount,
      'current_balance': instance.currentBalance,
      'total_collected': instance.totalCollected,
      'progress_percent': instance.progressPercent,
      'status': instance.status,
      'start_date': instance.startDate,
      'estimated_date': instance.estimatedDate,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
