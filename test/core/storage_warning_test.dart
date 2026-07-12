import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/platform/storage_estimate.dart';
import 'package:wird/core/platform/storage_warning.dart';

void main() {
  test('estimateStorage/requestPersistentStorage are no-ops off web', () async {
    expect(await estimateStorage(), isNull);
    expect(await requestPersistentStorage(), isFalse);
  });

  testWidgets(
      'confirmStorageBudget always resolves true on native regardless of size',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
      home: Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox();
      }),
    ));

    expect(
      await confirmStorageBudget(capturedContext, estimatedMb: 50),
      isTrue,
    );
  });
}
