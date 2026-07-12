import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wird/l10n/gen/app_localizations.dart';

/// The full `DATA_SOURCES.md` provenance/license detail, moved off the
/// main About screen (M23 feedback: About should show only what's
/// necessary — this detail stays reachable, just one tap further in).
class DataSourcesScreen extends StatelessWidget {
  const DataSourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).dataSourcesTitle)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('DATA_SOURCES.md'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snapshot.data!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          );
        },
      ),
    );
  }
}
