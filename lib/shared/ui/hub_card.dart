import 'package:flutter/material.dart';

import '../glass/glass_card.dart';
import 'corner_flourishes.dart';
import 'gold_pill_button.dart';
import 'wird_icons.dart';

/// The card used throughout every hub page (Home/Quran/Explore/More — M23
/// design spec): an illustration slot, bold title, a short two-line grey
/// description, and a full-width gold pill call to action. Every hub card
/// carries the same faint gold corner flourishes so the manuscript identity
/// is consistent across all hubs (no per-card opt-in — that made the Explore
/// grid look half-ornamented).
///
/// Two of these sit side by side in a 2-column grid on hub pages — see
/// [HubCardGrid].
class HubCard extends StatelessWidget {
  const HubCard({
    super.key,
    required this.glyph,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onTap,
  });

  final WirdGlyph glyph;
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          ...cornerFlourishes(context),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: WirdIcon(glyph, size: 40),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: GoldPillButton(label: ctaLabel, onPressed: onTap),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

/// Lays [children] out as the renders' 2-column hub grid.
class HubCardGrid extends StatelessWidget {
  // 230 left a visible void between a card's 2-line description and its CTA;
  // 196 was too tight and clipped the 2nd line of longer (and localized)
  // descriptions. 212 fits icon + title + a full 2-line description + pill
  // without clipping, while staying close to the iOS-tight look (D8).
  const HubCardGrid({super.key, required this.children, this.mainAxisExtent = 212});

  final List<Widget> children;
  final double? mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: mainAxisExtent,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
