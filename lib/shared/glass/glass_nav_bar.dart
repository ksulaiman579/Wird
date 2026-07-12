import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/haptics.dart';

/// The app's bottom navigation bar (M23.2): an opaque deep-emerald chrome
/// band with gold icons/labels, matching [GlassAppBar]. Unlike Material's
/// [NavigationBar] (which spreads a fixed destination count evenly), this
/// lays destinations out at a fixed width so that at most
/// [visibleDestinationCount] are on screen at once — extra destinations
/// (Al-Manhaj, per the M23 nav decision) sit just past the trailing edge,
/// reachable by pressing and swiping the bar horizontally. No scrollbar is
/// shown; a light haptic fires when the scroll settles.
class GlassNavBar extends StatefulWidget {
  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.visibleDestinationCount = 5,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  /// How many destinations fit on screen before the row overflows into
  /// swipe-to-reveal territory. Has no visual effect once
  /// `destinations.length <= visibleDestinationCount` — every tab already
  /// fits, so the row simply doesn't scroll.
  final int visibleDestinationCount;

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar> {
  final _controller = ScrollController();

  @override
  void didUpdateWidget(GlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    if (!_controller.hasClients) return;
    final itemWidth = _controller.position.viewportDimension /
        widget.visibleDestinationCount.clamp(1, widget.destinations.length);
    final targetLeft = widget.selectedIndex * itemWidth;
    final targetRight = targetLeft + itemWidth;
    final viewStart = _controller.offset;
    final viewEnd = viewStart + _controller.position.viewportDimension;
    if (targetLeft < viewStart) {
      _controller.animateTo(targetLeft, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else if (targetRight > viewEnd) {
      _controller.animateTo(
        (targetRight - _controller.position.viewportDimension).clamp(0, _controller.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>() ?? GlassTheme.light;
    final gold = glass.chromeForeground;
    final visibleCount = widget.visibleDestinationCount.clamp(1, widget.destinations.length);

    return Container(
      color: glass.chromeColor,
      height: 64 + MediaQuery.paddingOf(context).bottom,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / visibleCount;
            return NotificationListener<ScrollEndNotification>(
              onNotification: (_) {
                Haptics.selection();
                return false;
              },
              child: ScrollConfiguration(
                behavior: const _NoScrollbarBehavior(),
                child: SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: [
                      for (var i = 0; i < widget.destinations.length; i++)
                        SizedBox(
                          width: itemWidth,
                          child: _NavItem(
                            destination: widget.destinations[i],
                            selected: i == widget.selectedIndex,
                            gold: gold,
                            onTap: () => widget.onDestinationSelected(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.gold,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool selected;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? gold : gold.withValues(alpha: 0.75);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: color),
            child: selected ? (destination.selectedIcon ?? destination.icon) : destination.icon,
          ),
          const SizedBox(height: 2),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

/// Suppresses the platform scrollbar on the nav bar's horizontal scroll —
/// the design spec calls for "just the icons", swipe-to-reveal without a
/// visible scroll affordance.
class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}
