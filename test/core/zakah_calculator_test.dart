import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/zakah/zakah_calculator.dart';

void main() {
  group('nisabValueFor', () {
    test('silver basis uses 595g at the silver price', () {
      const inputs = ZakahInputs(
        goldPricePerGram: 80,
        silverPricePerGram: 1,
      );
      expect(nisabValueFor(inputs), 595);
    });

    test('gold basis uses 85g at the gold price', () {
      const inputs = ZakahInputs(
        goldPricePerGram: 80,
        silverPricePerGram: 1,
        nisabBasis: NisabBasis.gold,
      );
      expect(nisabValueFor(inputs), 85 * 80);
    });
  });

  group('calculateZakah', () {
    test('below nisab: no zakah due even with some wealth', () {
      const inputs = ZakahInputs(
        cash: 100,
        goldPricePerGram: 80,
        silverPricePerGram: 1,
      );
      final result = calculateZakah(inputs);

      expect(result.totalAssets, 100);
      expect(result.netWealth, 100);
      expect(result.nisabValue, 595);
      expect(result.meetsNisab, false);
      expect(result.zakahDue, 0);
    });

    test('exactly at nisab: zakah is due (>=, not >)', () {
      const inputs = ZakahInputs(
        cash: 595,
        goldPricePerGram: 80,
        silverPricePerGram: 1,
      );
      final result = calculateZakah(inputs);

      expect(result.meetsNisab, true);
      expect(result.zakahDue, closeTo(595 * 0.025, 1e-9));
    });

    test('above nisab: 2.5% of net wealth after liabilities', () {
      const inputs = ZakahInputs(
        cash: 5000,
        goldGrams: 10,
        silverGrams: 50,
        businessInventoryValue: 2000,
        receivables: 1000,
        dueLiabilities: 3000,
        goldPricePerGram: 80,
        silverPricePerGram: 1,
      );
      final result = calculateZakah(inputs);

      // totalAssets = 5000 + 10*80 + 50*1 + 2000 + 1000 = 8850
      expect(result.totalAssets, 8850);
      // netWealth = 8850 - 3000 = 5850
      expect(result.netWealth, 5850);
      expect(result.meetsNisab, true);
      expect(result.zakahDue, closeTo(5850 * 0.025, 1e-9));
    });

    test('liabilities can push net wealth negative — no zakah due', () {
      const inputs = ZakahInputs(
        cash: 100,
        dueLiabilities: 10000,
        goldPricePerGram: 80,
        silverPricePerGram: 1,
      );
      final result = calculateZakah(inputs);

      expect(result.netWealth, lessThan(0));
      expect(result.meetsNisab, false);
      expect(result.zakahDue, 0);
    });

    test('gold-basis nisab changes whether the same wealth qualifies', () {
      // 700 in cash: above the 595 silver nisab, below an 85*80=6800 gold nisab.
      final silverBasis = calculateZakah(const ZakahInputs(
        cash: 700,
        goldPricePerGram: 80,
        silverPricePerGram: 1,
      ));
      final goldBasis = calculateZakah(const ZakahInputs(
        cash: 700,
        goldPricePerGram: 80,
        silverPricePerGram: 1,
        nisabBasis: NisabBasis.gold,
      ));

      expect(silverBasis.meetsNisab, true);
      expect(goldBasis.meetsNisab, false);
    });

    test('investments value is included at 2.5%', () {
      final result = calculateZakah(const ZakahInputs(
        cash: 1000,
        investmentsValue: 4000,
        goldPricePerGram: 80,
        silverPricePerGram: 1,
      ));
      expect(result.totalAssets, 5000);
      expect(result.zakahDue, closeTo(5000 * 0.025, 1e-9));
    });
  });

  group('agriculture (ushr)', () {
    test('below the ~653kg nisab: nothing due', () {
      final r = calculateAgricultureZakah(
        harvestKg: 500,
        irrigation: IrrigationKind.natural,
      );
      expect(r.meetsNisab, false);
      expect(r.zakahDueKg, 0);
    });

    test('natural irrigation is 10%', () {
      final r = calculateAgricultureZakah(
        harvestKg: 1000,
        irrigation: IrrigationKind.natural,
      );
      expect(r.meetsNisab, true);
      expect(r.rate, 0.10);
      expect(r.zakahDueKg, closeTo(100, 1e-9));
    });

    test('artificial irrigation is 5%', () {
      final r = calculateAgricultureZakah(
        harvestKg: 1000,
        irrigation: IrrigationKind.irrigated,
      );
      expect(r.rate, 0.05);
      expect(r.zakahDueKg, closeTo(50, 1e-9));
    });
  });

  group('livestock — sheep/goats', () {
    LivestockResult sheep(int n) =>
        calculateLivestockZakah(kind: LivestockKind.sheep, count: n);

    test('below 40: nothing due', () {
      expect(sheep(39).meetsNisab, false);
      expect(sheep(39).due, isEmpty);
    });
    test('40..120 → 1 sheep', () {
      expect(sheep(40).due.single.count, 1);
      expect(sheep(120).due.single.count, 1);
    });
    test('121..200 → 2, 201..300 → 3', () {
      expect(sheep(121).due.single.count, 2);
      expect(sheep(300).due.single.count, 3);
    });
    test('above 300 → one per additional hundred', () {
      expect(sheep(400).due.single.count, 4);
      expect(sheep(500).due.single.count, 5);
    });
  });

  group('livestock — cattle', () {
    List<LivestockDue> cattle(int n) =>
        calculateLivestockZakah(kind: LivestockKind.cattle, count: n).due;
    int total(int n) => cattle(n).fold(0, (s, d) => s + d.count);

    test('below 30: nothing', () => expect(cattle(29), isEmpty));
    test('30 → 1 tabi', () => expect(cattle(30).single.count, 1));
    test('40 → 1 musinnah', () => expect(cattle(40).single.count, 1));
    test('60 → 2 (two tabi)', () => expect(total(60), 2));
    test('70 → tabi + musinnah', () => expect(total(70), 2));
    test('80 → 2 musinnah', () => expect(total(80), 2));
    test('90 → 3 tabi', () => expect(total(90), 3));
  });

  group('livestock — camels', () {
    List<LivestockDue> camel(int n) =>
        calculateLivestockZakah(kind: LivestockKind.camel, count: n).due;

    test('below 5: nothing', () => expect(camel(4), isEmpty));
    test('5..9 → 1 sheep', () => expect(camel(5).single.count, 1));
    test('20..24 → 4 sheep', () => expect(camel(24).single.count, 4));
    test('25 → bint makhad', () {
      expect(camel(25).single.animal, contains('bint makhad'));
    });
    test('46..60 → hiqqah', () {
      expect(camel(46).single.animal, contains('hiqqah'));
    });
    test('121 → 3 bint labun', () {
      expect(camel(121).single.count, 3);
      expect(camel(121).single.animal, contains('bint labun'));
    });
  });

  group('rikaz', () {
    test('flat 20%, no nisab', () {
      expect(calculateRikazZakah(1000), closeTo(200, 1e-9));
      expect(calculateRikazZakah(10), closeTo(2, 1e-9));
    });
    test('zero/negative → 0', () {
      expect(calculateRikazZakah(0), 0);
      expect(calculateRikazZakah(-5), 0);
    });
  });
}
