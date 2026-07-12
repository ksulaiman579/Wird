import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;

import '../../core/theme/app_theme.dart';

/// Shows a modal bottom sheet with the app's glass styling. Use this instead
/// of a bare [showModalBottomSheet] so every options/filter sheet looks
/// consistent (reader options, plan pickers, filter panels).
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (context) => _GlassSheetBody(builder: builder),
  );
}

class _GlassSheetBody extends StatelessWidget {
  const _GlassSheetBody({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final radius = BorderRadius.vertical(top: Radius.circular(glass.cardRadius));

    Widget content = Container(
      decoration: BoxDecoration(
        color: glass.fillColor,
        borderRadius: radius,
        border: Border(
          top: BorderSide(color: glass.borderColor, width: glass.borderWidth),
          left: BorderSide(color: glass.borderColor, width: glass.borderWidth),
          right: BorderSide(color: glass.borderColor, width: glass.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: glass.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // A ListTile/SwitchListTile/InkWell descendant paints its
              // background and ink splashes on the *nearest* Material
              // ancestor. Without this, that's the root Scaffold Material
              // far up the tree, and this sheet's own decorated Container
              // silently paints over it (same fix as GlassCard).
              //
              // Flexible so a scrollable builder (e.g. the reader options'
              // SingleChildScrollView) is given a bounded height and scrolls
              // internally instead of forcing this min-size Column past the
              // sheet's max height (which overflowed on shorter viewports).
              Flexible(
                child: Material(
                  type: MaterialType.transparency,
                  child: builder(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (glass.blurSigma > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: glass.blurSigma,
          sigmaY: glass.blurSigma,
        ),
        child: content,
      );
    }

    content = ClipRRect(borderRadius: radius, child: content);

    // Escape closes the sheet (Item A6) — modal bottom sheets don't bind
    // Escape the way dialogs do. Applied here so every glass sheet gets it.
    // skipTraversal keeps this Focus out of tab order so it never steals
    // focus from an input inside the sheet.
    return Focus(
      autofocus: true,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).maybePop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: content,
    );
  }
}
