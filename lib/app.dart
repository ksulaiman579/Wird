import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/backup/backup_service.dart';
import 'core/db/database.dart';
import 'core/notifications/notification_providers.dart';
import 'core/update/background_update_check.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/palette.dart';
import 'core/theme/palette_provider.dart';
import 'l10n/gen/app_localizations.dart';

import 'core/prefs/app_language_provider.dart';
import 'core/theme/theme_mode_provider.dart';
import 'router.dart';

/// Enables mouse/trackpad drag-to-scroll everywhere (Flutter's default
/// [MaterialScrollBehavior] only wires touch), so swipe gestures — e.g.
/// paging between ayahs in the Quran reader — work when the app is driven
/// by a mouse (web/desktop), not just a touchscreen.
class _WirdScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

class DailyApp extends ConsumerStatefulWidget {
  const DailyApp({super.key});

  @override
  ConsumerState<DailyApp> createState() => _DailyAppState();
}

class _DailyAppState extends ConsumerState<DailyApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Fire-and-forget: notification setup must never block first frame.
      unawaited(_initNotifications());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      if (!kIsWeb) unawaited(_maybeMonthlyBackup());
    });
  }

  /// Launch-time monthly local backup (Item 1.27b): silent unless it
  /// actually writes one, in which case a brief snackbar notes it.
  Future<void> _maybeMonthlyBackup() async {
    try {
      final wrote = await BackupService(ref.read(appDatabaseProvider))
          .maybeRunMonthlyBackup();
      if (wrote) {
        _messengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Monthly backup saved to this device')),
        );
      }
    } catch (_) {
      // Best-effort — never disrupt startup.
    }
  }

  Future<void> _initNotifications() async {
    try {
      final service = ref.read(notificationServiceProvider);
      service.onSelectPayload = (payload) {
        ref.read(routerProvider).go(payload);
      };
      await service.init();
      await rescheduleNotifications(ref);
      // Register the ~twice-daily background poll that surfaces an "update
      // available" / announcement notification even when the app is closed
      // (Android only; no backend — it reads the same GitHub JSON).
      await registerBackgroundUpdateCheck();
    } catch (_) {
      // Notification setup is best-effort: a missing plugin (e.g. no
      // device/emulator backing flutter_local_notifications) must never
      // crash app startup — this is a real possibility during `flutter
      // test`, which has no platform channel to answer these calls.
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider).value ?? AppThemeMode.system;
    final palette = ref.watch(paletteProvider).value ?? defaultPalette;
    final router = ref.watch(routerProvider);
    final localeCode = ref.watch(appLanguageProvider).value ?? 'en';

    return MaterialApp.router(
      title: 'Wird',
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      scrollBehavior: _WirdScrollBehavior(),
      locale: Locale(localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(palette),
      darkTheme: themeMode == AppThemeMode.amoled
          ? AppTheme.amoled(palette)
          : AppTheme.dark(palette),
      themeMode: AppTheme.flutterThemeMode(themeMode),
      routerConfig: router,
      builder: (context, child) => _ResponsiveShell(child: child ?? const SizedBox()),
    );
  }
}

/// Web/desktop parity (M23.12): on wide viewports the app is centred in a
/// ~480dp phone-width column over a parchment backdrop, so the PWA reads
/// like the mobile app instead of stretching edge-to-edge. On phones
/// (narrow viewports) it is a no-op passthrough.
class _ResponsiveShell extends StatelessWidget {
  const _ResponsiveShell({required this.child});

  final Widget child;

  /// Below this the app already fills the screen — no framing.
  static const _breakpoint = 640.0;
  static const _phoneWidth = 480.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _breakpoint) return child;

    final scheme = Theme.of(context).colorScheme;
    // A touch darker than the app surface so the phone column reads as a
    // distinct device sitting on a parchment desk.
    final backdrop = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.06),
      scheme.surface,
    );
    return ColoredBox(
      color: backdrop,
      child: Center(
        child: ClipRect(
          child: SizedBox(
            width: _phoneWidth,
            child: Material(
              color: scheme.surface,
              elevation: 8,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
