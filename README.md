# Super Nonogram

[<img src='https://github.com/adil192/super_nonogram/blob/main/assets_raw/PWA-dark-en.svg'
    alt='Launch as web app'
    height=80>][web_app]

This is a Flutter reimplementation of my [old Nonogram web app](https://adil.hanney.org/nonogram/).

It automatically generates boards based on your search term
(images are sourced from [Pixabay](https://pixabay.com/) using the [Pixabay API](https://pixabay.com/api/docs/)).

## Translating

### Extending existing languages

Check [_missing_translations.json](https://github.com/adil192/super_nonogram/blob/main/lib/i18n/_missing_translations.json)
   to see if any translations are missing.

1. Use [this link](https://github.com/adil192/super_nonogram/edit/main/lib/i18n/_missing_translations.json)
   to edit `_missing_translations.json`.
2. Update your `_missing_translations.json` file with your translations, e.g. updating German (de)
    ```javascript
    "de": {
      "editor": {
        "newerFileFormat": {
          "title": "Diese Notiz wurde mit einer neueren Version von Saber bearbeitet",
          "subtitle": "Wenn du diese Notiz bearbeitest, können Daten verloren gehen. Möchtest du die Notiz trotzdem öffnen?",
          "openAnyway": "Trotzdem öffnen",
          "cancel": "Abbruch"
        }
      }
    },
    // ignore the other languages...
    ```
3. Open a pull request! I'll do the rest

### Adding a new language

1. Look for your locale code [here](https://saimana.com/list-of-country-locale-code/),
   e.g. `hi` for Hindi, `fr` for French, `bn` for Bengali, `ar` for Arabic, etc.
2. Use [this link](https://github.com/adil192/saber/new/main/lib/i18n/community)
   to create a new file in `lib/i18n/community/` called `strings_XX.i18n.json`
   where `XX` is your locale code.
3. Copy the contents of an existing file like
   [`lib/i18n/strings.i18n.json`](https://github.com/adil192/saber/blob/main/lib/i18n/strings.i18n.json)
   and replace the translations with your own.
   If you don't know the translation for a string, just delete the line.
4. Open a pull request!

Also see [`slang`'s Getting Started](https://pub.dev/packages/slang#getting-started) for more information.

[web_app]: https://adil192.github.io/super_nonogram/
