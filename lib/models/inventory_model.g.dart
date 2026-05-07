// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryModel _$InventoryModelFromJson(Map<String, dynamic> json) =>
    InventoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pokemonId: (json['pokemon_id'] as num).toInt(),
      obtainedAt: DateTime.parse(json['obtained_at'] as String),
    );

Map<String, dynamic> _$InventoryModelToJson(InventoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'pokemon_id': instance.pokemonId,
      'obtained_at': instance.obtainedAt.toIso8601String(),
    };
