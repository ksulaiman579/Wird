import 'package:flutter/material.dart';

/// Wraps a Quran segment or [WordCloakText] row with an ayah number badge
/// `﴿N﴾` displayed before the row in RTL layout (M4.1).
class AyahNumberedRow extends StatelessWidget {
  const AyahNumberedRow({
    super.key,
    required this.child,
    this.ayahNumber,
  });

  final Widget child;
  final int? ayahNumber;

  @override
  Widget build(BuildContext context) {
    if (ayahNumber == null) return child;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        // Centre the badge against the verse line rather than pinning it to
        // the top: the Arabic line-height (~2.0) otherwise leaves the badge
        // floating high above the text's optical centre (Item 1.4).
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Text(
              '﴿$ayahNumber﴾',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
