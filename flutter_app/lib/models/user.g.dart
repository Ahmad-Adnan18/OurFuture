// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      currentTeamId: (json['current_team_id'] as num?)?.toInt(),
      currentTeam: json['current_team'] == null
          ? null
          : Team.fromJson(json['current_team'] as Map<String, dynamic>),
      ownedTeams: (json['owned_teams'] as List<dynamic>?)
          ?.map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      allTeams: (json['all_teams'] as List<dynamic>?)
          ?.map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profile_photo_url': instance.profilePhotoUrl,
      'current_team_id': instance.currentTeamId,
      'current_team': instance.currentTeam,
      'owned_teams': instance.ownedTeams,
      'all_teams': instance.allTeams,
      'created_at': instance.createdAt?.toIso8601String(),
    };

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      personalTeam: json['personal_team'] as bool,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'personal_team': instance.personalTeam,
      'created_at': instance.createdAt?.toIso8601String(),
      'users': instance.users,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'token': instance.token,
    };
