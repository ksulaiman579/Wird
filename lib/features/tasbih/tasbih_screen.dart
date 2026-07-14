import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/haptics.dart';
import '../../shared/glass/glass.dart';
import 'tasbih_providers.dart';

/// One stage of a multi-stage preset (e.g. SubhanAllah x33, then
/// Alhamdulillah x33, then Allahu Akbar x34).
class _TasbihStage {
  const _TasbihStage(this.label, this.count);
  final String label;
  final int count;
}

class _TasbihPreset {
  const _TasbihPreset(this.label, this.stages);
  final String label;
  final List<_TasbihStage> stages;

  int get total => stages.fold(0, (sum, s) => sum + s.count);
}

const _classicPreset = _TasbihPreset(
    '33 - 33 - 34 (SubhanAllah, Alhamdulillah, Allahu Akbar)', [
  _TasbihStage('SubhanAllah', 33),
  _TasbihStage('Alhamdulillah', 33),
  _TasbihStage('Allahu Akbar', 34),
]);
const _hundredPreset = _TasbihPreset('100', [_TasbihStage('Dhikr', 100)]);

const _subhanAllah33 =
    _TasbihPreset('SubhanAllah (33)', [_TasbihStage('SubhanAllah', 33)]);
const _alhamdulillah33 =
    _TasbihPreset('Alhamdulillah (33)', [_TasbihStage('Alhamdulillah', 33)]);
const _allahuAkbar33 =
    _TasbihPreset('Allahu Akbar (33)', [_TasbihStage('Allahu Akbar', 33)]);
const _astaghfirullah100 =
    _TasbihPreset('Astaghfirullah (100)', [_TasbihStage('Astaghfirullah', 100)]);
const _tahleel100 = _TasbihPreset(
    'La ilaha illallah (100)', [_TasbihStage('La ilaha illallah', 100)]);
const _subhanAllahiWaBihamdihi100 = _TasbihPreset(
    'SubhanAllahi wa bihamdihi (100)',
    [_TasbihStage('SubhanAllahi wa bihamdihi', 100)]);
const _ninetyNinePreset = _TasbihPreset('99', [_TasbihStage('Dhikr', 99)]);

/// Full-screen tap-anywhere Tasbih counter (M15.3, enhanced in Item 6.9).
class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  _TasbihPreset? _preset;
  int _stageIndex = 0;
  int _stageCount = 0;
  bool _recorded = false;

  int get _totalCompleted {
    if (_preset == null) return 0;
    final priorStages = _preset!.stages
        .take(_stageIndex)
        .fold<int>(0, (sum, s) => sum + s.count);
    return priorStages + _stageCount;
  }

  void _selectPreset(_TasbihPreset preset) {
    setState(() {
      _preset = preset;
      _stageIndex = 0;
      _stageCount = 0;
      _recorded = false;
    });
  }

  void _selectCustom(String dhikr, int target) {
    final label = dhikr.trim().isEmpty ? 'Custom ($target)' : '$dhikr ($target)';
    final stageLabel = dhikr.trim().isEmpty ? 'Dhikr' : dhikr.trim();
    _selectPreset(_TasbihPreset(label, [_TasbihStage(stageLabel, target)]));
  }

  void _reset() {
    setState(() {
      _preset = null;
      _stageIndex = 0;
      _stageCount = 0;
      _recorded = false;
    });
  }

  void _onTap() {
    final preset = _preset;
    if (preset == null) return;
    final stage = preset.stages[_stageIndex];
    if (_stageCount >= stage.count) return;

    Haptics.tick();
    setState(() {
      _stageCount++;
      if (_stageCount >= stage.count &&
          _stageIndex < preset.stages.length - 1) {
        Haptics.impact();
        _stageIndex++;
        _stageCount = 0;
      }
    });

    if (_totalCompleted >= preset.total && !_recorded) {
      _recorded = true;
      Haptics.success();
      recordTasbihSession(
        ref.read(appDatabaseProvider),
        presetLabel: preset.label,
        targetCount: preset.total,
        completedCount: preset.total,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).tasbihTitle)),
      body: _preset == null
          ? _PresetPicker(
              onSelect: _selectPreset,
              onCustom: _selectCustom,
            )
          : _CounterView(
              preset: _preset!,
              stageIndex: _stageIndex,
              stageCount: _stageCount,
              totalCompleted: _totalCompleted,
              onTap: _onTap,
              onReset: _reset,
            ),
    );
  }
}

class _PresetPicker extends ConsumerWidget {
  const _PresetPicker({required this.onSelect, required this.onCustom});

  final ValueChanged<_TasbihPreset> onSelect;
  final void Function(String dhikr, int target) onCustom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(tasbihSessionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(AppLocalizations.of(context).tasbihMultiStage,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_classicPreset),
          child: const Text(
              '33 - 33 - 34 (SubhanAllah, Alhamdulillah, Allahu Akbar)'),
        ),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_hundredPreset),
          child: const Text('100'),
        ),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_ninetyNinePreset),
          child: const Text('99'),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).tasbihIndividualPresets,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_subhanAllah33),
          child: const Text('SubhanAllah (33)'),
        ),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_alhamdulillah33),
          child: const Text('Alhamdulillah (33)'),
        ),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_allahuAkbar33),
          child: const Text('Allahu Akbar (33)'),
        ),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_astaghfirullah100),
          child: const Text('Astaghfirullah (100)'),
        ),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_tahleel100),
          child: const Text('La ilaha illallah (100)'),
        ),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => onSelect(_subhanAllahiWaBihamdihi100),
          child: const Text('SubhanAllahi wa bihamdihi (100)'),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 8),
        GlassCard(
          enableBlur: false,
          onTap: () => _showCustomDialog(context, onCustom),
          child: const Text('Custom'),
        ),
        const SizedBox(height: 24),
        Text('Recent sessions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text(AppLocalizations.of(context).commonFailedToLoad('$e')),
          data: (sessions) => sessions.isEmpty
              ? const Text('No sessions yet')
              : Column(
                  children: [
                    for (final session in sessions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: GlassCard(
                          enableBlur: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(session.presetLabel),
                              Text('${session.completedCount}'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  void _showCustomDialog(
      BuildContext context, void Function(String dhikr, int target) onCustom) {
    final nameController = TextEditingController();
    final countController = TextEditingController(text: '100');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Dhikr & Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Dhikr (e.g. Salawat, SubhanAllah)',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Count'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final target = int.tryParse(countController.text);
              Navigator.of(context).pop();
              if (target != null && target > 0) {
                onCustom(nameController.text, target);
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _CounterView extends StatelessWidget {
  const _CounterView({
    required this.preset,
    required this.stageIndex,
    required this.stageCount,
    required this.totalCompleted,
    required this.onTap,
    required this.onReset,
  });

  final _TasbihPreset preset;
  final int stageIndex;
  final int stageCount;
  final int totalCompleted;
  final VoidCallback onTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final stage = preset.stages[stageIndex];
    final finished = totalCompleted >= preset.total;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: finished ? null : onTap,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stage.label,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GlassProgressRing(
              progress: stageCount / stage.count,
              size: 200,
              strokeWidth: 12,
              center: Text(
                '$stageCount / ${stage.count}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              finished
                  ? AppLocalizations.of(context)
                      .tasbihComplete(totalCompleted, preset.total)
                  : AppLocalizations.of(context).tasbihTapAnywhere,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextButton(
                onPressed: onReset,
                child: Text(AppLocalizations.of(context).tasbihChooseAnother)),
          ],
        ),
      ),
    );
  }
}
