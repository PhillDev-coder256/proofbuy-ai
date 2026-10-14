// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingSession _$ShoppingSessionFromJson(Map<String, dynamic> json) =>
    _ShoppingSession(
      id: json['id'] as String,
      briefText: json['brief_text'] as String,
      requirementsJson: json['requirements_json'] as Map<String, dynamic>?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ShoppingSessionToJson(_ShoppingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brief_text': instance.briefText,
      'requirements_json': instance.requirementsJson,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
