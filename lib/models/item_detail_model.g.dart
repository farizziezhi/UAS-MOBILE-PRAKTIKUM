// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemDetailModel _$ItemDetailModelFromJson(Map<String, dynamic> json) =>
    ItemDetailModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      cost: (json['cost'] as num).toInt(),
      spriteUrl: json['spriteUrl'] as String,
      category: json['category'] as String,
      flingPower: (json['flingPower'] as num?)?.toInt() ?? 0,
      effectDescription: json['effectDescription'] as String?,
      attributes: (json['attributes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      flavorTextEntries: (json['flavorTextEntries'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ItemDetailModelToJson(ItemDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cost': instance.cost,
      'spriteUrl': instance.spriteUrl,
      'category': instance.category,
      'flingPower': instance.flingPower,
      'effectDescription': instance.effectDescription,
      'attributes': instance.attributes,
      'flavorTextEntries': instance.flavorTextEntries,
    };
