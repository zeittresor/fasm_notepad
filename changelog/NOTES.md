# Technical Notes

## Interface localization

User-visible strings are stored as UTF-16 code units in `src/localization.inc`. The source representation remains ASCII-safe, so the assembler source file does not depend on a particular editor code page.

Language changes rebuild the native Win32 menu and update the title, status line, About text, messages, file filters, and the find/replace window.

## Themes

The four themes use native `WM_CTLCOLOREDIT`, `WM_CTLCOLORSTATIC`, background brushes, and explicit child-window redraws. Theme changes therefore update the editor and status line immediately.

The native menu receives a theme-specific background brush. Its text, selection highlight, and some control details remain system-drawn to preserve normal Win32 behaviour and readability. Caption, border, and title-text colours are requested through `DwmSetWindowAttribute` when the running Windows version supports those attributes; unsupported systems retain their normal window frame. Common dialogs continue to follow the operating system appearance.

## Font and zoom

The editor font is represented by a Win32 `LOGFONT`. The standard `ChooseFontW` dialog updates it. The edit control is subclassed so `Ctrl` + mouse wheel adjusts `lfHeight` without changing document content.

## File types

The editor remains a plain-text editor. Markdown files are not rendered; `.md` support only provides appropriate open/save filters and filename extension handling.

## Icon

`src/assets/FasmNotepad.ico` is embedded as the executable icon. `src/assets/FasmNotepad_icon.png` is the editable preview/source image included for project maintenance.

## FASM hexadecimal notation

UTF-16 code units are written as hexadecimal literals. Values beginning with the letters A through F require a leading zero in FASM, such as `0D55Ch` instead of `D55Ch`.

