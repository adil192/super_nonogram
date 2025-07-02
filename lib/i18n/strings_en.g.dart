///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element

class Translations implements BaseTranslations<AppLocale, Translations> {
  /// Returns the current translations of the given [context].
  ///
  /// Usage:
  /// final t = Translations.of(context);
  static Translations of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, Translations>(context).translations;

  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  Translations(
      {Map<String, Node>? overrides,
      PluralResolver? cardinalResolver,
      PluralResolver? ordinalResolver,
      TranslationMetadata<AppLocale, Translations>? meta})
      : assert(overrides == null,
            'Set "translation_overrides: true" in order to enable this feature.'),
        $meta = meta ??
            TranslationMetadata(
              locale: AppLocale.en,
              overrides: overrides ?? {},
              cardinalResolver: cardinalResolver,
              ordinalResolver: ordinalResolver,
            );

  /// Metadata for the translations of <en>.
  @override
  final TranslationMetadata<AppLocale, Translations> $meta;

  late final Translations _root = this; // ignore: unused_field

  Translations $copyWith(
          {TranslationMetadata<AppLocale, Translations>? meta}) =>
      Translations(meta: meta ?? this.$meta);

  // Translations
  late final TranslationsTitleEn title = TranslationsTitleEn.internal(_root);
  late final TranslationsSearchEn search = TranslationsSearchEn.internal(_root);
  late final TranslationsPlayEn play = TranslationsPlayEn.internal(_root);
  late final TranslationsSettingsEn settings =
      TranslationsSettingsEn.internal(_root);
}

// Path: title
class TranslationsTitleEn {
  TranslationsTitleEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  String get appName => 'Super Nonogram';
  String get playLevels => 'Play levels';
  String get playImages => 'Play images';
  String get achievements => 'Achievements';
}

// Path: search
class TranslationsSearchEn {
  TranslationsSearchEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  String get createNewPuzzle => 'Create a puzzle';
  String get enterPrompt => 'Please enter a prompt';
  String get prompt => 'Prompt';
  String get failedToGenerateBoard =>
      'Failed to generate board, please try another prompt';
  String get create => 'Create';
}

// Path: play
class TranslationsPlayEn {
  TranslationsPlayEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  String level({required Object n}) => 'Level ${n}';
  String levelCompleted({required Object n}) => 'Level ${n} completed!';
  String get puzzleCompleted => 'Puzzle completed!';
  String get nextLevel => 'Next level';
  String get restartLevel => 'Restart level';
  String get restartPuzzle => 'Restart puzzle';
  String get backToTitlePage => 'Back to title page';
  TextSpan imageAttribution(
          {required InlineSpan author, required InlineSpan pixabay}) =>
      TextSpan(children: [
        const TextSpan(text: 'Image by '),
        author,
        const TextSpan(text: ' from '),
        pixabay,
      ]);
}

// Path: settings
class TranslationsSettingsEn {
  TranslationsSettingsEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  String get settings => 'Settings';
  String get configureAdsConsent => 'Configure ads consent';
  String get hyperlegibleFont => 'Use Atkinson Hyperlegible font';
  String get about => 'Tap here for more information about this app';
  String get legalese =>
      'Super Nonogram  Copyright (C) 2023  Adil Hanney\nThis program comes with absolutely no warranty. This is free software, and you are welcome to redistribute it under certain conditions.';
}
