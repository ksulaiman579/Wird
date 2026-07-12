import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

/// The hadith cards' "**Reference:** Bukhari 1, Muslim 1907" line — a bold
/// "Reference:" label followed by gold, tappable citation links (M23
/// design spec). [citations] map a display label (e.g. "Bukhari 1") to an
/// optional tap handler for cross-referencing that edition.
class ReferenceLine extends StatelessWidget {
  const ReferenceLine({super.key, required this.citations});

  final Map<String, VoidCallback?> citations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.colorScheme.secondary;
    final entries = citations.entries.toList();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(AppLocalizations.of(context).referenceLabel, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
        for (var i = 0; i < entries.length; i++)
          GestureDetector(
            onTap: entries[i].value,
            child: Text(
              i == entries.length - 1 ? entries[i].key : '${entries[i].key}, ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: gold,
                decoration: entries[i].value == null ? null : TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
