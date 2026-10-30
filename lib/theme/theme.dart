import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_nonogram/data/stows.dart';

abstract class SuperNonogramTheme {
  static ThemeData createTheme({
    required Brightness brightness,
    required TargetPlatform platform,
    bool highContrast = false,
  }) {
    var colorScheme = _getDefaultColorScheme(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (platform != TargetPlatform.android &&
        platform != TargetPlatform.fuchsia) {
      final plainBackground = brightness == Brightness.light
          ? Colors.white
          : Colors.black;
      colorScheme = colorScheme.copyWith(surface: plainBackground);
    }
    final textTheme = getTextTheme(
      platform,
      colorScheme,
      stows.hyperlegibleFont.value,
    );
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        applyThemeToAll: true,
      ),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(textStyle: textTheme.titleLarge),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.titleLarge),
      ),
      appBarTheme: AppBarTheme(centerTitle: false),
    );
  }

  static TextTheme getTextTheme(
    TargetPlatform platform,
    ColorScheme colorScheme,
    bool useHyperlegible,
  ) {
    final typography = Typography.material2021(
      platform: platform,
      colorScheme: colorScheme,
    );
    final base = colorScheme.brightness == Brightness.dark
        ? typography.white
        : typography.black;

    final (headerStyle, bodyStyle) = _getHeaderAndBodyTextStyles(
      useHyperlegible: useHyperlegible,
      base: base,
    );

    return base.copyWith(
      displayLarge: base.displayLarge!.merge(headerStyle),
      displayMedium: base.displayMedium!.merge(headerStyle),
      displaySmall: base.displaySmall!.merge(headerStyle),
      headlineLarge: base.headlineLarge!.merge(headerStyle),
      headlineMedium: base.headlineMedium!.merge(headerStyle),
      headlineSmall: base.headlineSmall!.merge(headerStyle),
      titleLarge: base.titleLarge!.merge(headerStyle),
      titleMedium: base.titleMedium!.merge(headerStyle),
      titleSmall: base.titleSmall!.merge(headerStyle),
      bodyLarge: base.bodyLarge!.merge(bodyStyle),
      bodyMedium: base.bodyMedium!.merge(bodyStyle),
      bodySmall: base.bodySmall!.merge(bodyStyle),
      labelLarge: base.labelLarge!.merge(bodyStyle),
      labelMedium: base.labelMedium!.merge(bodyStyle),
      labelSmall: base.labelSmall!.merge(bodyStyle),
    );
  }

  static ColorScheme _getDefaultColorScheme({
    required Brightness brightness,
    required bool highContrast,
  }) {
    return SeedColorScheme.fromSeeds(
      brightness: brightness,
      primaryKey: Colors.deepPurple,
      secondaryKey: Colors.blue,
      tertiaryKey: Colors.teal,
      contrastLevel: highContrast ? 0.7 : 0.0,
      useExpressiveOnContainerColors: !highContrast,
      tones: highContrast
          ? FlexTones.ultraContrast(brightness)
          : FlexTones.material(brightness),
    );
  }

  static (TextStyle, TextStyle) _getHeaderAndBodyTextStyles({
    required bool useHyperlegible,
    required TextTheme base,
  }) {
    final systemStyle = TextStyle(
      fontFamily: base.bodyMedium!.fontFamily,
      fontFamilyFallback: [
        'Adwaita Sans', // not included in Flutter yet
        ...?base.bodyMedium!.fontFamilyFallback,
        'Atkinson Hyperlegible Next',
        'AtkinsonHyperlegibleNext',
        'Atkinson Hyperlegible',
        'AtkinsonHyperlegible',
      ],
    );
    late final hyperlegibleStyle = GoogleFonts.atkinsonHyperlegible();
    final righteousStyle = GoogleFonts.righteous();

    final headerStyle = useHyperlegible ? hyperlegibleStyle : righteousStyle;
    final bodyStyle = useHyperlegible ? hyperlegibleStyle : systemStyle;
    return (headerStyle, bodyStyle);
  }
}
