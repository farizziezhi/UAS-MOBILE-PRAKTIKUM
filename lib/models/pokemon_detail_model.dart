import 'package:json_annotation/json_annotation.dart';

part 'pokemon_detail_model.g.dart';

/// PokemonDetailModel — merepresentasikan response dari PokeAPI.
///
/// Endpoint: GET https://pokeapi.co/api/v2/pokemon/{id}
///
/// Mem-parse nested JSON PokeAPI ke flat Dart object:
///   - types[]  → `List<String>`  (e.g. ['grass', 'poison'])
///   - stats[]  → `Map<String, int>` (e.g. {'hp': 45, 'attack': 49, ...})
@JsonSerializable()
class PokemonDetailModel {
  final int id;
  final String name;
  final int height;
  final int weight;

  /// Daftar tipe Pokémon, di-parse dari array nested PokeAPI.
  /// PokeAPI format: [{"slot":1,"type":{"name":"grass","url":"..."}}]
  @JsonKey(fromJson: _typesFromJson, toJson: _typesToJson)
  final List<String> types;

  /// Stats Pokémon, di-parse dari array nested PokeAPI.
  /// PokeAPI format: [{"base_stat":45,"stat":{"name":"hp","url":"..."}}]
  @JsonKey(fromJson: _statsFromJson, toJson: _statsToJson)
  final Map<String, int> stats;

  const PokemonDetailModel({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
  });

  factory PokemonDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PokemonDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonDetailModelToJson(this);

  // ── Custom parsers untuk nested PokeAPI JSON ──

  /// Parse types: [{"slot":1,"type":{"name":"fire"}}] → ['fire']
  static List<String> _typesFromJson(List<dynamic> json) {
    return json
        .map((e) => (e as Map<String, dynamic>)['type']['name'] as String)
        .toList();
  }

  static List<dynamic> _typesToJson(List<String> types) {
    return types
        .map((t) => {'type': {'name': t}})
        .toList();
  }

  /// Parse stats: [{"base_stat":45,"stat":{"name":"hp"}}] → {'hp': 45}
  static Map<String, int> _statsFromJson(List<dynamic> json) {
    final map = <String, int>{};
    for (final entry in json) {
      final e = entry as Map<String, dynamic>;
      final statName = (e['stat'] as Map<String, dynamic>)['name'] as String;
      final baseStat = e['base_stat'] as int;
      map[statName] = baseStat;
    }
    return map;
  }

  static List<dynamic> _statsToJson(Map<String, int> stats) {
    return stats.entries
        .map((e) => {
              'base_stat': e.value,
              'stat': {'name': e.key},
            })
        .toList();
  }

  // ── Computed getters ──

  /// Base Stat Total (BST) — jumlah semua base stats.
  int get bst => stats.values.fold(0, (sum, val) => sum + val);

  /// URL artwork resmi dari PokeAPI.
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  @override
  String toString() =>
      'PokemonDetailModel(id: $id, name: $name, types: $types, bst: $bst)';
}
