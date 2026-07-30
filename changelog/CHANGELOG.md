# Changelog

## 1.3.2 — 2026-07-30

- Fixed theme changes so the editor and status line repaint immediately without requiring a language switch.
- Added themed native-menu backgrounds and reapplied them after rebuilding the menu for a language change.
- Added optional DWM caption, border, and title-text colours where the Windows version supports those attributes.
- Added explicit redraw handling for the main window, editor, status line, and find/replace dialog.
- Expanded the README with a concise feature overview, supported languages, file handling, and build instructions.
- Updated the About-dialog version and executable metadata to 1.3.2.

## 1.3.1 — 2026-07-30

- Fixed FASM-compatible hexadecimal notation throughout the UTF-16 localization table.
- Added a leading zero to code units whose hexadecimal literal starts with A-F, for example `0D55Ch` and `0FF1Ah`.
- Prevents build failures in the Korean, Chinese, and other non-Latin interface strings.

## 1.3.0 — 2026-07-30

- Added an interface language selector with English as the default.
- Added German, French, Portuguese, Danish, Ukrainian, Russian, Simplified Chinese, Korean, Arabic, and Turkish translations.
- Added Light, Dark, Aurora, and Matrix themes.
- Added the Windows font selection dialog.
- Added editor zoom with `Ctrl` + mouse wheel.
- Added `.txt` and `.md` filters for opening and saving files.
- Added automatic `.txt` or `.md` extension handling based on the selected save filter.
- Added an application icon to the executable and title bar.
- Renamed internal language identifiers to avoid collisions with Win32 language constants.
- Added MIT license and repository information to the About dialog and executable metadata.
- Moved detailed notes and release history out of the README.

## 1.2.2

- Corrected local FASM discovery and first-run compiler bootstrap handling.

## 1.2.1

- Added a project-local replacement for the missing `INVALID_FILE_SIZE` include constant.

## 1.2.0

- Added find and replace, printing, clipboard commands, a status line, and resizable window handling.
