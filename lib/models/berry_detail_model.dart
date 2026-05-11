import 'package:json_annotation/json_annotation.dart';

part 'berry_detail_model.g.dart';

/// BerryDetailModel — merepresentasikan data Berry dari hybrid fetch.
///
/// Fetch pertama: GET https://pokeapi.co/api/v2/berry/{id}
/// Fetch kedua: GET https://pokeapi.co/api/v2/item/{item_id} (dari berry.item.url)
///
/// Gabungan data dari kedua endpoint untuk menampilkan detail lengkap Berry.
@JsonSerializable()
class BerryDetailModel {
  final int id;
  final String name;
  final int size;
  final int growthTime;
  final int maxHarvest;
  final int cost;
  final String spriteUrl;
  final String? effectDescription;

  /// Rasa berry dengan potency-nya
  /// Format: {'spicy': 10, 'dry': 20, 'sweet': 30, 'bitter': 5, 'sour': 15}
  @JsonKey(fromJson: _flavorsFromJson, toJson: _flavorsToJson)
  final Map<String, int> flavors;

  const BerryDetailModel({
    required this.id,
    required this.name,
    required this.size,
    required this.growthTime,
    required this.maxHarvest,
    required this.cost,
    required this.spriteUrl,
    required this.effectDescription,
    required this.flavors,
  });

  factory BerryDetailModel.fromJson(Map<String, dynamic> json) =>
      _$BerryDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$BerryDetailModelToJson(this);

  /// Parse flavors dari array nested PokeAPI Berry JSON
  /// Format API: [{"potency": 10, "flavor": {"name": "spicy", "url": "..."}}]
  static Map<String, int> _flavorsFromJson(List<dynamic> json) {
    final Map<String, int> result = {};
    for (var item in json) {
      final flavorName =
          (item as Map<String, dynamic>)['flavor']['name'] as String;
      final potency = item['potency'] as int;
      result[flavorName] = potency;
    }
    return result;
  }

  static List<dynamic> _flavorsToJson(Map<String, int> flavors) {
    return flavors.entries
        .map(
          (e) => {
            'flavor': {'name': e.key},
            'potency': e.value,
          },
        )
        .toList();
  }
}
