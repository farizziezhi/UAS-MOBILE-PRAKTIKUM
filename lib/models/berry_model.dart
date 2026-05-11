import 'package:json_annotation/json_annotation.dart';

part 'berry_model.g.dart';

@JsonSerializable()
class BerryModel {
  final int id;
  
  final String name;
  
  @JsonKey(defaultValue: '')
  final String itemName;
  
  @JsonKey(name: 'growth_time', defaultValue: 0)
  final int growthTime;
  
  @JsonKey(defaultValue: 0)
  final int size;
  
  @JsonKey(defaultValue: '')
  final String spriteUrl;

  const BerryModel({
    required this.id,
    required this.name,
    required this.itemName,
    required this.growthTime,
    required this.size,
    required this.spriteUrl,
  });

  factory BerryModel.fromJson(Map<String, dynamic> json) =>
      _$BerryModelFromJson(json);

  Map<String, dynamic> toJson() => _$BerryModelToJson(this);
}
