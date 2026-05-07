import 'package:json_annotation/json_annotation.dart';

part 'inventory_model.g.dart';

/// InventoryModel — merepresentasikan row di tabel `user_inventory` Supabase.
///
/// Schema DB (snake_case):
///   id           UUID PRIMARY KEY (auto-generated)
///   user_id      UUID REFERENCES users(id)
///   pokemon_id   INT REFERENCES pokemon_pool(pokemon_id)
///   obtained_at  TIMESTAMPTZ DEFAULT now()
@JsonSerializable()
class InventoryModel {
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'pokemon_id')
  final int pokemonId;

  @JsonKey(name: 'obtained_at')
  final DateTime obtainedAt;

  const InventoryModel({
    required this.id,
    required this.userId,
    required this.pokemonId,
    required this.obtainedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryModelToJson(this);

  /// URL sprite dari PokeAPI berdasarkan pokemonId.
  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';

  @override
  String toString() =>
      'InventoryModel(id: $id, pokemonId: $pokemonId, at: $obtainedAt)';
}
