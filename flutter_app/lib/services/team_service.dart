import '../models/user.dart';
import 'api_service.dart';

class TeamService {
  final ApiService _apiService = ApiService();

  Future<Team> createTeam(String name) async {
    final response = await _apiService.post('/teams', data: {'name': name});
    return Team.fromJson(response.data['team']);
  }

  Future<Team> updateTeam(int teamId, String name) async {
    final response = await _apiService.put('/teams/$teamId', data: {'name': name});
    return Team.fromJson(response.data['team']);
  }

  Future<void> inviteMember(int teamId, String email, String role) async {
    await _apiService.post('/teams/$teamId/invite', data: {
      'email': email,
      'role': role,
    });
  }
}
