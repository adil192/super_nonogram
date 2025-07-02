import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_nonogram/ads/banner_ad_widget.dart';
import 'package:super_nonogram/data/prefs.dart';
import 'package:super_nonogram/games_services/games_services_helper.dart';
import 'package:super_nonogram/pages/play_page.dart';
import 'package:super_nonogram/pages/search_page.dart';
import 'package:super_nonogram/pages/settings_page.dart';
import 'package:super_nonogram/pages/title_page.dart';

final _router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const TitlePage(),
  ),
  GoRoute(
    path: '/search',
    builder: (context, state) => const SearchPage(),
  ),
  GoRoute(
    path: '/play',
    builder: (context, state) => PlayPage(
      query: state.uri.queryParameters['query'],
      level: int.tryParse(state.uri.queryParameters['level'] ?? ''),
    ),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsPage(),
  ),
]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdState.init();

  Prefs.init();
  await Future.wait([
    Prefs.currentLevel.waitUntilLoaded(),
  ]);

  _addLicenses();

  if (isGamesServicesSupported) GamesServices.signIn();

  runApp(const MyApp());
}

void _addLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license =
        await rootBundle.loadString('assets/google_fonts/Righteous/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _setState() => setState(() {});
  @override
  void initState() {
    super.initState();
    Prefs.hyperlegibleFont.addListener(_setState);
  }

  @override
  void dispose() {
    Prefs.hyperlegibleFont.removeListener(_setState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        lightDynamic ??= ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        );
        darkDynamic ??= ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        );

        final TextTheme textTheme;
        if (Prefs.hyperlegibleFont.value) {
          textTheme = GoogleFonts.atkinsonHyperlegibleTextTheme();
        } else {
          textTheme = GoogleFonts.righteousTextTheme();
        }

        return MaterialApp.router(
          title: 'Super Nonogram',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic,
            textTheme: textTheme,
            scaffoldBackgroundColor: lightDynamic.surface,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic,
            textTheme: textTheme,
            scaffoldBackgroundColor: darkDynamic.surface,
          ),
          routerConfig: _router,
        );
      },
    );
  }
}
