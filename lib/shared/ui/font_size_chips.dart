import 'package:flutter/material.dart';

/// The renders' "A+ / A−" reading-font-size control (hadith list/detail
/// cards, M23 design spec). Purely presentational — [onIncrease]/
/// [onDecrease] are wired to whatever text-scale state the screen owns.
class FontSizeChips extends StatelessWidget {
  const FontSizeChips({super.key, required this.onIncrease, required this.onDecrease});

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip(context, 'A+', onIncrease),
        const SizedBox(width: 6),
        _chip(context, 'A−', onDecrease),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
