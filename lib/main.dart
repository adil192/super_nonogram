import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_nonogram/data/game_mode.dart';
import 'package:super_nonogram/data/stows.dart';
import 'package:super_nonogram/games_services/games_services_helper.dart';
import 'package:super_nonogram/pages/play_page.dart';
import 'package:super_nonogram/pages/search_page.dart';
import 'package:super_nonogram/pages/settings_page.dart';
import 'package:super_nonogram/pages/title_page.dart';
import 'package:super_nonogram/theme/theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TitlePage()),
    GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
    GoRoute(
      path: '/play',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        final level = int.tryParse(state.uri.queryParameters['level'] ?? '');
        if (query != null) {
          return PlayPage(ImageGameMode(query));
        } else if (level != null) {
          return PlayPage(LevelGameMode(level));
        } else if (state.uri.queryParameters.containsKey('classic')) {
          return PlayPage(
            ClassicGameMode(
              int.tryParse(state.uri.queryParameters['classic']!),
            ),
          );
        } else {
          throw Exception('Either query or level must be provided');
        }
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await stows.currentLevel.waitUntilRead();

  _addLicenses();

  if (isGamesServicesSupported) GamesServices.signIn();

  runApp(const MyApp());
}

void _addLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/google_fonts/Righteous/OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appKey = GlobalKey<State<MaterialApp>>();

  void _setState() => setState(() {});

  @override
  void initState() {
    super.initState();
    stows.hyperlegibleFont.addListener(_setState);
  }

  @override
  void dispose() {
    stows.hyperlegibleFont.removeListener(_setState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.highContrastOf(context);
        return MaterialApp.router(
          key: _appKey,
          title: 'Super Nonogram',
          debugShowCheckedModeBanner: false,
          theme: SuperNonogramTheme.createTheme(
            brightness: Brightness.light,
            platform: defaultTargetPlatform,
            highContrast: highContrast,
          ),
          darkTheme: SuperNonogramTheme.createTheme(
            brightness: Brightness.dark,
            platform: defaultTargetPlatform,
            highContrast: highContrast,
          ),
          routerConfig: _router,
        );
  }
}
