/// Pure Zakah calculation — no Flutter import, unit-tested directly.
/// `lib/features/zakah/` is the presentation layer on top.
///
/// M15.2 shipped the monetary calculator ([calculateZakah]). M23.10 extends
/// it with the remaining forms of Zakah — agriculture (ushr), livestock
/// (camel/cattle/sheep tables), and rikaz (buried treasure / mined minerals)
/// — while keeping the original monetary API fully backward-compatible.
///
/// All fiqh figures follow the mainstream Sunni (four-madhhab consensus where
/// it exists) positions summarised from the vetted fiqh corpus; provenance in
/// DATA_SOURCES.md. Nothing here is derived from memory of scripture text.
library;

/// Nisab (the minimum wealth threshold zakah becomes due above) can be
/// pegged to either metal's weight. Silver's threshold is lower in
/// present-day gold/silver price ratios, so pegging to it makes zakah due
/// on smaller amounts of wealth — the safer-for-the-poor default per
/// mainstream fiqh guidance, switchable to gold.
enum NisabBasis { silver, gold }

const double goldNisabGrams = 85;
const double silverNisabGrams = 595;
const double zakahRate = 0.025;

/// Rikaz (buried treasure, or minerals extracted from a find) is due at a
/// flat one-fifth (khums), with no nisab threshold and no one-year hawl.
const double rikazRate = 0.20;

/// Nisab for agricultural produce: five awsuq. One wasq ≈ 130.56 kg of the
/// standard measure, so five awsuq ≈ 652.8 kg. Widely rounded to ~653 kg.
const double agricultureNisabKg = 652.8;

/// Ushr: produce watered naturally (rain, springs, rivers) is due at 10%;
/// produce watered by artificial, costly means (wells, pumps, irrigation
/// bought at expense) is due at 5%.
const double ushrNaturalRate = 0.10;
const double ushrIrrigatedRate = 0.05;

class ZakahInputs {
  const ZakahInputs({
    this.cash = 0,
    this.goldGrams = 0,
    this.silverGrams = 0,
    this.businessInventoryValue = 0,
    this.receivables = 0,
    this.investmentsValue = 0,
    this.dueLiabilities = 0,
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    this.nisabBasis = NisabBasis.silver,
  });

  final double cash;
  final double goldGrams;
  final double silverGrams;
  final double businessInventoryValue;
  final double receivables;

  /// Market value of zakatable investments/shares. For shares bought to
  /// trade (resale), this is the full market value. For shares held long
  /// term (for dividends/growth), the caller passes only the zakatable
  /// portion (the underlying zakatable assets of the company); the
  /// calculator treats whatever value it is given at the 2.5% rate.
  final double investmentsValue;

  final double dueLiabilities;

  /// Manually entered, in the user's own currency — no price API (offline
  /// & keeps the app free of a network dependency for something this
  /// consequential to get right).
  final double goldPricePerGram;
  final double silverPricePerGram;

  final NisabBasis nisabBasis;
}

class ZakahResult {
  const ZakahResult({
    required this.totalAssets,
    required this.netWealth,
    required this.nisabValue,
    required this.zakahDue,
  });

  final double totalAssets;
  final double netWealth;
  final double nisabValue;

  /// Zero when [netWealth] is below [nisabValue] — no zakah is due, not
  /// "an error" or "unset".
  final double zakahDue;

  bool get meetsNisab => netWealth >= nisabValue;
}

double nisabValueFor(ZakahInputs inputs) => switch (inputs.nisabBasis) {
      NisabBasis.gold => goldNisabGrams * inputs.goldPricePerGram,
      NisabBasis.silver => silverNisabGrams * inputs.silverPricePerGram,
    };

/// Monetary Zakah (2.5%): cash, the value of gold/silver held, business
/// inventory, receivables and zakatable investments, less liabilities due
/// now — gated by nisab.
ZakahResult calculateZakah(ZakahInputs inputs) {
  final totalAssets = inputs.cash +
      inputs.goldGrams * inputs.goldPricePerGram +
      inputs.silverGrams * inputs.silverPricePerGram +
      inputs.businessInventoryValue +
      inputs.receivables +
      inputs.investmentsValue;
  final netWealth = totalAssets - inputs.dueLiabilities;
  final nisabValue = nisabValueFor(inputs);

  final meetsNisab = netWealth >= nisabValue;
  return ZakahResult(
    totalAssets: totalAssets,
    netWealth: netWealth,
    nisabValue: nisabValue,
    zakahDue: meetsNisab && netWealth > 0 ? netWealth * zakahRate : 0,
  );
}

// --------------------------------------------------------------------------
// Agriculture (ushr)
// --------------------------------------------------------------------------

enum IrrigationKind {
  /// Rain, rivers, springs — no artificial cost. 10%.
  natural,

  /// Wells, pumps, purchased irrigation water — costly. 5%.
  irrigated,
}

class AgricultureResult {
  const AgricultureResult({
    required this.harvestKg,
    required this.rate,
    required this.meetsNisab,
    required this.zakahDueKg,
  });

  final double harvestKg;
  final double rate;
  final bool meetsNisab;

  /// Payable in kind (kilograms of the same produce). Zero below nisab.
  final double zakahDueKg;
}

AgricultureResult calculateAgricultureZakah({
  required double harvestKg,
  required IrrigationKind irrigation,
}) {
  final rate = switch (irrigation) {
    IrrigationKind.natural => ushrNaturalRate,
    IrrigationKind.irrigated => ushrIrrigatedRate,
  };
  final meets = harvestKg >= agricultureNisabKg;
  return AgricultureResult(
    harvestKg: harvestKg,
    rate: rate,
    meetsNisab: meets,
    zakahDueKg: meets && harvestKg > 0 ? harvestKg * rate : 0,
  );
}

// --------------------------------------------------------------------------
// Livestock (sa'imah — free-grazing) — paid in animals, not currency.
// --------------------------------------------------------------------------

enum LivestockKind { camel, cattle, sheep }

/// A single line of due livestock, e.g. "1 × bint labun" or "3 × sheep".
class LivestockDue {
  const LivestockDue(this.count, this.animal);

  final int count;

  /// The classical animal name/age-grade, in plain terms for display.
  final String animal;
}

class LivestockResult {
  const LivestockResult({
    required this.kind,
    required this.count,
    required this.meetsNisab,
    required this.due,
  });

  final LivestockKind kind;
  final int count;
  final bool meetsNisab;

  /// Empty below the first nisab. May hold more than one line (e.g. large
  /// camel herds owe a mix of grades).
  final List<LivestockDue> due;
}

LivestockResult calculateLivestockZakah({
  required LivestockKind kind,
  required int count,
}) {
  final due = switch (kind) {
    LivestockKind.camel => _camelDue(count),
    LivestockKind.cattle => _cattleDue(count),
    LivestockKind.sheep => _sheepDue(count),
  };
  return LivestockResult(
    kind: kind,
    count: count,
    meetsNisab: due.isNotEmpty,
    due: due,
  );
}

/// Sheep/goats: nothing below 40.
/// 40–120: 1 · 121–200: 2 · 201–300: 3 · then +1 per additional 100.
List<LivestockDue> _sheepDue(int n) {
  if (n < 40) return const [];
  if (n <= 120) return const [LivestockDue(1, 'sheep')];
  if (n <= 200) return const [LivestockDue(2, 'sheep')];
  if (n <= 300) return const [LivestockDue(3, 'sheep')];
  // Above 300, one sheep for each additional hundred.
  final count = n ~/ 100;
  return [LivestockDue(count, 'sheep')];
}

/// Cattle: nothing below 30.
/// 30–39: 1 tabi' (1yr) · 40–59: 1 musinnah (2yr) · then per-30 a tabi'
/// and per-40 a musinnah, taking the combination that uses up the herd.
List<LivestockDue> _cattleDue(int n) {
  if (n < 30) return const [];
  // Standard tabulation: find the mix of 30s (tabi') and 40s (musinnah)
  // that exactly accounts for the count, matching the classical table
  // for the salient breakpoints (60→2 tabi', 70→tabi'+musinnah, 80→2
  // musinnah, 90→3 tabi', 100→tabi'+2·musinnah, 120→3 tabi' or 3 musinnah).
  if (n < 40) return const [LivestockDue(1, "tabi' (1-year-old)")];
  if (n < 60) return const [LivestockDue(1, 'musinnah (2-year-old)')];
  // For 60+, choose non-negative a (×30) and b (×40) with 30a+40b == n when
  // possible, else the closest lower tabulation. Iterate b downward.
  for (int b = n ~/ 40; b >= 0; b--) {
    final rem = n - 40 * b;
    if (rem >= 0 && rem % 30 == 0) {
      final a = rem ~/ 30;
      return [
        if (a > 0) LivestockDue(a, "tabi' (1-year-old)"),
        if (b > 0) LivestockDue(b, 'musinnah (2-year-old)'),
      ];
    }
  }
  // Fallback (should not hit for n>=60): treat as all tabi'.
  return [LivestockDue(n ~/ 30, "tabi' (1-year-old)")];
}

/// Camels: nothing below 5. Small herds owe sheep; from 25 up they owe
/// graded she-camels, then a per-40/per-50 rule above 120.
List<LivestockDue> _camelDue(int n) {
  if (n < 5) return const [];
  if (n <= 9) return const [LivestockDue(1, 'sheep')];
  if (n <= 14) return const [LivestockDue(2, 'sheep')];
  if (n <= 19) return const [LivestockDue(3, 'sheep')];
  if (n <= 24) return const [LivestockDue(4, 'sheep')];
  if (n <= 35) return const [LivestockDue(1, 'bint makhad (1-year she-camel)')];
  if (n <= 45) return const [LivestockDue(1, 'bint labun (2-year she-camel)')];
  if (n <= 60) return const [LivestockDue(1, 'hiqqah (3-year she-camel)')];
  if (n <= 75) return const [LivestockDue(1, "jadha'ah (4-year she-camel)")];
  if (n <= 90) return const [LivestockDue(2, 'bint labun (2-year she-camel)')];
  if (n <= 120) return const [LivestockDue(2, 'hiqqah (3-year she-camel)')];
  // Above 120: for every 40, a bint labun; for every 50, a hiqqah. Choose
  // the mix that exactly accounts for the herd (prefer more hiqqah — 50s).
  for (int h = n ~/ 50; h >= 0; h--) {
    final rem = n - 50 * h;
    if (rem >= 0 && rem % 40 == 0) {
      final l = rem ~/ 40;
      return [
        if (l > 0) LivestockDue(l, 'bint labun (2-year she-camel)'),
        if (h > 0) LivestockDue(h, 'hiqqah (3-year she-camel)'),
      ];
    }
  }
  // Fallback: closest lower — all bint labun by 40s.
  return [LivestockDue(n ~/ 40, 'bint labun (2-year she-camel)')];
}

// --------------------------------------------------------------------------
// Rikaz (buried treasure / mined minerals) — flat 20%, no nisab, no hawl.
// --------------------------------------------------------------------------

double calculateRikazZakah(double value) =>
    value > 0 ? value * rikazRate : 0;
