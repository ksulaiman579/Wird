import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/calendar_math.dart';
import '../../core/content/quran_repository.dart';
import '../../core/khatmah/khatmah_plan.dart';
import '../../core/l10n/dates.dart';
import '../../core/l10n/format.dart';
import '../../shared/glass/glass.dart';
import '../../shared/share/share_card.dart';

/// The saved plan: start date + number of days, plus days ticked off.
class KhatmahState {
  const KhatmahState({this.start, this.days, this.done = const {}});
  final DateTime? start;
  final int? days;
  final Set<int> done;

  bool get active => start != null && days != null;
}

class KhatmahNotifier extends AsyncNotifier<KhatmahState> {
  static const _startKey = 'khatmah_start';
  static const _daysKey = 'khatmah_days';
  static const _doneKey = 'khatmah_done';

  @override
  Future<KhatmahState> build() async {
    final p = await SharedPreferences.getInstance();
    final parsed =
        parseKhatmahQuery(p.getString(_startKey), '${p.getInt(_daysKey)}');
    if (parsed == null) return const KhatmahState();
    return KhatmahState(
      start: parsed.$1,
      days: parsed.$2,
      done: {
        for (final d in p.getStringList(_doneKey) ?? const <String>[])
          if (int.tryParse(d) != null) int.parse(d),
      },
    );
  }

  Future<void> startPlan(DateTime start, int days) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_startKey, dayKeyFor(start));
    await p.setInt(_daysKey, days);
    await p.remove(_doneKey);
    state = AsyncData(KhatmahState(start: dateOnly(start), days: days));
  }

  Future<void> toggleDay(int day) async {
    final cur = state.value ?? const KhatmahState();
    final done = {...cur.done};
    if (!done.remove(day)) done.add(day);
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_doneKey, [for (final d in done) '$d']);
    state = AsyncData(KhatmahState(start: cur.start, days: cur.days, done: done));
  }

  Future<void> stop() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_startKey);
    await p.remove(_daysKey);
    await p.remove(_doneKey);
    state = const AsyncData(KhatmahState());
  }
}

final khatmahProvider =
    AsyncNotifierProvider<KhatmahNotifier, KhatmahState>(KhatmahNotifier.new);

/// Every ayah in order with its word count (loaded once).
final _weightedAyahsProvider =
    FutureProvider<List<(AyahRef, int)>>((ref) async {
  final repo = ref.read(quranRepositoryProvider);
  final out = <(AyahRef, int)>[];
  for (var s = 1; s <= 114; s++) {
    final surah = await repo.loadSurah(s);
    for (final a in surah.ayahs) {
      out.add((AyahRef(s, a.ayah), a.wordCount < 1 ? 1 : a.wordCount));
    }
  }
  return out;
});

/// The plan's daily portions (empty when no plan).
final khatmahPortionsProvider =
    FutureProvider<List<KhatmahPortion>>((ref) async {
  final plan = await ref.watch(khatmahProvider.future);
  if (!plan.active) return const [];
  final ayahs = await ref.watch(_weightedAyahsProvider.future);
  return splitKhatmah(ayahs, plan.days!);
});

class KhatmahScreen extends ConsumerStatefulWidget {
  const KhatmahScreen({super.key, this.linkStart, this.linkDays});

  /// From a shared link (`/khatmah?start=...&days=...`).
  final String? linkStart;
  final String? linkDays;

  @override
  ConsumerState<KhatmahScreen> createState() => _KhatmahScreenState();
}

class _KhatmahScreenState extends ConsumerState<KhatmahScreen> {
  int _days = 30;
  bool _offeredJoin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferJoin());
  }

  Future<void> _maybeOfferJoin() async {
    final link = parseKhatmahQuery(widget.linkStart, widget.linkDays);
    if (link == null || _offeredJoin || !mounted) return;
    _offeredJoin = true;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.khatmahJoinTitle),
        content: Text(l.khatmahJoinBody(
            link.$2, formatDateLocalized(context, link.$1))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.khatmahJoin),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(khatmahProvider.notifier).startPlan(link.$1, link.$2);
    }
  }

  Future<void> _pickDate() async {
    final now = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      firstDate: addCalendarDays(now, 1),
      lastDate: addCalendarDays(now, 365),
      initialDate: addCalendarDays(now, _days - 1),
    );
    if (picked != null) {
      setState(() => _days = daysBetweenCalendarDates(now, picked) + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = ref.watch(khatmahProvider).value ?? const KhatmahState();

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(l.khatmahTitle)),
      body: plan.active ? _PlanView(plan: plan) : _setup(context, l),
    );
  }

  Widget _setup(BuildContext context, AppLocalizations l) {
    final now = dateOnly(DateTime.now());
    final end = addCalendarDays(now, _days - 1);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.khatmahDesc, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in const [7, 10, 15, 20, 30, 60])
              ChoiceChip(
                label: Text(l.khatmahDays(d)),
                selected: _days == d,
                onSelected: (_) => setState(() => _days = d),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.event_rounded),
          label: Text(l.khatmahPickDate),
        ),
        const SizedBox(height: 8),
        Text(l.khatmahFinishBy(formatDateLocalized(context, end)),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () =>
              ref.read(khatmahProvider.notifier).startPlan(now, _days),
          child: Text(l.khatmahStart),
        ),
      ],
    );
  }
}

class _PlanView extends ConsumerWidget {
  const _PlanView({required this.plan});
  final KhatmahState plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final portionsAsync = ref.watch(khatmahPortionsProvider);
    final today = khatmahDayFor(plan.start!, plan.days!, DateTime.now());
    final end = addCalendarDays(plan.start!, plan.days! - 1);
    final notStarted = DateTime.now().isBefore(plan.start!);

    return portionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(l.commonFailedToLoad('$e'))),
      data: (portions) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            notStarted
                ? l.khatmahStartsOn(formatDateLocalized(context, plan.start!))
                : today == null
                    ? l.khatmahFinished
                    : l.khatmahDayOf(today, plan.days!),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(l.khatmahFinishBy(formatDateLocalized(context, end))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: Text(l.khatmahShare),
                  onPressed: () => SharePlus.instance.share(ShareParams(
                    text: '${l.khatmahShareText(plan.days!, formatDateLocalized(context, plan.start!))}\n'
                        '${wirdLink('/khatmah?${khatmahQuery(plan.start!, plan.days!)}')}',
                  )),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => ref.read(khatmahProvider.notifier).stop(),
                child: Text(l.khatmahStop),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final p in portions)
            _PortionTile(
              portion: p,
              isToday: p.day == today,
              done: plan.done.contains(p.day),
            ),
        ],
      ),
    );
  }
}

class _PortionTile extends ConsumerWidget {
  const _PortionTile({
    required this.portion,
    required this.isToday,
    required this.done,
  });

  final KhatmahPortion portion;
  final bool isToday;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        enableBlur: false,
        fillColor: isToday ? scheme.secondaryContainer : null,
        onTap: () => context.push(
            '/read?surah=${portion.start.surah}&ayah=${portion.start.ayah}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.khatmahDayN(portion.day),
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(l.khatmahRange(bidiIsolate('${portion.start}'),
                      bidiIsolate('${portion.end}'))),
                ],
              ),
            ),
            IconButton(
              tooltip: l.khatmahMarkDone,
              icon: Icon(
                done ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: done ? scheme.primary : null,
              ),
              onPressed: () =>
                  ref.read(khatmahProvider.notifier).toggleDay(portion.day),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small Today card for an active plan: today's day and range.
class KhatmahTodayCard extends ConsumerWidget {
  const KhatmahTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(khatmahProvider).value;
    if (plan == null || !plan.active) return const SizedBox.shrink();
    final day = khatmahDayFor(plan.start!, plan.days!, DateTime.now());
    if (day == null) return const SizedBox.shrink();
    final portions = ref.watch(khatmahPortionsProvider).value;
    if (portions == null || portions.length < day) {
      return const SizedBox.shrink();
    }
    final p = portions[day - 1];
    final l = AppLocalizations.of(context);
    final done = plan.done.contains(day);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        enableBlur: false,
        onTap: () => context.push('/khatmah'),
        child: Row(
          children: [
            Icon(done ? Icons.check_circle_rounded : Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l.khatmahTitle} · ${l.khatmahDayOf(day, plan.days!)}',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(l.khatmahRange(
                      bidiIsolate('${p.start}'), bidiIsolate('${p.end}'))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
