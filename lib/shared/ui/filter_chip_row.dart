import 'package:flutter/material.dart';

/// The renders' "Bookmarked / Recent" style filter row: a horizontal set of
/// single-select toggle chips (M23 design spec). Generic over [T] so the
/// same widget serves Bookmarked/Recent, Morning/Evening, Presets/Custom,
/// etc.
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelOf,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(labelOf(option)),
            selected: option == selected,
            onSelected: (_) => onChanged(option),
            selectedColor: theme.colorScheme.secondary.withValues(alpha: 0.22),
            labelStyle: TextStyle(
              fontWeight: option == selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
