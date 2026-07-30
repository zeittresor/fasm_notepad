# FASM Notepad

FASM Notepad is a small native Windows text editor written in Flat Assembler with the Win32 API. It is intended as a compact, readable Notepad-style application and as a practical FASM GUI example.

## Main features

- Create, open, edit, save, and print plain-text documents.
- Open and save `.txt` and `.md` files, with an additional all-files filter.
- Drag files from Windows Explorer into the editor.
- Find, find next, replace, and replace all.
- Undo, cut, copy, paste, delete, and select all.
- Configurable word wrapping and a standard Windows font selection dialog.
- Change editor text size with `Ctrl` + mouse wheel.
- Status line with the current line, total character count, and an approximate token count.
- Selectable encodings including UTF-8, UTF-16, Windows code pages, ISO-8859-1, and DOS/OEM code pages.
- Light, Dark, Aurora, and Matrix interface themes.
- Resizable and maximizable native Windows window.

Markdown files are edited as plain text; the application does not render Markdown formatting.

## Interface languages

English is the default interface language. The application also includes:

- German
- French
- Portuguese
- Danish
- Ukrainian
- Russian
- Simplified Chinese
- Korean
- Arabic
- Turkish

The language can be changed at runtime from the **Language** menu.

## Building

The project targets 32-bit Windows and also runs on 64-bit Windows through WoW64.

### Normal build

Run:

```bat
build.cmd
```

The script looks for FASM in the project, through `FASM_HOME`, and in `PATH`. If FASM is not available, it can download the official Windows compiler package into `tools\fasm` without changing the system-wide PowerShell execution policy.

The resulting executable is written to:

```text
bin\FasmNotepad.exe
```

### Build and run

```bat
build_and_run.cmd
```

### Clean generated output

```bat
clean.cmd
```

The build requires the standard FASM Windows include files, especially `win32wx.inc`.

## Project structure

```text
src\FasmNotepad.asm       Main application source
src\localization.inc      UTF-16 interface strings
src\assets\               Application icon resources
changelog\                Release history and technical notes
build.cmd                  Compiler discovery and build script
```

## License and source

FASM Notepad is distributed under the MIT License. See `LICENSE.txt`.

Source repository: https://github.com/zeittresor/fasm_notepad
