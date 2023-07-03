import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:super_nonogram/ads/banner_ad_widget.dart';
import 'package:super_nonogram/i18n/strings.g.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  BlobController blobController = BlobController();

  @override
  Widget build(BuildContext context) {
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
            if (AdState.adsSupported) GestureDetector(
              onTap: () {
                blobController.change();
                AdState.showConsentForm();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return Blob.animatedRandom(
                    size: constraints.minWidth,
                    minGrowth: 7,
                    styles: BlobStyles(
                      color: colorScheme.primary.withOpacity(0.3),
                      fillType: BlobFillType.fill,
                    ),
                    controller: blobController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  );
                }
              ),
            ),

            if (AdState.adsSupported) const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
