# Regression plan

## Every release
1. `flutter analyze` must show 0 errors, and `flutter test` must pass in full.
2. `python -I tool/audit/quran_audit.py`: 114 surahs, 6,236 ayahs, 30 juz, and only the 3 known spellings.
3. `python -I tool/audit/hadith_audit.py`: counts match, and there are no new one-sided blank lines.
4. `python -I tool/audit/library_links.py`: no new dead links.
5. Live site checks: `curl` returns 200 for `wird-alpha.vercel.app`, `/.well-known/assetlinks.json` and `update.json`, and `update.json` carries a sha256.
6. Emulator, fresh install in Urdu:
   - Run onboarding.
   - Check the Urdu translation shows in the reader.
   - Download a hadith book and open it offline.
   - Share an ayah.
   - Open a shared link from the home screen and from Settings.
7. `adb shell dumpsys alarm`: the adhan alarms have no lateness window, once WQA-024 is fixed.

## Tests to add with each fix
| Fix | Test |
|---|---|
| WQA-004 | Fixture with overlapping ranges; also check that no book ends up empty. |
| WQA-014 / 015 | `resolveHadithGrade` with mixed graders, and with "Shadh". |
| WQA-024 | The adhan uses exact scheduling. |
| WQA-025 | Finishing onboarding in Urdu installs a translation pack. |
| WQA-028 / 033 / 020 | Router tests: a link while on Settings, a repeat search link, bad links. |
| WQA-026 | Counter direction in Arabic and Urdu. |
| WQA-034 | Every tappable control has a semantics label. |
