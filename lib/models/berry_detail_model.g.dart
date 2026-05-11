// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'berry_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BerryDetailModel _$BerryDetailModelFromJson(Map<String, dynamic> json) =>
    BerryDetailModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      size: (json['size'] as num).toInt(),
      growthTime: (json['growthTime'] as num).toInt(),
      maxHarvest: (json['maxHarvest'] as num).toInt(),
      cost: (json['cost'] as num).toInt(),
      spriteUrl: json['spriteUrl'] as String,
      effectDescription: json['effectDescription'] as String?,
      flavors: BerryDetailModel._flavorsFromJson(json['flavors'] as List),
    );

Map<String, dynamic> _$BerryDetailModelToJson(BerryDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'size': instance.size,
      'growthTime': instance.growthTime,
      'maxHarvest': instance.maxHarvest,
      'cost': instance.cost,
      'spriteUrl': instance.spriteUrl,
      'effectDescription': instance.effectDescription,
      'flavors': BerryDetailModel._flavorsToJson(instance.flavors),
    };
