import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;
  @JsonKey(name: 'current_team_id')
  final int? currentTeamId;
  @JsonKey(name: 'current_team')
  final Team? currentTeam;
  @JsonKey(name: 'owned_teams')
  final List<Team>? ownedTeams;
  @JsonKey(name: 'all_teams')
  final List<Team>? allTeams;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
    this.currentTeamId,
    this.currentTeam,
    this.ownedTeams,
    this.allTeams,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Team {
  final int id;
  final String name;
  @JsonKey(name: 'personal_team')
  final bool personalTeam;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  final List<User>? users;

  Team({
    required this.id,
    required this.name,
    required this.personalTeam,
    this.createdAt,
    this.users,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String message;
  final User user;
  final String token;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
