import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/db/database.dart';
import 'plan_edit_controller.dart';

const _dailyMinuteOptions = [5, 10, 15, 20, 30, 45, 60];
const _juzCount = 30;
const _surahCount = 114;

/// Re-plans the Quran portion of an existing plan: selection type/ids,
/// direction, and daily minutes. Diffs by contentKey under the hood
/// ([applyQuranPlanEdit]) so SM-2 progress on surviving items is
/// untouched — only reachable from Settings for plans that include Quran.
class PlanEditScreen extends ConsumerStatefulWidget {
  const PlanEditScreen({super.key});

  @override
  ConsumerState<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends ConsumerState<PlanEditScreen> {
  bool _loaded = false;
  bool _saving = false;

  String _selectionType = 'whole';
  List<int> _selectedJuz = [];
  List<int> _selectedSurahs = [];
  String _direction = 'normal';
  int _dailyMinutes = 10;

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    final db = ref.read(appDatabaseProvider);
    final plan = await (db.select(db.userPlans)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (plan == null || !mounted) return;

    final ids = plan.quranSelectionJson == null
        ? const <int>[]
        : (jsonDecode(plan.quranSelectionJson!) as List).cast<int>();

    setState(() {
      _selectionType = plan.quranSelectionType ?? 'whole';
      _selectedJuz = _selectionType == 'juz' ? ids : [];
      _selectedSurahs = _selectionType == 'surahs' ? ids : [];
      _direction = plan.direction;
      _dailyMinutes = plan.dailyMinutes;
      _loaded = true;
    });
  }

  List<int> get _selectionIds =>
      _selectionType == 'surahs' ? _selectedSurahs : _selectedJuz;

  bool get _hasValidSelection =>
      _selectionType != 'juz' && _selectionType != 'surahs' ||
      _selectionIds.isNotEmpty;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await applyQuranPlanEdit(
        ref,
        selectionType: _selectionType,
        selectionIds: _selectionIds,
        direction: _direction,
        dailyMinutes: _dailyMinutes,
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save plan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.planEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.planSelection, style: const TextStyle(fontWeight: FontWeight.bold)),
                    RadioGroup<String>(
                      groupValue: _selectionType,
                      onChanged: (v) => setState(() => _selectionType = v!),
                      child: Column(
                        children: [
                          RadioListTile<String>(title: Text(l.planWholeQuran), value: 'whole'),
                          RadioListTile<String>(title: Text(l.planSpecificJuz), value: 'juz'),
                          RadioListTile<String>(title: Text(l.planSpecificSurahs), value: 'surahs'),
                        ],
                      ),
                    ),
                    if (_selectionType == 'juz')
                      _MultiPicker(
                        count: _juzCount,
                        label: 'Juz',
                        selected: _selectedJuz,
                        onChanged: (ids) => setState(() => _selectedJuz = ids),
                      ),
                    if (_selectionType == 'surahs')
                      _MultiPicker(
                        count: _surahCount,
                        label: l.commonSurahWord,
                        selected: _selectedSurahs,
                        onChanged: (ids) => setState(() => _selectedSurahs = ids),
                      ),
                    const SizedBox(height: 16),
                    Text(l.planDirection, style: const TextStyle(fontWeight: FontWeight.bold)),
                    RadioGroup<String>(
                      groupValue: _direction,
                      onChanged: (v) => setState(() => _direction = v!),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text(l.planNormalOrder),
                            value: 'normal',
                          ),
                          RadioListTile<String>(
                            title: Text(l.planReversedOrder),
                            value: 'reversed',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l.planDailyMinutes, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _dailyMinuteOptions.map((minutes) {
                        return ChoiceChip(
                          label: Text(l.commonMinutesShort(minutes)),
                          selected: _dailyMinutes == minutes,
                          onSelected: (_) => setState(() => _dailyMinutes = minutes),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_hasValidSelection && !_saving) ? _save : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.planSaveChanges),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiPicker extends StatelessWidget {
  const _MultiPicker({
    required this.count,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final int count;
  final String label;
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(count, (i) => i + 1).map((n) {
        final isSelected = selected.contains(n);
        return FilterChip(
          label: Text('$label $n'),
          selected: isSelected,
          onSelected: (v) {
            final next = [...selected];
            if (v) {
              next.add(n);
            } else {
              next.remove(n);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
