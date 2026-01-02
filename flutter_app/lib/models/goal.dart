import 'package:json_annotation/json_annotation.dart';

part 'goal.g.dart';

@JsonSerializable()
class Goal {
  final int id;
  final String title;
  @JsonKey(name: 'target_amount')
  final double targetAmount;
  @JsonKey(name: 'current_balance')
  final double currentBalance;
  @JsonKey(name: 'total_collected')
  final double totalCollected;
  @JsonKey(name: 'progress_percent')
  final double? progressPercent;
  final String status;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'estimated_date')
  final String? estimatedDate;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentBalance,
    required this.totalCollected,
    this.progressPercent,
    required this.status,
    this.startDate,
    this.estimatedDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);

  /// Calculate progress percent if not provided
  double get calculatedProgressPercent {
    if (progressPercent != null) return progressPercent!;
    if (targetAmount <= 0) return 0;
    return (totalCollected / targetAmount) * 100;
  }

  /// Check if goal is completed
  bool get isCompleted => status == 'completed';

  /// Check if goal is active
  bool get isActive => status == 'active';

  /// Remaining amount to reach target
  double get remainingAmount => targetAmount - totalCollected;
}
