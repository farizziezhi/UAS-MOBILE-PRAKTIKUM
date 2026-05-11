import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable()
class ItemModel {
  final int id;
  
  final String name;
  
  @JsonKey(defaultValue: 0)
  final int cost;
  
  @JsonKey(defaultValue: '')
  final String spriteUrl;

  const ItemModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.spriteUrl,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}
