import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_nonogram/pages/play_page.dart';
import 'package:super_nonogram/pages/search_page.dart';
import 'package:super_nonogram/pages/title_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TitlePage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/play/:query',
      builder: (context, state) => PlayPage(
        query: state.pathParameters['query']!,
      ),
    ),
  ]
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

        return MaterialApp.router(
          title: 'Super Nonogram',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic,
            textTheme: GoogleFonts.righteousTextTheme(),
            scaffoldBackgroundColor: lightDynamic.background,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic,
            textTheme: GoogleFonts.righteousTextTheme(),
            scaffoldBackgroundColor: darkDynamic.background,
          ),
          routerConfig: _router,
        );
      },
    );
  }
}
