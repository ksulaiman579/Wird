import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
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

    // Cloud backup is OPT-IN and OFF unless this build was compiled with the
    // Supabase keys (--dart-define). When configured, initialise with
    // auto-refresh DISABLED so the app never produces a background auth
    // event — a user counts as monthly-active only in a month they
    // deliberately sign in to back up or restore.
    if (CloudConfig.isConfigured) {
      await Supabase.initialize(
        url: CloudConfig.supabaseUrl,
        // Publishable (public) key — safe to ship; RLS gates all access.
        publishableKey: CloudConfig.supabasePublishableKey,
        authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
      );
    }

    DebugLog.instance.add(
      'Wird started — cloud backup ${CloudConfig.isConfigured ? "enabled" : "disabled"}',
    );

    runApp(const ProviderScope(child: DailyApp()));
  }, (error, stack) {
    DebugLog.instance.recordError(error, stack);
  });
}
