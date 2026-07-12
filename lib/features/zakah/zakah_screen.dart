import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter/services.dart';

import '../../core/zakah/currencies.dart';
import '../../core/zakah/zakah_calculator.dart';
import '../../core/zakah/zakah_notes.dart';
import '../../core/zakah/zakah_prefs.dart';
import '../../shared/glass/glass.dart';

/// The forms of Zakah a user can turn on. Cash / metals / business /
/// investments all feed one pooled 2.5% monetary calculation; agriculture,
/// livestock and rikaz are computed on their own rules.
enum ZakahCategory {
  monetary('Cash & savings', 'Cash, bank balances, and money owed to you'),
  metals('Gold & silver', 'By weight, valued at your entered price'),
  business('Business assets', 'Trade goods / inventory held for sale'),
  investments('Investments & shares', 'Trading or long-term holdings'),
  agriculture('Agriculture', 'Crops & fruits (ushr, in kind)'),
  livestock('Livestock', 'Free-grazing camels, cattle, sheep/goats'),
  rikaz('Rikaz', 'Buried treasure / windfall find (20%)');

  const ZakahCategory(this.label, this.blurb);
  final String label;
  final String blurb;
}

/// Localized label/blurb for a [ZakahCategory] (the enum's own strings are
/// English fallbacks / identity). Kept as free functions so the const enum
/// stays context-free.
String zakahCategoryLabel(ZakahCategory c, AppLocalizations l) => switch (c) {
      ZakahCategory.monetary => l.zakahCatMonetary,
      ZakahCategory.metals => l.zakahCatMetals,
      ZakahCategory.business => l.zakahCatBusiness,
      ZakahCategory.investments => l.zakahCatInvestments,
      ZakahCategory.agriculture => l.zakahCatAgriculture,
      ZakahCategory.livestock => l.zakahCatLivestock,
      ZakahCategory.rikaz => l.zakahCatRikaz,
    };

String zakahCategoryBlurb(ZakahCategory c, AppLocalizations l) => switch (c) {
      ZakahCategory.monetary => l.zakahCatMonetaryBlurb,
      ZakahCategory.metals => l.zakahCatMetalsBlurb,
      ZakahCategory.business => l.zakahCatBusinessBlurb,
      ZakahCategory.investments => l.zakahCatInvestmentsBlurb,
      ZakahCategory.agriculture => l.zakahCatAgricultureBlurb,
      ZakahCategory.livestock => l.zakahCatLivestockBlurb,
      ZakahCategory.rikaz => l.zakahCatRikazBlurb,
    };

/// M23.10 Zakah calculator: pick the categories that apply, fill each form,
/// and read a combined breakdown. Manual prices only (offline). Last inputs
/// are remembered between visits.
class ZakahScreen extends StatefulWidget {
  const ZakahScreen({super.key});

  @override
  State<ZakahScreen> createState() => _ZakahScreenState();
}

class _ZakahScreenState extends State<ZakahScreen> {
  String _currencyCode = defaultCurrencyCode;
  NisabBasis _nisabBasis = NisabBasis.silver;
  final Set<ZakahCategory> _active = {ZakahCategory.monetary};

  IrrigationKind _irrigation = IrrigationKind.natural;
  LivestockKind _livestockKind = LivestockKind.sheep;

  final _controllers = <String, TextEditingController>{};
  bool _loaded = false;

  static const _fields = [
    'goldPrice', 'silverPrice', // metal prices
    'cash', 'receivables', // monetary
    'goldGrams', 'silverGrams', // metals
    'business', // business
    'investments', // investments
    'liabilities', // deductions
    'harvestKg', // agriculture
    'livestockCount', // livestock
    'rikaz', // rikaz
  ];

  TextEditingController _c(String key) =>
      _controllers.putIfAbsent(key, () => TextEditingController());

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      _c(f).addListener(_persistAndRebuild);
    }
    _restore();
  }

  Future<void> _restore() async {
    final s = await loadZakahState();
    if (!mounted) return;
    setState(() {
      _currencyCode = (s['currency'] as String?) ?? defaultCurrencyCode;
      _nisabBasis = (s['nisabBasis'] == 'gold')
          ? NisabBasis.gold
          : NisabBasis.silver;
      _irrigation = (s['irrigation'] == 'irrigated')
          ? IrrigationKind.irrigated
          : IrrigationKind.natural;
      _livestockKind = LivestockKind.values.firstWhere(
        (k) => k.name == s['livestockKind'],
        orElse: () => LivestockKind.sheep,
      );
      final active = (s['active'] as List?)?.cast<String>() ?? const [];
      if (active.isNotEmpty) {
        _active
          ..clear()
          ..addAll(active.map((n) => ZakahCategory.values
              .firstWhere((c) => c.name == n, orElse: () => ZakahCategory.monetary)));
      }
      final vals = (s['fields'] as Map?)?.cast<String, dynamic>() ?? const {};
      for (final f in _fields) {
        final v = vals[f];
        if (v != null) _c(f).text = v.toString();
      }
      _loaded = true;
    });
  }

  void _persistAndRebuild() {
    setState(() {});
    saveZakahState({
      'currency': _currencyCode,
      'nisabBasis': _nisabBasis.name,
      'irrigation': _irrigation.name,
      'livestockKind': _livestockKind.name,
      'active': _active.map((c) => c.name).toList(),
      'fields': {for (final f in _fields) f: _c(f).text},
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _n(String key) => double.tryParse(_c(key).text) ?? 0;
  int _i(String key) => int.tryParse(_c(key).text) ?? 0;

  Currency get _currency => currencyByCode(_currencyCode);

  ZakahInputs get _monetaryInputs => ZakahInputs(
        cash: _active.contains(ZakahCategory.monetary) ? _n('cash') : 0,
        receivables:
            _active.contains(ZakahCategory.monetary) ? _n('receivables') : 0,
        goldGrams: _active.contains(ZakahCategory.metals) ? _n('goldGrams') : 0,
        silverGrams:
            _active.contains(ZakahCategory.metals) ? _n('silverGrams') : 0,
        businessInventoryValue:
            _active.contains(ZakahCategory.business) ? _n('business') : 0,
        investmentsValue:
            _active.contains(ZakahCategory.investments) ? _n('investments') : 0,
        dueLiabilities: _n('liabilities'),
        goldPricePerGram: _n('goldPrice'),
        silverPricePerGram: _n('silverPrice'),
        nisabBasis: _nisabBasis,
      );

  bool get _needsMetalPrices =>
      _active.contains(ZakahCategory.monetary) ||
      _active.contains(ZakahCategory.metals) ||
      _active.contains(ZakahCategory.business) ||
      _active.contains(ZakahCategory.investments);

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return GlassScaffold(
        appBar: GlassAppBar(title: Text(AppLocalizations.of(context).zakahTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).zakahTitle)),
      body: ListView(
        children: [
          _NoteBox(AppLocalizations.of(context).zakahGeneralNote),
          const SizedBox(height: 12),
          _setupCard(context),
          const SizedBox(height: 12),
          _categoryPickerCard(context),
          const SizedBox(height: 12),
          for (final cat in ZakahCategory.values)
            if (_active.contains(cat)) ...[
              _categorySection(context, cat),
              const SizedBox(height: 12),
            ],
          _SummaryCard(
            currency: _currency,
            monetary:
                _needMonetary ? calculateZakah(_monetaryInputs) : null,
            agriculture: _active.contains(ZakahCategory.agriculture)
                ? calculateAgricultureZakah(
                    harvestKg: _n('harvestKg'), irrigation: _irrigation)
                : null,
            livestock: _active.contains(ZakahCategory.livestock)
                ? calculateLivestockZakah(
                    kind: _livestockKind, count: _i('livestockCount'))
                : null,
            rikaz: _active.contains(ZakahCategory.rikaz)
                ? calculateRikazZakah(_n('rikaz'))
                : null,
          ),
        ],
      ),
    );
  }

  bool get _needMonetary => _active.any((c) =>
      c == ZakahCategory.monetary ||
      c == ZakahCategory.metals ||
      c == ZakahCategory.business ||
      c == ZakahCategory.investments);

  Widget _setupCard(BuildContext context) {
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(AppLocalizations.of(context).zakahSetup),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppLocalizations.of(context).zakahCurrency),
            subtitle: Text('${_currency.code} — ${_currency.name}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickCurrency,
          ),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).zakahNisabBasis),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            GlassPill(
              enableBlur: false,
              selected: _nisabBasis == NisabBasis.silver,
              onTap: () {
                setState(() => _nisabBasis = NisabBasis.silver);
                _persistAndRebuild();
              },
              child: Text(AppLocalizations.of(context).zakahSilverBasis),
            ),
            GlassPill(
              enableBlur: false,
              selected: _nisabBasis == NisabBasis.gold,
              onTap: () {
                setState(() => _nisabBasis = NisabBasis.gold);
                _persistAndRebuild();
              },
              child: Text(AppLocalizations.of(context).zakahGoldBasis),
            ),
          ]),
          if (_needsMetalPrices) ...[
            const SizedBox(height: 12),
            Text(
                AppLocalizations.of(context)
                    .zakahMetalPriceLabel(_currency.code),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _MoneyField(controller: _c('goldPrice'), label: AppLocalizations.of(context).zakahGoldPrice),
            _MoneyField(
                controller: _c('silverPrice'), label: AppLocalizations.of(context).zakahSilverPrice),
          ],
        ],
      ),
    );
  }

  Widget _categoryPickerCard(BuildContext context) {
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(AppLocalizations.of(context).zakahWhichApply),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cat in ZakahCategory.values)
                GlassPill(
                  enableBlur: false,
                  selected: _active.contains(cat),
                  onTap: () {
                    setState(() {
                      if (!_active.remove(cat)) _active.add(cat);
                    });
                    _persistAndRebuild();
                  },
                  child: Text(zakahCategoryLabel(cat, AppLocalizations.of(context))),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categorySection(BuildContext context, ZakahCategory cat) {
    final children = <Widget>[];
    switch (cat) {
      case ZakahCategory.monetary:
        children.addAll([
          const _NoteBox(monetaryNote),
          _MoneyField(controller: _c('cash'), label: AppLocalizations.of(context).zakahCatMonetary),
          _MoneyField(
              controller: _c('receivables'),
              label: AppLocalizations.of(context).zakahReceivables),
          _MoneyField(
              controller: _c('liabilities'), label: AppLocalizations.of(context).zakahDebtsDue),
        ]);
      case ZakahCategory.metals:
        children.addAll([
          const _NoteBox(metalsNote),
          _MoneyField(controller: _c('goldGrams'), label: AppLocalizations.of(context).zakahGoldGrams),
          _MoneyField(
              controller: _c('silverGrams'), label: AppLocalizations.of(context).zakahSilverGrams),
        ]);
      case ZakahCategory.business:
        children.addAll([
          const _NoteBox(businessNote),
          _MoneyField(
              controller: _c('business'), label: AppLocalizations.of(context).zakahTradeGoods),
        ]);
      case ZakahCategory.investments:
        children.addAll([
          const _NoteBox(investmentsNote),
          _MoneyField(
              controller: _c('investments'),
              label: AppLocalizations.of(context).zakahInvestmentValue),
        ]);
      case ZakahCategory.agriculture:
        children.addAll([
          const _NoteBox(agricultureNote),
          Wrap(spacing: 8, children: [
            GlassPill(
              enableBlur: false,
              selected: _irrigation == IrrigationKind.natural,
              onTap: () {
                setState(() => _irrigation = IrrigationKind.natural);
                _persistAndRebuild();
              },
              child: Text(AppLocalizations.of(context).zakahRainFed),
            ),
            GlassPill(
              enableBlur: false,
              selected: _irrigation == IrrigationKind.irrigated,
              onTap: () {
                setState(() => _irrigation = IrrigationKind.irrigated);
                _persistAndRebuild();
              },
              child: Text(AppLocalizations.of(context).zakahIrrigated),
            ),
          ]),
          const SizedBox(height: 12),
          _MoneyField(
              controller: _c('harvestKg'), label: AppLocalizations.of(context).zakahHarvestWeight),
        ]);
      case ZakahCategory.livestock:
        children.addAll([
          const _NoteBox(livestockNote),
          Wrap(spacing: 8, children: [
            for (final k in LivestockKind.values)
              GlassPill(
                enableBlur: false,
                selected: _livestockKind == k,
                onTap: () {
                  setState(() => _livestockKind = k);
                  _persistAndRebuild();
                },
                child: Text(_livestockLabel(k)),
              ),
          ]),
          const SizedBox(height: 12),
          _MoneyField(
              controller: _c('livestockCount'),
              label: AppLocalizations.of(context).zakahNumberAnimals,
              integer: true),
        ]);
      case ZakahCategory.rikaz:
        children.addAll([
          const _NoteBox(rikazNote),
          _MoneyField(controller: _c('rikaz'), label: AppLocalizations.of(context).zakahFindValue),
        ]);
    }
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(zakahCategoryLabel(cat, AppLocalizations.of(context))),
          ...children,
        ],
      ),
    );
  }

  String _livestockLabel(LivestockKind k) => switch (k) {
        LivestockKind.camel => AppLocalizations.of(context).zakahCamels,
        LivestockKind.cattle => AppLocalizations.of(context).zakahCattle,
        LivestockKind.sheep => AppLocalizations.of(context).zakahSheepGoats,
      };

  Future<void> _pickCurrency() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          builder: (context, scrollController) => ListView.builder(
            controller: scrollController,
            itemCount: currencies.length,
            itemBuilder: (context, i) {
              final cur = currencies[i];
              return ListTile(
                leading: SizedBox(
                    width: 40,
                    child: Text(cur.symbol,
                        style: Theme.of(context).textTheme.titleMedium)),
                title: Text('${cur.code} — ${cur.name}'),
                selected: cur.code == _currencyCode,
                onTap: () => Navigator.pop(context, cur.code),
              );
            },
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _currencyCode = picked);
      _persistAndRebuild();
    }
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.label,
    this.integer = false,
  });

  final TextEditingController controller;
  final String label;
  final bool integer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType:
            TextInputType.numberWithOptions(decimal: !integer),
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              integer ? RegExp(r'^\d*') : RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.currency,
    this.monetary,
    this.agriculture,
    this.livestock,
    this.rikaz,
  });

  final Currency currency;
  final ZakahResult? monetary;
  final AgricultureResult? agriculture;
  final LivestockResult? livestock;
  final double? rikaz;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = <Widget>[];

    if (monetary != null) {
      final m = monetary!;
      rows.add(_row(AppLocalizations.of(context).zakahZakatableWealth, currency.format(m.netWealth)));
      rows.add(_row(AppLocalizations.of(context).zakahNisabThreshold, currency.format(m.nisabValue)));
      rows.add(_row(
        m.meetsNisab ? AppLocalizations.of(context).zakahMonetaryDue : AppLocalizations.of(context).zakahBelowNisabNothing,
        currency.format(m.zakahDue),
        emphasise: true,
      ));
    }
    if (agriculture != null) {
      final a = agriculture!;
      rows.add(_row(
        a.meetsNisab
            ? 'Agriculture (${(a.rate * 100).toStringAsFixed(0)}%)'
            : AppLocalizations.of(context).zakahAgricultureBelowNisab,
        '${a.zakahDueKg.toStringAsFixed(1)} kg',
        emphasise: true,
      ));
    }
    if (livestock != null) {
      final l = livestock!;
      if (!l.meetsNisab) {
        rows.add(_row(AppLocalizations.of(context).zakahLivestock,
            AppLocalizations.of(context).zakahBelowNisab));
      } else {
        for (final d in l.due) {
          rows.add(_row(AppLocalizations.of(context).zakahLivestockDue, '${d.count} × ${d.animal}',
              emphasise: true));
        }
      }
    }
    if (rikaz != null) {
      rows.add(_row(AppLocalizations.of(context).zakahRikazDue, currency.format(rikaz!), emphasise: true));
    }

    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(AppLocalizations.of(context).zakahSelectCategories)
          else
            ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasise = false}) {
    return Builder(builder: (context) {
      final style = emphasise
          ? Theme.of(context).textTheme.titleMedium
          : Theme.of(context).textTheme.bodyMedium;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: style)),
            const SizedBox(width: 12),
            Text(value, style: style),
          ],
        ),
      );
    });
  }
}
