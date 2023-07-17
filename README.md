# Super Nonogram

[<img src='https://github.com/adil192/super_nonogram/blob/main/assets_raw/google-play-badge.png'
    alt='Get it on Google Play'
    height=80>][google_play]
&nbsp;
[<img src='https://github.com/adil192/super_nonogram/blob/main/assets_raw/app-store-badge.svg'
    alt='Download on the App Store'
    height=80>][app_store]
&nbsp;
[<img src='https://github.com/adil192/super_nonogram/blob/main/assets_raw/pwa-badge.png'
    alt='Launch as web app'
    height=80>][web_app]
&nbsp;
[<img src="https://github.com/adil192/super_nonogram/blob/main/assets_raw/windows-badge.png"
    alt="Download for Windows"
    height=80>][download_windows]
&nbsp;
[<img src="https://github.com/adil192/super_nonogram/blob/main/assets_raw/flathub-badge.svg"
    alt="Download on Flathub"
    height=80>][flathub]
&nbsp;
[<img src="https://github.com/adil192/super_nonogram/blob/main/assets_raw/appimage-logo.png"
    alt="Get it as an AppImage"
    height=80>][download_appimage]

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
          "title": "Diese Notiz wurde mit einer neueren Version von Super Nonogram bearbeitet",
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
2. Use [this link](https://github.com/adil192/super_nonogram/new/main/lib/i18n/community)
   to create a new file in `lib/i18n/community/` called `strings_XX.i18n.json`
   where `XX` is your locale code.
3. Copy the contents of an existing file like
   [`lib/i18n/strings.i18n.json`](https://github.com/adil192/super_nonogram/blob/main/lib/i18n/strings.i18n.json)
   and replace the translations with your own.
   If you don't know the translation for a string, just delete the line.
4. Open a pull request!

Also see [`slang`'s Getting Started](https://pub.dev/packages/slang#getting-started) for more information.

[google_play]: https://play.google.com/store/apps/details?id=com.adilhanney.super_nonogram
[app_store]: https://apps.apple.com/gb/app/super-nonogram/id6450968056
[web_app]: https://adil192.github.io/super_nonogram/
[flathub]: https://flathub.org/apps/details/com.adilhanney.super_nonogram
[download_windows]: https://github.com/adil192/super_nonogram/releases/download/v0.7.2/SuperNonogramInstaller_v0.7.2.exe
[download_appimage]: https://github.com/adil192/super_nonogram/releases/download/v0.7.2/SuperNonogram-0.7.2-x86_64.AppImage
