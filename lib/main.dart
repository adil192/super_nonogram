import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_nonogram/components/pages/play_page.dart';
import 'package:super_nonogram/components/pages/title_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TitlePage(),
    ),
    GoRoute(
      path: '/play',
      builder: (context, state) => const PlayPage(),
    )
  ]
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(brightness: Brightness.dark);
    final theme = baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      textTheme: GoogleFonts.righteousTextTheme(baseTheme.textTheme),
      useMaterial3: true,
    );

    return MaterialApp.router(
      title: 'Super Nonogram',
      theme: theme,
      routerConfig: _router,
    );
  }
}
