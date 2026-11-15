import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opt-in, anonymous crash reports (Sentry). Off unless the user turns it
/// on in Settings, and only available in builds made with
/// `--dart-define=SENTRY_DSN=...` — without a key the switch is hidden and
/// nothing is ever sent.
const _dsn = String.fromEnvironment('SENTRY_DSN');
const crashReportsPrefsKey = 'crash_reports_enabled';

bool get crashReportsAvailable => _dsn.isNotEmpty;

/// Starts Sentry if the user opted in. Sends only the error, stack and app
/// version: no user id, IP, device name, screenshots, breadcrumbs (which
/// could hold what was read) or performance data.
Future<void> initCrashReportsIfOptedIn() async {
  if (!crashReportsAvailable) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(crashReportsPrefsKey) ?? false)) return;
    // Plain-Dart Sentry (the Flutter one needs Android 8+; the app
    // supports 7). Errors are passed in from main.dart's handlers.
    await Sentry.init((o) {
      o.dsn = _dsn;
      o.sendDefaultPii = false;
      o.tracesSampleRate = 0;
      o.maxBreadcrumbs = 0;
      o.beforeSend = (event, hint) {
        event
          ..user = null
          ..serverName = null
          ..breadcrumbs = [];
        return event;
      };
    });
    _active = true;
  } catch (_) {
    // Crash reporting must never stop the app from starting.
  }
}

bool _active = false;

/// Sends one error when the user opted in; otherwise does nothing.
void reportCrash(Object error, StackTrace? stack) {
  if (!_active) return;
  Sentry.captureException(error, stackTrace: stack).ignore();
}

class CrashReportsNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(crashReportsPrefsKey) ?? false;
  }

  /// Takes effect on the next app start.
  Future<void> set(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(crashReportsPrefsKey, enabled);
    if (!enabled) {
      _active = false;
      await Sentry.close();
    }
    state = AsyncData(enabled);
  }
}

final crashReportsProvider =
    AsyncNotifierProvider<CrashReportsNotifier, bool>(CrashReportsNotifier.new);
