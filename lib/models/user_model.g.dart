// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  pokecoinBalance: (json['pokecoin_balance'] as num?)?.toInt() ?? 0,
  pokeballCount: (json['pokeball_count'] as num?)?.toInt() ?? 0,
  lastDailyClaim: json['last_daily_claim'] == null
      ? null
      : DateTime.parse(json['last_daily_claim'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'pokecoin_balance': instance.pokecoinBalance,
  'pokeball_count': instance.pokeballCount,
  'last_daily_claim': instance.lastDailyClaim?.toIso8601String(),
};
