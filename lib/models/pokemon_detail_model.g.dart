// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonDetailModel _$PokemonDetailModelFromJson(Map<String, dynamic> json) =>
    PokemonDetailModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      height: (json['height'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      types: PokemonDetailModel._typesFromJson(json['types'] as List),
      stats: PokemonDetailModel._statsFromJson(json['stats'] as List),
    );

Map<String, dynamic> _$PokemonDetailModelToJson(PokemonDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'height': instance.height,
      'weight': instance.weight,
      'types': PokemonDetailModel._typesToJson(instance.types),
      'stats': PokemonDetailModel._statsToJson(instance.stats),
    };
