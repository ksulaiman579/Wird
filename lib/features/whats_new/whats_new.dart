import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

const _lastSeenKey = 'whats_new_last_seen_code';

Future<int> _currentBuildCode() async {
  final info = await PackageInfo.fromPlatform();
  return int.tryParse(info.buildNumber) ?? 0;
}

/// Records the current build as "seen" without showing anything — used for a
/// brand-new install so the user isn't shown a changelog for the version they
/// just installed.
Future<void> recordWhatsNewSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_lastSeenKey, await _currentBuildCode());
}

/// Shows a one-time "What's new" dialog when the app has been updated to a
/// newer build than the user last saw. Works on every platform (PWA + native).
/// A returning user with no record yet (i.e. updating into the first build that
/// carries this feature) still sees the notes for the current build.
Future<void> maybeShowWhatsNew(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final current = await _currentBuildCode();
  final lastSeen = prefs.getInt(_lastSeenKey);
  if (lastSeen != null && current <= lastSeen) return;
  if (!context.mounted) return;

  final localeCode = Localizations.localeOf(context).languageCode;
  final notes = await _loadNotes(current, localeCode);
  await prefs.setInt(_lastSeenKey, current);
  if (notes == null || notes.items.isEmpty || !context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (_) => _WhatsNewDialog(notes: notes),
  );
}

class _Notes {
  const _Notes({required this.title, required this.items});
  final String title;
  final List<String> items;
}

/// Loads the release notes for [buildCode] in [localeCode] from the bundled
/// `whats_new.json`, falling back to English, then to null if the build has no
/// entry (so unknown builds simply show nothing).
Future<_Notes?> _loadNotes(int buildCode, String localeCode) async {
  try {
    final raw = await rootBundle.loadString('assets/data/whats_new.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final entry = map['$buildCode'] as Map<String, dynamic>?;
    if (entry == null) return null;

    String pick(String field) {
      final byLocale = entry[field] as Map<String, dynamic>;
      return (byLocale[localeCode] ?? byLocale['en']) as String;
    }

    final itemsByLocale = entry['items'] as Map<String, dynamic>;
    final items = (itemsByLocale[localeCode] ?? itemsByLocale['en']) as List;
    return _Notes(
      title: pick('title'),
      items: items.cast<String>(),
    );
  } catch (_) {
    return null;
  }
}

class _WhatsNewDialog extends StatelessWidget {
  const _WhatsNewDialog({required this.notes});
  final _Notes notes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(notes.title)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in notes.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(Icons.check_circle_rounded,
                            size: 16, color: scheme.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonDone),
        ),
      ],
    );
  }
}
