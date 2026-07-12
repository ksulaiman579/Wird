import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/credits.dart';

/// A short, essentials-only About screen (M23 feedback: don't serve up
/// detail nobody asked for). Full data provenance/licensing detail moved
/// to a separate `/settings/data-sources` screen — one tap further, not
/// gone. Credits collapse behind an expander instead of always listing
/// all of them. The "Support this project" donation card lives on the
/// Al-Manhaj tab (M16.1) — see `lib/features/almanhaj/almanhaj_screen.dart`.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).aboutTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Image(
                image: AssetImage('assets/icon/logo_display.png'),
                width: 96,
                height: 96,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                AppLocalizations.of(context).aboutIntro,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 32),
            Text(
              AppLocalizations.of(context).aboutFoundation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).aboutFoundationBody),
            const Divider(height: 32),
            Text(AppLocalizations.of(context).aboutLicense,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).aboutLicenseBody),
            const Divider(height: 32),
            const _CreditsExpander(),
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(AppLocalizations.of(context).aboutDataSourcesLink),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/settings/data-sources'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditsExpander extends StatelessWidget {
  const _CreditsExpander();

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(AppLocalizations.of(context).aboutCredits),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          for (final credit in credits)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(credit.name),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () => _open(credit.url),
            ),
        ],
      ),
    );
  }
}
