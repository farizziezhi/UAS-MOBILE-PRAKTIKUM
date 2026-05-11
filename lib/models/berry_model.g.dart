// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'berry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BerryModel _$BerryModelFromJson(Map<String, dynamic> json) => BerryModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  itemName: json['itemName'] as String? ?? '',
  growthTime: (json['growth_time'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num?)?.toInt() ?? 0,
  spriteUrl: json['spriteUrl'] as String? ?? '',
);

Map<String, dynamic> _$BerryModelToJson(BerryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'itemName': instance.itemName,
      'growth_time': instance.growthTime,
      'size': instance.size,
      'spriteUrl': instance.spriteUrl,
    };
