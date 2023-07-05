import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:super_nonogram/ads/banner_ad_widget.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:super_nonogram/settings/settings_blob.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.settings),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: ListView(
          children: [
            // ad banner
            if (AdState.adsSupported) const Padding(
              padding: EdgeInsets.all(32),
              child: BannerAdWidget(
                adSize: AdSize.mediumRectangle,
              ),
            ),

            // ad consent
            if (AdState.adsSupported) SettingsBlob(
              onTap: AdState.showConsentForm,
              children: [
                const FaIcon(FontAwesomeIcons.rectangleAd),
                Text(
                  t.settings.configureAdsConsent,
                  style: TextStyle(
                    color: colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
