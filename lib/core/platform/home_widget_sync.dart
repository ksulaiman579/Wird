import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Pushes Today's numbers to the Android home-screen widget
/// (WirdWidgetProvider). Skips unchanged values so it's cheap to call from
/// a build; never throws.
class HomeWidgetSync {
  HomeWidgetSync._();

  static String? _last;

  static Future<void> update({
    required String title,
    required String detail,
    required String streak,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final key = '$title|$detail|$streak';
    if (key == _last) return;
    _last = key;
    try {
      await HomeWidget.saveWidgetData<String>('title', title);
      await HomeWidget.saveWidgetData<String>('detail', detail);
      await HomeWidget.saveWidgetData<String>('streak', streak);
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'io.github.ksulaiman579.wird.WirdWidgetProvider',
      );
    } catch (_) {
      _last = null;
    }
  }
}
