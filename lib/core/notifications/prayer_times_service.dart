import 'dart:convert';
import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_plan.dart';

enum PrayerTimeSource { online, offline }

class DailyPrayerTimes {
  const DailyPrayerTimes({
    required this.fajr,
    required this.asr,
    required this.source,
  });

  final DateTime fajr;
  final DateTime asr;
  final PrayerTimeSource source;
}

/// AlAdhan API `method` parameter for each country's official Sunni
/// prayer-time authority, where a well-known one exists. Countries not
/// listed here fall back to [defaultCalculationMethod] (Muslim World
/// League) — a manual override list belongs in Settings (M7.3), not here.
const Map<String, int> countryCalculationMethods = {
  'SA': 4, // Umm al-Qura University, Makkah
  'AE': 8, 'QA': 8, 'BH': 8, 'KW': 8, 'OM': 8, // Gulf Region
  'EG': 5, // Egyptian General Authority of Survey
  'PK': 1, // University of Islamic Sciences, Karachi
  'TR': 13, // Diyanet İşleri Başkanlığı, Turkey
  'US': 2, 'CA': 2, // ISNA
};

const int defaultCalculationMethod = 3; // Muslim World League

/// Human-readable names for every method this app can select — both the
/// auto-mapped ones in [countryCalculationMethods] and a couple of extra
/// well-known ones — for Settings' manual override picker (M7.3).
const Map<int, String> calculationMethodNames = {
  1: 'University of Islamic Sciences, Karachi',
  2: 'Islamic Society of North America (ISNA)',
  3: 'Muslim World League',
  4: 'Umm al-Qura University, Makkah',
  5: 'Egyptian General Authority of Survey',
  8: 'Gulf Region',
  12: 'Union Organization Islamic de France',
  13: 'Diyanet İşleri Başkanlığı, Turkey',
};

/// [override] wins when given (Settings' manual method picker); otherwise
/// falls back to the country's official authority, or
/// [defaultCalculationMethod] if neither is known.
int calculationMethodFor(String? countryCode, {int? override}) =>
    override ??
    countryCalculationMethods[countryCode?.toUpperCase()] ??
    defaultCalculationMethod;

/// Pure offline calculation via `adhan_dart` — no network, no platform
/// dependency, always available.
DailyPrayerTimes calculateOffline({
  required DateTime date,
  required double latitude,
  required double longitude,
  Madhab madhab = Madhab.shafi,
}) {
  final params = CalculationMethodParameters.muslimWorldLeague();
  params.madhab = madhab;
  final times = PrayerTimes(
    date: date,
    coordinates: Coordinates(latitude, longitude),
    calculationParameters: params,
  );
  return DailyPrayerTimes(
    fajr: times.fajr,
    asr: times.asr,
    source: PrayerTimeSource.offline,
  );
}

/// All five daily prayer times, offline via `adhan_dart`. Adhan reminders
/// (buildAdhanPlan) need every salah, not just the Fajr/Asr the adhkar
/// windows use — computed offline (no network/cache) since these are
/// ±minutes reminders, matching the rest of this file's philosophy.
Map<Salah, DateTime> calculateAllPrayersOffline({
  required DateTime date,
  required double latitude,
  required double longitude,
  Madhab madhab = Madhab.shafi,
}) {
  final params = CalculationMethodParameters.muslimWorldLeague();
  params.madhab = madhab;
  final times = PrayerTimes(
    date: date,
    coordinates: Coordinates(latitude, longitude),
    calculationParameters: params,
  );
  return {
    Salah.fajr: times.fajr,
    Salah.dhuhr: times.dhuhr,
    Salah.asr: times.asr,
    Salah.maghrib: times.maghrib,
    Salah.isha: times.isha,
  };
}

String monthCacheKey({
  required double latitude,
  required double longitude,
  required int method,
  required int year,
  required int month,
}) {
  final latKey = latitude.toStringAsFixed(2);
  final lngKey = longitude.toStringAsFixed(2);
  return 'prayer_times_cache_${latKey}_${lngKey}_${method}_${year}_$month';
}

String encodeMonthCache(Map<int, DailyPrayerTimes> byDay) {
  return jsonEncode({
    for (final entry in byDay.entries)
      '${entry.key}': {
        'fajr': entry.value.fajr.toIso8601String(),
        'asr': entry.value.asr.toIso8601String(),
      },
  });
}

Map<int, DailyPrayerTimes> decodeMonthCache(String json) {
  final decoded = jsonDecode(json) as Map<String, dynamic>;
  return {
    for (final entry in decoded.entries)
      int.parse(entry.key): DailyPrayerTimes(
        fajr: DateTime.parse(
            (entry.value as Map<String, dynamic>)['fajr'] as String),
        asr: DateTime.parse(
            (entry.value as Map<String, dynamic>)['asr'] as String),
        source: PrayerTimeSource.online,
      ),
  };
}

/// Parses one AlAdhan `data[].timings.Fajr`/`.Asr`-style string (e.g.
/// `"05:12 (+03)"`) against the calendar day it belongs to.
DateTime parseAlAdhanTime(String raw, DateTime day) {
  final hhmm = raw.split(' ').first; // strip the "(+03)" timezone suffix
  final parts = hhmm.split(':');
  return DateTime(
    day.year,
    day.month,
    day.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}

/// Fetches one calendar month of Fajr/Asr times from the AlAdhan API,
/// keyed by day-of-month. Network-only — not unit-tested against a real
/// network call in this environment; [parseAlAdhanTime] (the actual
/// parsing logic) is tested directly, and [PrayerTimesService]'s tests use
/// `http`'s `MockClient` to exercise this without a real request.
Future<Map<int, DailyPrayerTimes>> fetchMonthFromAlAdhan({
  required http.Client client,
  required double latitude,
  required double longitude,
  required int method,
  required int year,
  required int month,
}) async {
  final uri = Uri.https('api.aladhan.com', '/v1/calendar', {
    'latitude': '$latitude',
    'longitude': '$longitude',
    'method': '$method',
    'month': '$month',
    'year': '$year',
  });
  final response = await client.get(uri);
  if (response.statusCode != 200) {
    throw HttpException('AlAdhan API returned ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final data = decoded['data'] as List;
  final result = <int, DailyPrayerTimes>{};

  for (final entry in data) {
    final timings = entry['timings'] as Map<String, dynamic>;
    final gregorian = entry['date']['gregorian'] as Map<String, dynamic>;
    final day = int.parse(gregorian['day'] as String);
    final date = DateTime(year, month, day);
    result[day] = DailyPrayerTimes(
      fajr: parseAlAdhanTime(timings['Fajr'] as String, date),
      asr: parseAlAdhanTime(timings['Asr'] as String, date),
      source: PrayerTimeSource.online,
    );
  }
  return result;
}

/// Combines the online AlAdhan monthly calendar (cached in
/// shared_preferences so one HTTP call covers the whole month) with the
/// `adhan_dart` offline fallback — used whenever [online] is false, the
/// fetch fails (no network), or the cache/fetch throws for any reason.
class PrayerTimesService {
  PrayerTimesService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<DailyPrayerTimes> timesFor({
    required DateTime date,
    required double latitude,
    required double longitude,
    String? countryCode,
    int? methodOverride,
    bool online = true,
  }) async {
    if (online) {
      try {
        final method = calculationMethodFor(countryCode, override: methodOverride);
        final month = await _cachedMonth(
              latitude: latitude,
              longitude: longitude,
              method: method,
              year: date.year,
              month: date.month,
            ) ??
            await _fetchAndCacheMonth(
              latitude: latitude,
              longitude: longitude,
              method: method,
              year: date.year,
              month: date.month,
            );
        final dayTimes = month[date.day];
        if (dayTimes != null) return dayTimes;
      } catch (_) {
        // Fall through to the offline calculation below.
      }
    }
    return calculateOffline(date: date, latitude: latitude, longitude: longitude);
  }

  Future<Map<int, DailyPrayerTimes>?> _cachedMonth({
    required double latitude,
    required double longitude,
    required int method,
    required int year,
    required int month,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(monthCacheKey(
      latitude: latitude,
      longitude: longitude,
      method: method,
      year: year,
      month: month,
    ));
    return raw == null ? null : decodeMonthCache(raw);
  }

  Future<Map<int, DailyPrayerTimes>> _fetchAndCacheMonth({
    required double latitude,
    required double longitude,
    required int method,
    required int year,
    required int month,
  }) async {
    final fetched = await fetchMonthFromAlAdhan(
      client: _httpClient,
      latitude: latitude,
      longitude: longitude,
      method: method,
      year: year,
      month: month,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      monthCacheKey(
        latitude: latitude,
        longitude: longitude,
        method: method,
        year: year,
        month: month,
      ),
      encodeMonthCache(fetched),
    );
    return fetched;
  }
}
