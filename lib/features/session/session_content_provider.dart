import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/chunking/ayah_grouper.dart' show parseQuranContentKey;
import '../../core/content/dua_repository.dart';
import '../../core/content/hadith_repository.dart';
import '../../core/content/models/dua_models.dart';
import '../../core/content/quran_repository.dart';

/// Display-ready content for one session queue entry, keyed by the item's
/// (contentType, contentKey) so quran/hadith/dua all render through the
/// same new-material and review flows. [arabicSegments] has one entry per
/// ayah for a Quran group (enabling per-ayah fading and chain recall), or a
/// single entry for a hadith/dua.
class SessionItemContent {
  const SessionItemContent({
    required this.title,
    required this.arabicSegments,
    required this.translationSegments,
    this.transliterationSegments = const [],
    this.meaningNote,
    this.distractorWordPool = const [],
    this.ayahNumbers = const [],
  });

  final String title;
  final List<String> arabicSegments;
  final List<String> translationSegments;

  /// Per-segment transliteration (Quran items only; empty for hadith/dua
  /// whose bundled data has none). Shown in the memorization Listen step
  /// when the user enables it (M22.4).
  final List<String> transliterationSegments;

  /// Hadith summary or dua reference — shown once during the meaning step.
  final String? meaningNote;

  /// Words from elsewhere in the same surah (Quran items only), for M6.4's
  /// micro-exercises to draw wrong-answer choices from. Empty for
  /// hadith/dua, which have no comparable surrounding word pool.
  final List<String> distractorWordPool;

  /// Ayah numbers corresponding to each segment in [arabicSegments] for Quran items.
  final List<int> ayahNumbers;
}

final sessionItemContentProvider =
    FutureProvider.family<SessionItemContent, (String, String)>(
        (ref, key) async {
  final (contentType, contentKey) = key;
  switch (contentType) {
    case 'quran':
      return _loadQuranContent(ref, contentKey);
    case 'hadith':
      return _loadHadithContent(ref, contentKey);
    case 'dua':
      return _loadDuaContent(ref, contentKey);
    default:
      throw ArgumentError('unknown contentType: $contentType');
  }
});

Future<SessionItemContent> _loadQuranContent(Ref ref, String contentKey) async {
  final parsed = parseQuranContentKey(contentKey)!;
  final surahNumber = parsed.surah;
  final startAyah = parsed.startAyah;
  final endAyah = parsed.endAyah;

  final quranRepo = ref.read(quranRepositoryProvider);
  final meta = await quranRepo.loadMeta();
  final surahMeta = meta.surahs.firstWhere((s) => s.number == surahNumber);
  final surah = await quranRepo.loadSurah(surahNumber);
  final ayahs = surah.ayahs
      .where((a) => a.ayah >= startAyah && a.ayah <= endAyah)
      .toList()
    ..sort((a, b) => a.ayah.compareTo(b.ayah));

  final distractorWordPool = [
    for (final a in surah.ayahs)
      if (a.ayah < startAyah || a.ayah > endAyah)
        ...a.arabic.split(RegExp(r'\s+')).where((w) => w.isNotEmpty),
  ];

  return SessionItemContent(
    title: '${surahMeta.nameTransliterated} '
        '$startAyah${endAyah != startAyah ? '-$endAyah' : ''}',
    arabicSegments: [for (final a in ayahs) a.arabic],
    translationSegments: [for (final a in ayahs) a.translation],
    transliterationSegments: [for (final a in ayahs) a.transliteration],
    distractorWordPool: distractorWordPool,
    ayahNumbers: [for (final a in ayahs) a.ayah],
  );
}

Future<SessionItemContent> _loadHadithContent(
    Ref ref, String contentKey) async {
  // Format: h:<collection>:<n>, e.g. h:nawawi:1. Only the Nawawi 42 is
  // wired into SRS today (M13.5 wires the new downloadable collections
  // into the reader, not the review queue).
  final rest = contentKey.substring('h:'.length);
  final collection = rest.substring(0, rest.indexOf(':'));
  final id = int.parse(rest.substring(collection.length + 1));
  if (collection != 'nawawi') {
    throw UnimplementedError(
        'SRS review for hadith collection "$collection" not yet supported');
  }
  final hadith = await ref.read(hadithRepositoryProvider).loadById(id);

  return SessionItemContent(
    title: 'Hadith ${hadith.id}: ${hadith.titleEnglish}',
    arabicSegments: [hadith.arabic],
    translationSegments: [hadith.translation],
    meaningNote: hadith.summary,
  );
}

Future<SessionItemContent> _loadDuaContent(Ref ref, String contentKey) async {
  final id = contentKey.substring('d:'.length);
  final duaRepo = ref.read(duaRepositoryProvider);

  final adhkar = await duaRepo.loadAdhkar();
  var dua = _findDua([...adhkar.morning, ...adhkar.evening], id);

  if (dua == null) {
    final categories = await duaRepo.loadCategories();
    for (final category in categories.categories) {
      dua = _findDua(category.duas, id);
      if (dua != null) break;
    }
  }

  final found = dua!;
  return SessionItemContent(
    title: found.reference,
    arabicSegments: [found.arabic],
    translationSegments: [found.translation],
    meaningNote: found.reference,
  );
}

Dua? _findDua(Iterable<Dua> duas, String id) {
  for (final d in duas) {
    if (d.id == id) return d;
  }
  return null;
}
