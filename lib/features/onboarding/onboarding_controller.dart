import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/chunking/selection_ordering.dart';
import '../../core/content/dua_repository.dart';
import '../../core/content/hadith_repository.dart';
import '../../core/content/models/quran_models.dart';
import '../../core/content/quran_repository.dart';
import '../../core/db/database.dart';
import 'onboarding_state.dart';

class OnboardingController extends Notifier<OnboardingFormState> {
  @override
  OnboardingFormState build() => const OnboardingFormState();

  void updateProfile({String? name, String? avatarEmoji}) {
    state = state.copyWith(name: name, avatarEmoji: avatarEmoji);
  }

  void updateScope({bool? wantsQuran, bool? wantsHadith, bool? wantsDuas}) {
    state = state.copyWith(
      wantsQuran: wantsQuran,
      wantsHadith: wantsHadith,
      wantsDuas: wantsDuas,
    );
  }

  void updateQuranSelection({
    String? selectionType,
    List<int>? selectedJuz,
    List<int>? selectedSurahs,
    String? direction,
  }) {
    state = state.copyWith(
      quranSelectionType: selectionType,
      selectedJuz: selectedJuz,
      selectedSurahs: selectedSurahs,
      direction: direction,
    );
  }

  void updateDailyMinutes(int minutes) {
    state = state.copyWith(dailyMinutes: minutes);
  }

  /// Total Quran word count for the current selection — used for the
  /// onboarding completion-date estimate. Loads whatever surahs the
  /// selection touches.
  Future<int> quranWordCountForSelection() async {
    if (!state.wantsQuran) return 0;

    final quranRepo = ref.read(quranRepositoryProvider);
    final meta = await quranRepo.loadMeta();
    final slices = orderSelection(
      meta: meta,
      selectionType: state.quranSelectionType,
      selectionIds: state.quranSelectionIds,
      direction: state.direction,
    );

    var total = 0;
    for (final surahNumber in slices.map((s) => s.surah).toSet()) {
      final surah = await quranRepo.loadSurah(surahNumber);
      for (final slice in slices.where((s) => s.surah == surahNumber)) {
        total += surah.ayahs
            .where((a) => a.ayah >= slice.startAyah && a.ayah <= slice.endAyah)
            .fold<int>(0, (sum, a) => sum + a.wordCount);
      }
    }
    return total;
  }

  /// Writes the profile, plan, and every generated SRS item, in one
  /// transaction. Hadith scope always includes the 40 core hadiths in
  /// their traditional order (Nawawi's collection has no direction
  /// concept). The duas toggle seeds the morning/evening adhkar set as a
  /// starter memorization queue — a judgment call, since onboarding has
  /// no dedicated dua-picking step; users can add/remove individual duas
  /// later from the Dua browser.
  Future<void> complete() async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();

    await db.transaction(() async {
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              name: state.name.trim().isEmpty ? 'Friend' : state.name.trim(),
              avatarEmoji: Value(state.avatarEmoji),
              createdAt: now,
            ),
          );

      await db.into(db.userPlans).insert(
            UserPlansCompanion.insert(
              id: const Value(1),
              scope: state.scope,
              quranSelectionType: Value(
                state.wantsQuran ? state.quranSelectionType : null,
              ),
              quranSelectionJson: Value(
                state.wantsQuran
                    ? jsonEncode(state.quranSelectionIds)
                    : null,
              ),
              direction: Value(state.direction),
              dailyMinutes: state.dailyMinutes,
              createdAt: now,
            ),
          );

      final items = <SrsItemsCompanion>[];
      var orderIndex = 0;

      if (state.wantsQuran) {
        final quranRepo = ref.read(quranRepositoryProvider);
        final QuranMeta meta = await quranRepo.loadMeta();
        final slices = orderSelection(
          meta: meta,
          selectionType: state.quranSelectionType,
          selectionIds: state.quranSelectionIds,
          direction: state.direction,
        );
        final touchedSurahs = slices.map((s) => s.surah).toSet();
        final ayahsBySurah = {
          for (final surahNumber in touchedSurahs)
            surahNumber: (await quranRepo.loadSurah(surahNumber)).ayahs,
        };

        final groups = planQuranItems(
          meta: meta,
          ayahsBySurah: ayahsBySurah,
          selectionType: state.quranSelectionType,
          selectionIds: state.quranSelectionIds,
          direction: state.direction,
        );
        for (final group in groups) {
          items.add(SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: group.contentKey,
            orderIndex: orderIndex++,
            wordCount: group.wordCount,
          ));
        }
      }

      if (state.wantsHadith) {
        final hadithRepo = ref.read(hadithRepositoryProvider);
        final hadiths = (await hadithRepo.loadAll())
            .where((h) => h.core)
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
        for (final hadith in hadiths) {
          items.add(SrsItemsCompanion.insert(
            contentType: 'hadith',
            contentKey: 'h:nawawi:${hadith.id}',
            orderIndex: orderIndex++,
            wordCount: hadith.wordCount,
          ));
        }
      }

      if (state.wantsDuas) {
        final duaRepo = ref.read(duaRepositoryProvider);
        final adhkar = await duaRepo.loadAdhkar();
        for (final dhikr in adhkar.morning) {
          items.add(SrsItemsCompanion.insert(
            contentType: 'dua',
            contentKey: 'd:${dhikr.id}',
            orderIndex: orderIndex++,
            wordCount: dhikr.wordCount,
          ));
        }
      }

      await db.batch((batch) => batch.insertAll(db.srsItems, items));
    });
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingFormState>(
  OnboardingController.new,
);
