import 'dart:math';

import 'package:games_services/games_services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/data/stows.dart';
import 'package:super_nonogram/games_services/games_services_helper.dart';
import 'package:super_nonogram/i18n/strings.g.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenSize = MediaQuery.sizeOf(context);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final elevatedButtonStyle = ElevatedButtonTheme.of(context).style!.copyWith(
      shape: WidgetStatePropertyAll(buttonShape),
      textStyle: WidgetStatePropertyAll(
        textTheme.titleLarge!.copyWith(fontSize: 24),
      ),
      padding: WidgetStatePropertyAll(
        const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      ),
      backgroundColor: WidgetStatePropertyAll(
        Color.lerp(
          theme.colorScheme.surface,
          theme.colorScheme.primaryContainer,
          0.4,
        )!,
      ),
      foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onSurface),
    );
    final playButtonStyle = elevatedButtonStyle.copyWith(
      minimumSize: WidgetStatePropertyAll(Size(double.infinity, 128)),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 32,
            horizontal: max((screenSize.width - 600) / 2, 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(t.title.appName, style: textTheme.displayMedium),
              const SizedBox(height: 32),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: playButtonStyle.copyWith(
                        backgroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.primaryContainer,
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onPressed: () {
                        context.push('/play?level=${stows.currentLevel.value}');
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t.title.playLevels, textAlign: .center),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: playButtonStyle.copyWith(
                        backgroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.secondaryContainer,
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      onPressed: () {
                        context.push('/play?classic');
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t.title.playClassic, textAlign: .center),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: playButtonStyle.copyWith(
                        backgroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.tertiaryContainer,
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      onPressed: () {
                        context.push('/search');
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t.title.playImages, textAlign: .center),
                      ),
                    ),
                  ),
                ],
              ),
              if (isGamesServicesSupported)
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () =>
                      runAfterGamesSignIn(GamesServices.showAchievements),
                  child: Text(t.title.achievements),
                ),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () {
                  context.push('/settings');
                },
                child: Text(t.settings.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
