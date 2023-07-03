import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_nonogram/data/prefs.dart';
import 'package:super_nonogram/i18n/strings.g.dart';
import 'package:super_nonogram/pages/search_page.dart';
import 'package:super_nonogram/pages/settings_page.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final double titleFontSize;
    final double buttonFontSize;
    switch (mediaQuery.size.width) {
      case < 400:
        titleFontSize = 24;
        buttonFontSize = 16;
      case < 600:
        titleFontSize = 36;
        buttonFontSize = 24;
      default:
        titleFontSize = 48;
        buttonFontSize = 32;
    }

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonFontSize * 2),
    );

    return Scaffold(
      body: ColoredBox(
        color: colorScheme.primary,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.title.appName,
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: buttonShape,
                ),
                onPressed: () {
                  context.push('/play?level=${Prefs.currentLevel.value}');
                },
                child: Padding(
                  padding: EdgeInsets.all(buttonFontSize / 2),
                  child: Text(
                    t.title.playLevels,
                    style: TextStyle(
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OpenContainer(
                tappable: false,
                closedShape: buttonShape,
                closedColor: Colors.transparent,
                closedElevation: 0,
                openColor: Colors.transparent,
                openElevation: 0,
                closedBuilder: (context, action) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: buttonShape,
                    ),
                    onPressed: action,
                    child: Padding(
                      padding: EdgeInsets.all(buttonFontSize / 2),
                      child: Text(
                        t.title.playCustom,
                        style: TextStyle(
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return const SearchPage();
                },
              ),
              const SizedBox(height: 16),
              OpenContainer(
                tappable: false,
                closedShape: buttonShape,
                closedColor: Colors.transparent,
                closedElevation: 0,
                openColor: Colors.transparent,
                openElevation: 0,
                closedBuilder: (context, action) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: buttonShape,
                    ),
                    onPressed: action,
                    child: Padding(
                      padding: EdgeInsets.all(buttonFontSize / 2),
                      child: Text(
                        t.settings.settings,
                        style: TextStyle(
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return const SettingsPage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
