import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../core/donations.dart';
import '../../shared/glass/glass.dart';

/// Al-Manhaj tab (M16.1) — a locked "coming soon" teaser for a structured
/// Islamic-studies platform. Per Item 1.26 (accounts offline-only) there is
/// no sign-in here: Wird is fully offline and account-free. The
/// donation/support section lives here as the "support the project" tab.
class AlManhajScreen extends StatelessWidget {
  const AlManhajScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).alManhajTitle)),
      body: ListView(
        children: [
          GlassCard(
            enableBlur: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccentIconChip(
                      icon: Icons.school_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).alManhajTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context).almanhajComingSoon),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.lock_clock_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).almanhajOfflineNote,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const GlassCard(enableBlur: false, child: SupportCard()),
        ],
      ),
    );
  }
}

/// Extracted so it can be reused/tested independently of which screen
/// hosts it (previously About, now Al-Manhaj per M16.1).
class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).almanhajSupportTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context).almanhajSupportBody),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _open(DonationLinks.payPal),
              child: const Text('PayPal'),
            ),
            // Buy Me a Coffee also points at the PayPal link — only a
            // PayPal account exists; kept as a second, more casual-sounding
            // call to action rather than a second real payment provider.
            OutlinedButton(
              onPressed: () => _open(DonationLinks.payPal),
              child: const Text('Buy Me a Coffee'),
            ),
          ],
        ),
      ],
    );
  }
}
