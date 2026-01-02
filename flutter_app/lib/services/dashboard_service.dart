import '../config/api_config.dart';
import '../models/dashboard.dart';
import 'api_service.dart';

/// Dashboard Service for fetching dashboard data
class DashboardService {
  final ApiService _api = ApiService();

  /// Get dashboard summary data
  Future<DashboardData> getDashboard() async {
    final response = await _api.get(ApiConfig.dashboard);
    return DashboardData.fromJson(response.data);
  }
}
