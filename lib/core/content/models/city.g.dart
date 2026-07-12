// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_City _$CityFromJson(Map<String, dynamic> json) => _City(
  name: json['name'] as String,
  country: json['country'] as String,
  countryCode: json['countryCode'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$CityToJson(_City instance) => <String, dynamic>{
  'name': instance.name,
  'country': instance.country,
  'countryCode': instance.countryCode,
  'lat': instance.lat,
  'lng': instance.lng,
};
