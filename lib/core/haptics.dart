import 'package:flutter/services.dart';

/// One place for the app's haptic vocabulary (M23.14), replacing scattered
/// direct `HapticFeedback.*` calls so the feedback stays consistent and can
/// be tuned (or globally muted) from a single spot later.
///
/// Semantic names, not physical ones:
/// - [selection] — moving between choices (nav tabs, pickers).
/// - [tick] — a light confirming tap (dhikr counter, small toggles).
/// - [impact] — a firmer confirmation (a milestone, a committed action).
/// - [success] — the strongest, for a completed session / celebration.
abstract final class Haptics {
  static void selection() => HapticFeedback.selectionClick();
  static void tick() => HapticFeedback.lightImpact();
  static void impact() => HapticFeedback.mediumImpact();
  static void success() => HapticFeedback.heavyImpact();
}
