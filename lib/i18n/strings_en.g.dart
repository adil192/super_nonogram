///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$title$en title = Translations$title$en.internal(_root);
	late final Translations$search$en search = Translations$search$en.internal(_root);
	late final Translations$play$en play = Translations$play$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$gameModes$en gameModes = Translations$gameModes$en.internal(_root);
}

// Path: title
class Translations$title$en {
	Translations$title$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Super Nonogram'
	String get appName => 'Super Nonogram';

	/// en: 'Play levels'
	String get playLevels => 'Play\nlevels';

	/// en: 'Play images'
	String get playImages => 'Play\nimages';

	/// en: 'Play classic'
	String get playClassic => 'Play\nclassic';

	/// en: 'Achievements'
	String get achievements => 'Achievements';
}

// Path: search
class Translations$search$en {
	Translations$search$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create a puzzle'
	String get createNewPuzzle => 'Create a puzzle';

	/// en: 'Please enter a prompt'
	String get enterPrompt => 'Please enter a prompt';

	/// en: 'Prompt'
	String get prompt => 'Prompt';

	/// en: 'Failed to generate board, please try another prompt'
	String get failedToGenerateBoard => 'Failed to generate board, please try another prompt';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Your prompt will be sent to Pixabay, a free image sharing website, to fetch a relevant image. See our ${link(Privacy Policy)} for more information.'
	TextSpan privacyInformation({required InlineSpanBuilder link}) => TextSpan(children: [
		const TextSpan(text: 'Your prompt will be sent to Pixabay, a free image sharing website, to fetch a relevant image.\nSee our '),
		link('Privacy Policy'),
		const TextSpan(text: ' for more information.'),
	]);
}

// Path: play
class Translations$play$en {
	Translations$play$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Level $n'
	String level({required Object n}) => 'Level ${n}';

	/// en: 'Level $n completed!'
	String levelCompleted({required Object n}) => 'Level ${n} completed!';

	/// en: 'Puzzle completed!'
	String get puzzleCompleted => 'Puzzle completed!';

	/// en: 'Next level'
	String get nextLevel => 'Next level';

	/// en: 'Restart level'
	String get restartLevel => 'Restart level';

	/// en: 'Restart puzzle'
	String get restartPuzzle => 'Restart puzzle';

	/// en: 'Play another'
	String get playAnother => 'Play another';

	/// en: 'Back to title page'
	String get backToTitlePage => 'Back to title page';

	/// en: 'Image by $author from $pixabay'
	TextSpan imageAttribution({required InlineSpan author, required InlineSpan pixabay}) => TextSpan(children: [
		const TextSpan(text: 'Image by '),
		author,
		const TextSpan(text: ' from '),
		pixabay,
	]);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Use Atkinson Hyperlegible font'
	String get hyperlegibleFont => 'Use Atkinson Hyperlegible font';

	/// en: 'More readable for people with low vision'
	String get hyperlegibleFontDescription => 'More readable for people with low vision';

	/// en: 'Use haptic feedback'
	String get useHapticFeedback => 'Use haptic feedback';

	/// en: 'Vibrate slightly when you interact with the board'
	String get useHapticFeedbackDescription => 'Vibrate slightly when you interact with the board';

	/// en: 'Tap here for more information about this app'
	String get about => 'Tap here for more information about this app';

	/// en: 'Super Nonogram Copyright (C) 2025 Adil Hanney This program comes with absolutely no warranty. This is free software, and you are welcome to redistribute it under certain conditions.'
	String get legalese => 'Super Nonogram  Copyright (C) 2025  Adil Hanney\nThis program comes with absolutely no warranty. This is free software, and you are welcome to redistribute it under certain conditions.';
}

// Path: gameModes
class Translations$gameModes$en {
	Translations$gameModes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Levels'
	String get level => 'Levels';

	/// en: 'Classic'
	String get classic => 'Classic';

	/// en: 'Image'
	String get image => 'Image';
}
