import 'package:flutter/material.dart';

/// A bold section label within a hub page ("Surah Collections", "Calculate
/// & Navigate", "Time-Aware Reminders" — M23 design spec). Uses the app's
/// Marcellus display face (wired in `AppTheme._build`'s `titleLarge`) so
/// section headers carry the same "carved" presence as page titles, one
/// step down in size.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.padding = const EdgeInsets.fromLTRB(4, 24, 4, 12)});

  final String title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
