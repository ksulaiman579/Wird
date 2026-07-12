import 'package:flutter/foundation.dart';

/// A tiny in-memory ring buffer of recent log lines and errors, so a tester
/// on a real device (with no computer / adb attached) can open a screen,
/// read what happened, and share it back for troubleshooting.
///
/// Captures three streams (wired in `main`): `debugPrint` output, Flutter
/// framework errors (`FlutterError.onError`), and uncaught async/platform
/// errors. Everything stays on the device unless the user explicitly
/// shares it — nothing is sent anywhere automatically.
class DebugLog {
  DebugLog._();
  static final DebugLog instance = DebugLog._();

  static const int _cap = 800;
  final List<String> _lines = <String>[];

  /// Bumped on every change so a viewer can rebuild.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  void add(String message, {String level = 'LOG'}) {
    final now = DateTime.now();
    final ts = '${_pad2(now.hour)}:${_pad2(now.minute)}:${_pad2(now.second)}'
        '.${now.millisecond.toString().padLeft(3, '0')}';
    for (final line in message.split('\n')) {
      _lines.add('$ts  $level  $line');
    }
    final overflow = _lines.length - _cap;
    if (overflow > 0) _lines.removeRange(0, overflow);
    revision.value++;
  }

  void recordFlutterError(FlutterErrorDetails details) {
    add(details.exceptionAsString(), level: 'FLUTTER');
    final stack = details.stack;
    if (stack != null) add(stack.toString(), level: 'STACK');
  }

  void recordError(Object error, StackTrace stack) {
    add(error.toString(), level: 'ERROR');
    add(stack.toString(), level: 'STACK');
  }

  List<String> get lines => List.unmodifiable(_lines);

  String dump() => _lines.join('\n');

  void clear() {
    _lines.clear();
    revision.value++;
  }

  static String _pad2(int n) => n.toString().padLeft(2, '0');
}
