/// Pure per-ayah audio logic: reciter catalogue, everyayah.com URL/on-disk
/// filename builders, and loop/repeat configuration. No Flutter or
/// just_audio imports — plain Dart so it stays trivially unit-testable;
/// `ayah_audio_service.dart` is the thin just_audio-wrapping layer on top.
library;

/// Reciters available for verse-by-verse audio, keyed by the everyayah.com
/// folder name (also used as the on-disk download subfolder — see M4.3).
///
/// Every folder below was verified against everyayah.com (M23.8) by
/// requesting the first (001001), last (114006), and scattered mid-range
/// ayahs and confirming HTTP 200 — everyayah publishes each reciter as a
/// complete 6236-file set, so a folder that serves those brackets is a
/// full set. Bitrate is part of the folder name upstream; kept in the
/// label so the download-size trade-off is visible in the picker.
const Map<String, String> reciters = {
  'Husary_128kbps': 'Al-Husary (Murattal) — 128kbps',
  'Husary_Muallim_128kbps': 'Al-Husary (Muallim / teaching) — 128kbps',
  'Alafasy_128kbps': 'Mishary Alafasy — 128kbps',
  'Abdul_Basit_Murattal_64kbps': 'Abdul Basit (Murattal) — 64kbps',
  'Abdul_Basit_Murattal_192kbps': 'Abdul Basit (Murattal) — 192kbps',
  'Minshawy_Murattal_128kbps': 'Al-Minshawi (Murattal) — 128kbps',
  'Minshawy_Mujawwad_192kbps': 'Al-Minshawi (Mujawwad) — 192kbps',
  'Abdurrahmaan_As-Sudais_192kbps': 'As-Sudais — 192kbps',
  'Saood_ash-Shuraym_128kbps': 'Ash-Shuraim — 128kbps',
  'Ahmed_ibn_Ali_al_Ajamy_128kbps': 'Al-Ajmy — 128kbps',
  'Ghamadi_40kbps': 'Al-Ghamdi — 40kbps',
  'Hudhaify_128kbps': 'Al-Hudhaify — 128kbps',
  'Maher_AlMuaiqly_64kbps': 'Maher Al-Muaiqly — 64kbps',
  'Muhammad_Ayyoub_128kbps': 'Muhammad Ayyoub — 128kbps',
  'Abu_Bakr_Ash-Shaatree_128kbps': 'Abu Bakr Ash-Shatri — 128kbps',
  'Nasser_Alqatami_128kbps': 'Nasser Al-Qatami — 128kbps',
  'Yasser_Ad-Dussary_128kbps': 'Yasser Ad-Dossari — 128kbps',
  'Ali_Jaber_64kbps': 'Ali Jaber — 64kbps',
};

const String defaultReciter = 'Husary_128kbps';

const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// How many times a loop step repeats before advancing/stopping. `infinite`
/// loops until the user stops it manually.
enum RepeatCount { three, five, ten, infinite }

extension RepeatCountValue on RepeatCount {
  /// Target repeat count, or null for [RepeatCount.infinite].
  int? get times => switch (this) {
    RepeatCount.three => 3,
    RepeatCount.five => 5,
    RepeatCount.ten => 10,
    RepeatCount.infinite => null,
  };
}

/// Whether looping replays a single ayah or the whole group before the
/// repeat counter advances.
enum LoopScope { single, group }

/// Everyayah.com per-ayah URL: `https://everyayah.com/data/<reciter>/<SSS><AAA>.mp3`.
String ayahAudioUrl({
  required String reciter,
  required int surah,
  required int ayah,
}) {
  return 'https://everyayah.com/data/$reciter/${ayahAudioFileName(surah: surah, ayah: ayah)}';
}

/// The per-ayah filename (`<SSS><AAA>.mp3`), shared by the URL builder above
/// and the download manager's (M4.3) on-disk layout, so playback can check
/// for a locally downloaded file using the exact same name it would have
/// been saved under.
String ayahAudioFileName({required int surah, required int ayah}) {
  final surahPadded = surah.toString().padLeft(3, '0');
  final ayahPadded = ayah.toString().padLeft(3, '0');
  return '$surahPadded$ayahPadded.mp3';
}

/// Whether a loop step that has just completed [completedCount] play(s)
/// should play again, given the user's chosen [target].
bool shouldRepeatAgain(int completedCount, RepeatCount target) {
  final times = target.times;
  return times == null || completedCount < times;
}
