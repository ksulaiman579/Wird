import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/notifications/prayer_times_service.dart';

// Riyadh, roughly.
const _lat = 24.7136;
const _lng = 46.6753;

void main() {
  test('calculationMethodFor maps known countries, defaults for unknown', () {
    expect(calculationMethodFor('SA'), 4);
    expect(calculationMethodFor('sa'), 4, reason: 'case-insensitive');
    expect(calculationMethodFor('AE'), 8);
    expect(calculationMethodFor('ZZ'), defaultCalculationMethod);
    expect(calculationMethodFor(null), defaultCalculationMethod);
  });

  test('calculationMethodFor prefers an explicit override over the country map', () {
    expect(calculationMethodFor('SA', override: 2), 2);
    expect(calculationMethodFor(null, override: 13), 13);
  });

  test('calculateOffline returns a plausible fajr before asr, same day', () {
    final date = DateTime(2026, 6, 1);
    final times = calculateOffline(date: date, latitude: _lat, longitude: _lng);

    expect(times.source, PrayerTimeSource.offline);
    expect(times.fajr.isBefore(times.asr), true);
    expect(times.fajr.year, 2026);
    expect(times.fajr.month, 6);
  });

  test('parseAlAdhanTime strips the timezone suffix and applies the date', () {
    final day = DateTime(2026, 3, 15);
    final result = parseAlAdhanTime('05:12 (+03)', day);

    expect(result, DateTime(2026, 3, 15, 5, 12));
  });

  test('monthCacheKey is stable for the same inputs and varies with them', () {
    final key1 = monthCacheKey(
        latitude: 1.234, longitude: 5.678, method: 3, year: 2026, month: 6);
    final key2 = monthCacheKey(
        latitude: 1.234, longitude: 5.678, method: 3, year: 2026, month: 6);
    final key3 = monthCacheKey(
        latitude: 1.234, longitude: 5.678, method: 3, year: 2026, month: 7);

    expect(key1, key2);
    expect(key1, isNot(key3));
  });

  test('encodeMonthCache/decodeMonthCache round-trips', () {
    final withDates = {
      1: DailyPrayerTimes(
        fajr: DateTime(2026, 6, 1, 5, 10),
        asr: DateTime(2026, 6, 1, 15, 40),
        source: PrayerTimeSource.online,
      ),
    };

    final encoded = encodeMonthCache(withDates);
    final decoded = decodeMonthCache(encoded);

    expect(decoded[1]!.fajr, withDates[1]!.fajr);
    expect(decoded[1]!.asr, withDates[1]!.asr);
  });

  group('PrayerTimesService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('online:false always uses the offline calculation, no network', () async {
      final service = PrayerTimesService(
        httpClient: MockClient((request) async {
          fail('should not make an HTTP request when online is false');
        }),
      );

      final result = await service.timesFor(
        date: DateTime(2026, 6, 1),
        latitude: _lat,
        longitude: _lng,
        online: false,
      );

      expect(result.source, PrayerTimeSource.offline);
    });

    test('caches a fetched month and does not re-fetch on the next lookup',
        () async {
      var fetchCount = 0;
      final service = PrayerTimesService(
        httpClient: MockClient((request) async {
          fetchCount++;
          return http.Response(
            jsonEncode({
              'data': [
                for (var day = 1; day <= 30; day++)
                  {
                    'timings': {
                      'Fajr': '05:10 (+00)',
                      'Asr': '15:40 (+00)',
                    },
                    'date': {
                      'gregorian': {'day': day.toString().padLeft(2, '0')},
                    },
                  },
              ],
            }),
            200,
          );
        }),
      );

      final first = await service.timesFor(
        date: DateTime(2026, 6, 1),
        latitude: _lat,
        longitude: _lng,
        countryCode: 'SA',
      );
      final second = await service.timesFor(
        date: DateTime(2026, 6, 15),
        latitude: _lat,
        longitude: _lng,
        countryCode: 'SA',
      );

      expect(fetchCount, 1, reason: 'second lookup in the same month should hit the cache');
      expect(first.source, PrayerTimeSource.online);
      expect(second.source, PrayerTimeSource.online);
      expect(first.fajr.hour, 5);
      expect(second.asr.day, 15);
    });

    test('falls back to offline when the fetch fails', () async {
      final service = PrayerTimesService(
        httpClient: MockClient((request) async => http.Response('', 500)),
      );

      final result = await service.timesFor(
        date: DateTime(2026, 6, 1),
        latitude: _lat,
        longitude: _lng,
      );

      expect(result.source, PrayerTimeSource.offline);
    });
  });
}
