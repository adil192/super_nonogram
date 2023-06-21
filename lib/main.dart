import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_nonogram/components/pages/title_page.dart';

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

    return MaterialApp(
      title: 'Super Nonogram',
      theme: theme,
      home: const TitlePage(),
    );
  }
}
