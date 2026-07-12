import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/hadith_pack_repository.dart';
import 'package:wird/features/onboarding/onboarding_screen.dart';

void main() {
  test('every downloadable collection has a size estimate', () {
    expect(
      hadithCollectionSizeMb.keys.toSet(),
      hadithCollections.keys.toSet(),
    );
  });

  test('SelectedHadithCollectionsNotifier toggles membership', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(selectedHadithCollectionsProvider.notifier);

    expect(container.read(selectedHadithCollectionsProvider), isEmpty);

    notifier.toggle('bukhari');
    expect(container.read(selectedHadithCollectionsProvider), {'bukhari'});

    notifier.toggle('muslim');
    expect(
      container.read(selectedHadithCollectionsProvider),
      {'bukhari', 'muslim'},
    );

    notifier.toggle('bukhari');
    expect(container.read(selectedHadithCollectionsProvider), {'muslim'});
  });
}
