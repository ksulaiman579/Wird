import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/features/quran_reader/reading_streak.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, ReadingStreakNotifier)> setUp() async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    await container.read(readingStreakProvider.future);
    return (container, container.read(readingStreakProvider.notifier));
  }

  test('first read starts the streak at 1', () async {
    final (container, notifier) = await setUp();
    addTearDown(container.dispose);
    await notifier.recordReadToday(DateTime(2026, 1, 1));
    expect(container.read(readingStreakProvider).value!.currentStreak, 1);
  });

  test('reading again the same day is a no-op', () async {
    final (container, notifier) = await setUp();
    addTearDown(container.dispose);
    await notifier.recordReadToday(DateTime(2026, 1, 1));
    await notifier.recordReadToday(DateTime(2026, 1, 1));
    expect(container.read(readingStreakProvider).value!.currentStreak, 1);
  });

  test('consecutive days increment the streak', () async {
    final (container, notifier) = await setUp();
    addTearDown(container.dispose);
    await notifier.recordReadToday(DateTime(2026, 1, 1));
    await notifier.recordReadToday(DateTime(2026, 1, 2));
    await notifier.recordReadToday(DateTime(2026, 1, 3));
    expect(container.read(readingStreakProvider).value!.currentStreak, 3);
  });

  test('a multi-day gap resets the streak to 1', () async {
    final (container, notifier) = await setUp();
    addTearDown(container.dispose);
    await notifier.recordReadToday(DateTime(2026, 1, 1));
    await notifier.recordReadToday(DateTime(2026, 1, 2));
    await notifier.recordReadToday(DateTime(2026, 1, 6)); // 4-day gap
    expect(container.read(readingStreakProvider).value!.currentStreak, 1);
  });

  test('streak persists across a fresh provider (SharedPreferences)', () async {
    final (container, notifier) = await setUp();
    addTearDown(container.dispose);
    await notifier.recordReadToday(DateTime(2026, 1, 1));
    await notifier.recordReadToday(DateTime(2026, 1, 2));
    // A new container reads the same mock store.
    final container2 = ProviderContainer();
    addTearDown(container2.dispose);
    final state = await container2.read(readingStreakProvider.future);
    expect(state.currentStreak, 2);
    expect(state.longestStreak, 2);
  });
}
