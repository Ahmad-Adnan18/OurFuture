// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageAccount _$StorageAccountFromJson(Map<String, dynamic> json) =>
    StorageAccount(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num).toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StorageAccountToJson(StorageAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'balance': instance.balance,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
