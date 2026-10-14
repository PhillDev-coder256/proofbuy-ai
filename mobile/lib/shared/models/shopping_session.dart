import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_session.freezed.dart';
part 'shopping_session.g.dart';

@freezed
abstract class ShoppingSession with _$ShoppingSession {
  const factory ShoppingSession({
    required String id,
    @JsonKey(name: 'brief_text') required String briefText,
    @JsonKey(name: 'requirements_json') Map<String, dynamic>? requirementsJson,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ShoppingSession;

  factory ShoppingSession.fromJson(Map<String, dynamic> json) =>
      _$ShoppingSessionFromJson(json);
}
