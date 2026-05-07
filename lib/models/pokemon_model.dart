import 'package:json_annotation/json_annotation.dart';

part 'pokemon_model.g.dart';

/// PokemonModel — merepresentasikan row di tabel `pokemon_pool` Supabase.
///
/// Schema DB (snake_case):
///   pokemon_id   INT PRIMARY KEY
///   name         TEXT
///   rarity       TEXT ('common', 'rare', 'epic', 'legendary')
///   drop_weight  INT
@JsonSerializable()
class PokemonModel {
  @JsonKey(name: 'pokemon_id')
  final int pokemonId;

  final String name;

  final String rarity;

  @JsonKey(name: 'drop_weight')
  final int dropWeight;

  const PokemonModel({
    required this.pokemonId,
    required this.name,
    required this.rarity,
    required this.dropWeight,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonModelFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonModelToJson(this);

  /// URL sprite dari PokeAPI berdasarkan pokemonId.
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';

  @override
  String toString() =>
      'PokemonModel(id: $pokemonId, name: $name, rarity: $rarity)';
}
