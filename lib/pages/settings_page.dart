import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/data/stows.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:super_nonogram/settings/animated_app_icon.dart';
import 'package:super_nonogram/settings/settings_item.dart';
import 'package:super_nonogram/util/sonic_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconTheme = IconTheme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              // hyperlegible font
              SettingsItem(
                onTap: () => stows.hyperlegibleFont.value =
                    !stows.hyperlegibleFont.value,
                children: [
                  Text(
                    'Aa',
                    style: textTheme.displaySmall?.copyWith(
                      fontSize: (iconTheme.size ?? 24) * 0.8,
                    ),
                    softWrap: false,
                  ),
                  Text(t.settings.hyperlegibleFont, textAlign: .center),
                  Text(
                    t.settings.hyperlegibleFontDescription,
                    style: textTheme.labelMedium,
                    textAlign: .center,
                  ),
                  ListenableBuilder(
                    listenable: stows.hyperlegibleFont,
                    builder: (context, child) {
                      return Switch.adaptive(
                        value: stows.hyperlegibleFont.value,
                        onChanged: (_) => stows.hyperlegibleFont.value =
                            !stows.hyperlegibleFont.value,
                      );
                    },
                  ),
                ],
              ),
              const Divider(),

              // haptic feedback
              SettingsItem(
                onTap: () => stows.useHapticFeedback.value =
                    !stows.useHapticFeedback.value,
                children: [
                  Icon(Icons.vibration),
                  Text(t.settings.useHapticFeedback, textAlign: .center),
                  Text(
                    t.settings.useHapticFeedbackDescription,
                    style: textTheme.labelMedium,
                    textAlign: .center,
                  ),
                  ListenableBuilder(
                    listenable: stows.useHapticFeedback,
                    builder: (context, child) {
                      return Switch.adaptive(
                        value: stows.useHapticFeedback.value,
                        onChanged: (_) {
                          stows.useHapticFeedback.value =
                              !stows.useHapticFeedback.value;
                          SonicController.notifyHapticSettingChanged();
                        },
                      );
                    },
                  ),
                ],
              ),
              const Divider(),

              SettingsItem(
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: t.title.appName,
                    applicationLegalese: t.settings.legalese,
                  );
                },
                children: [
                  const Icon(Icons.info),
                  Text(t.title.appName, textAlign: .center),
                  Text(
                    t.settings.about,
                    style: textTheme.labelMedium,
                    textAlign: .center,
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
    );
  }
}
