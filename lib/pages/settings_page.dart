import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:super_nonogram/ads/banner_ad_widget.dart';
import 'package:super_nonogram/data/prefs.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:super_nonogram/settings/animated_app_icon.dart';
import 'package:super_nonogram/settings/settings_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconTheme = IconTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.settings),
      ),
      body: DefaultTextStyle.merge(
        style: TextStyle(
          color: colorScheme.onSurface,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: ListView(
              children: [
                if (AdState.adsSupported) ...[
                  // ad banner
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: BannerAdWidget(
                      adSize: AdSize.mediumRectangle,
                    ),
                  ),
                  const Divider(),

                  // ad consent
                  SettingsItem(
                    onTap: AdState.showConsentForm,
                    children: [
                      const FaIcon(FontAwesomeIcons.rectangleAd),
                      Text(
                        t.settings.configureAdsConsent,
                      ),
                    ],
                  ),
                  const Divider(),
                ],

                // hyperlegible font
                SettingsItem(
                  onTap: () => setState(() {
                    Prefs.hyperlegibleFont.value =
                        !Prefs.hyperlegibleFont.value;
                  }),
                  children: [
                    Text(
                      'Aa',
                      style: TextStyle(
                        fontSize: iconTheme.size ?? 24,
                      ),
                    ),
                    Text(
                      t.settings.hyperlegibleFont,
                    ),
                    Switch(
                      value: Prefs.hyperlegibleFont.value,
                      onChanged: (_) => setState(() {
                        Prefs.hyperlegibleFont.value =
                            !Prefs.hyperlegibleFont.value;
                      }),
                    ),
                  ],
                ),
                const Divider(),

                if (AdState.adsSupported) ...[
                  // ad banner
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: BannerAdWidget(
                      adSize: AdSize.mediumRectangle,
                    ),
                  ),
                  const Divider(),
                ],

                SettingsItem(
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: t.title.appName,
                      applicationLegalese: t.settings.legalese,
                    );
                  },
                  children: [
                    const FaIcon(FontAwesomeIcons.info),
                    Text(
                      t.title.appName,
                    ),
                    Text(
                      t.settings.about,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Divider(),

                // something to put at the bottom after the last divider
                const AnimatedAppIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
