import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/diagnostics/crash_reporting.dart';
import 'core/cloud/cloud_config.dart';
import 'core/diagnostics/debug_log.dart';

void main() {
  // Mirror all debugPrint output into the on-device log buffer (Settings →
  // Diagnostics) so testers can troubleshoot without a computer attached.
  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) DebugLog.instance.add(message);
    originalDebugPrint(message, wrapWidth: wrapWidth);
  };

  runZonedGuarded(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // Framework + async/platform error capture → in-app log.
    final priorFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      DebugLog.instance.recordFlutterError(details);
      if (priorFlutterOnError != null) {
        priorFlutterOnError(details);
      } else {
        FlutterError.presentError(details);
      }
    };
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      DebugLog.instance.recordError(error, stack);
      return true;
    };

    // The Supabase project is used only as a public, read-only mirror for
    // content downloads, fetched over plain HTTP (see ContentSource). No
    // client SDK is needed, so nothing is initialised before the first
    // frame (M27.3).
    DebugLog.instance.add(
      'Wird started — content mirror ${CloudConfig.isConfigured ? "on" : "off"}',
    );

    await initCrashReportsIfOptedIn();

    runApp(const ProviderScope(child: DailyApp()));
  }, (error, stack) {
    DebugLog.instance.recordError(error, stack);
  });
}
