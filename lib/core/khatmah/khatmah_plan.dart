/// Khatmah (whole-Quran reading) plan: split the Quran into N daily
/// portions of roughly equal length. Pure Dart, no Flutter imports.
///
/// A plan is just (start date, number of days), so it fits in a short
/// link: `/khatmah?start=2027-02-18&days=30`.
library;

import '../calendar_math.dart';

/// One ayah position.
class AyahRef {
  const AyahRef(this.surah, this.ayah);
  final int surah;
  final int ayah;

  @override
  bool operator ==(Object other) =>
      other is AyahRef && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => '$surah:$ayah';
}

/// One day's reading: from [start] to [end], inclusive.
class KhatmahPortion {
  const KhatmahPortion(this.day, this.start, this.end);

  /// 1-based day number.
  final int day;
  final AyahRef start;
  final AyahRef end;
}

/// Splits ayahs (in Quran order, each with a weight such as its word
/// count) into [days] consecutive portions of about equal total weight.
/// Never splits an ayah; every day gets at least one ayah when
/// days <= ayah count.
List<KhatmahPortion> splitKhatmah(
  List<(AyahRef, int)> weightedAyahs,
  int days,
) {
  if (days < 1 || weightedAyahs.isEmpty) return const [];
  final n = weightedAyahs.length;
  final d = days > n ? n : days;
  final total = weightedAyahs.fold<int>(0, (s, a) => s + a.$2);

  final portions = <KhatmahPortion>[];
  var i = 0;
  var done = 0;
  for (var day = 1; day <= d; day++) {
    final startIndex = i;
    // Last day takes everything left.
    if (day == d) {
      i = n;
    } else {
      final target = total * day / d;
      // Leave at least one ayah for each remaining day.
      final maxEnd = n - (d - day);
      while (i < maxEnd &&
          (i == startIndex || done + weightedAyahs[i].$2 / 2 <= target)) {
        done += weightedAyahs[i].$2;
        i++;
      }
    }
    portions.add(KhatmahPortion(
      day,
      weightedAyahs[startIndex].$1,
      weightedAyahs[i - 1].$1,
    ));
  }
  return portions;
}

/// Which day of a plan [today] falls on (1-based), or null when outside.
int? khatmahDayFor(DateTime start, int days, DateTime today) {
  final diff = daysBetweenCalendarDates(start, today);
  if (diff < 0 || diff >= days) return null;
  return diff + 1;
}

/// Plan link query, e.g. `start=2027-02-18&days=30`.
String khatmahQuery(DateTime start, int days) =>
    'start=${dayKeyFor(start)}&days=$days';

/// Parses a plan link's query values; null when invalid.
(DateTime, int)? parseKhatmahQuery(String? start, String? days) {
  if (start == null || days == null) return null;
  final d = int.tryParse(days);
  final s = DateTime.tryParse(start);
  if (d == null || s == null || d < 1 || d > 365) return null;
  return (dateOnly(s), d);
}
