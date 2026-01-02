import '../config/api_config.dart';
import '../models/goal.dart';
import 'api_service.dart';

/// Goal Service for CRUD operations on goals
class GoalService {
  final ApiService _api = ApiService();

  /// Get all goals
  Future<List<Goal>> getGoals({String status = 'active'}) async {
    final response = await _api.get(
      ApiConfig.goals,
      queryParameters: {'status': status},
    );
    
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => Goal.fromJson(json)).toList();
  }

  /// Get single goal by ID
  Future<Goal> getGoal(int id) async {
    final response = await _api.get(ApiConfig.goal(id));
    return Goal.fromJson(response.data['data'] ?? response.data);
  }

  /// Create new goal
  Future<Goal> createGoal({
    required String title,
    required double targetAmount,
    required String startDate,
    String? estimatedDate,
  }) async {
    final response = await _api.post(
      ApiConfig.goals,
      data: {
        'title': title,
        'target_amount': targetAmount,
        'start_date': startDate,
        if (estimatedDate != null) 'estimated_date': estimatedDate,
      },
    );
    
    return Goal.fromJson(response.data['goal']);
  }

  /// Update existing goal
  Future<Goal> updateGoal(
    int id, {
    required String title,
    required double targetAmount,
    String? estimatedDate,
    String? status,
  }) async {
    final response = await _api.put(
      ApiConfig.goal(id),
      data: {
        'title': title,
        'target_amount': targetAmount,
        if (estimatedDate != null) 'estimated_date': estimatedDate,
        if (status != null) 'status': status,
      },
    );
    
    return Goal.fromJson(response.data['goal']);
  }

  /// Delete goal
  Future<void> deleteGoal(int id) async {
    await _api.delete(ApiConfig.goal(id));
  }
}
