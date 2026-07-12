import '../content/models/quran_models.dart';

/// A contiguous group of ayahs within one surah that becomes a single SRS
/// item, e.g. `q:2:1-5`. Never spans more than one surah, and never splits
/// an ayah — a single ayah longer than [maxGroupWords] simply becomes its
/// own (oversized) group.
class AyahGroup {
  const AyahGroup({
    required this.surah,
    required this.startAyah,
    required this.endAyah,
    required this.wordCount,
  });

  final int surah;
  final int startAyah;
  final int endAyah;
  final int wordCount;

  String get contentKey =>
      startAyah == endAyah ? 'q:$surah:$startAyah' : 'q:$surah:$startAyah-$endAyah';
}

/// The surah/ayah-range a Quran `contentKey` refers to — the inverse of
/// [AyahGroup.contentKey]. Shared by content loading (`session_content_
/// provider.dart`) and audio playback (needs the concrete ayah numbers to
/// build per-ayah URLs), so the format is decoded in exactly one place.
class QuranContentRef {
  const QuranContentRef({
    required this.surah,
    required this.startAyah,
    required this.endAyah,
  });

  final int surah;
  final int startAyah;
  final int endAyah;

  List<int> get ayahs => [for (var a = startAyah; a <= endAyah; a++) a];
}

/// Parses a `q:<surah>:<startAyah>[-<endAyah>]` contentKey. Returns null for
/// anything else (a non-Quran contentKey, or a malformed one).
QuranContentRef? parseQuranContentKey(String contentKey) {
  if (!contentKey.startsWith('q:')) return null;

  final parts = contentKey.substring(2).split(':');
  if (parts.length != 2) return null;

  final surah = int.tryParse(parts[0]);
  final range = parts[1].split('-');
  final startAyah = int.tryParse(range[0]);
  final endAyah = range.length > 1 ? int.tryParse(range[1]) : startAyah;
  if (surah == null || startAyah == null || endAyah == null) return null;

  return QuranContentRef(surah: surah, startAyah: startAyah, endAyah: endAyah);
}

const int minGroupWords = 15;
const int maxGroupWords = 25;

/// Groups a contiguous, ascending-order run of ayahs from a single surah
/// into ~[minGroupWords]-[maxGroupWords]-word chunks.
List<AyahGroup> groupAyahs(int surahNumber, List<Ayah> ayahs) {
  final groups = <AyahGroup>[];
  var i = 0;

  while (i < ayahs.length) {
    var wordSum = ayahs[i].wordCount;
    var j = i;

    while (j + 1 < ayahs.length) {
      if (wordSum >= minGroupWords) break;
      final nextWordCount = ayahs[j + 1].wordCount;
      if (wordSum + nextWordCount > maxGroupWords) break;
      wordSum += nextWordCount;
      j++;
    }

    groups.add(AyahGroup(
      surah: surahNumber,
      startAyah: ayahs[i].ayah,
      endAyah: ayahs[j].ayah,
      wordCount: wordSum,
    ));
    i = j + 1;
  }

  return groups;
}
