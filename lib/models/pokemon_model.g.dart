// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonModel _$PokemonModelFromJson(Map<String, dynamic> json) => PokemonModel(
  pokemonId: (json['pokemon_id'] as num).toInt(),
  name: json['name'] as String,
  rarity: json['rarity'] as String,
  dropWeight: (json['drop_weight'] as num).toInt(),
);

Map<String, dynamic> _$PokemonModelToJson(PokemonModel instance) =>
    <String, dynamic>{
      'pokemon_id': instance.pokemonId,
      'name': instance.name,
      'rarity': instance.rarity,
      'drop_weight': instance.dropWeight,
    };
