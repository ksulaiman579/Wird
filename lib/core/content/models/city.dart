import 'package:freezed_annotation/freezed_annotation.dart';

part 'city.freezed.dart';
part 'city.g.dart';

/// One entry in the bundled city list (M5.2) — replaces `geolocator` (an
/// F-Droid blocker) as the source of a location for prayer-time
/// calculation. See DATA_SOURCES.md for provenance.
@freezed
abstract class City with _$City {
  const factory City({
    required String name,
    required String country,
    required String countryCode,
    required double lat,
    required double lng,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}
