import 'package:json_annotation/json_annotation.dart';

part 'item_detail_model.g.dart';

/// ItemDetailModel — merepresentasikan data detail Item/Pokéball dari PokeAPI.
///
/// Endpoint: GET https://pokeapi.co/api/v2/item/{id}
///
/// Menyimpan informasi lengkap item termasuk efek, kategori, atribut,
/// fling power, dan flavor text (lore/journal).
@JsonSerializable()
class ItemDetailModel {
  final int id;
  final String name;
  final int cost;
  final String spriteUrl;

  /// Kategori item (misal: standard-balls, pokeballs, medicine, dll.)
  final String category;

  /// Kekuatan fling saat item dilempar dalam battle
  @JsonKey(defaultValue: 0)
  final int flingPower;

  /// Deskripsi efek mekanis item (dari effect_entries bahasa Inggris)
  final String? effectDescription;

  /// Atribut item (misal: countable, consumable, usable-in-battle, dll.)
  final List<String> attributes;

  /// Teks lore / journal dari flavor_text_entries (bahasa Inggris)
  final List<String> flavorTextEntries;

  const ItemDetailModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.spriteUrl,
    required this.category,
    required this.flingPower,
    required this.effectDescription,
    required this.attributes,
    required this.flavorTextEntries,
  });

  factory ItemDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ItemDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemDetailModelToJson(this);
}
