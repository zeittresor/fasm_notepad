# FASM Notepad

FASM Notepad is a small native Notepad-style text editor for Windows, written entirely in **Flat Assembler (FASM)** and the classic Win32 API.

## Features

- New, Open, Save, Save As, Print, and Exit
- Confirmation before discarding unsaved changes
- File drag and drop from Windows Explorer
- Undo, Cut, Copy, Paste, Delete, and Select All
- Find, Find Next, Replace, and Replace All
- Optional case-sensitive and whole-word search
- Resizable and maximizable main window
- Toggleable word wrap
- Dynamic status line showing:
  - current selected/caret line
  - total character count
  - approximate token count
- Command-line argument for opening a file at startup
- Native Unicode GUI with UTF-16 text internally
- Encoding menu with:
  - UTF-8 without BOM
  - UTF-8 with BOM
  - UTF-16 LE with BOM
  - UTF-16 BE with BOM
  - Windows-1252
  - Windows-1250
  - Windows-1251
  - ISO-8859-1
  - DOS/OEM 437
  - DOS/OEM 850
- BOM detection when opening files
- UTF-8 validation with a Windows-1252 fallback for invalid UTF-8 files
- Warning before saving characters that cannot be represented by a selected legacy code page

## Status line

The status line is updated while typing and when the caret or selection moves.

The token value is intentionally an estimate. It uses the simple approximation of roughly one token per four UTF-16 characters. Actual tokenization depends on the language and tokenizer used by a specific language model.

## Find and replace

Open the Find/Replace window through the **Edit** menu or by using:

- `Ctrl+F` — Find
- `Ctrl+H` — Replace
- `F3` — Find Next

The search wraps to the beginning of the document after reaching the end. Search can optionally match case and restrict results to whole words.

## Printing

Use **File > Print** or `Ctrl+P` to open the standard Windows printer dialog.

Printing uses a fixed-width font, wraps long logical lines to the printable page width, and creates additional pages automatically when required.

## Encoding behavior

The selection under **Encoding** determines:

1. how a file without a BOM is interpreted when it is opened or reloaded;
2. which encoding is used when the current document is saved.

A UTF-8, UTF-16 LE, or UTF-16 BE BOM takes priority when opening a file. Use **Reload file with selected encoding** to reinterpret an already opened file with the selected code page.

## Building

### Recommended method

Run:

```bat
build.cmd
```

The build script searches for a real `fasm.exe` in this order:

1. common locations below `tools\`;
2. recursively below `tools\`;
3. through the `FASM_HOME` environment variable;
4. in the system `PATH`;
5. if FASM is still missing, the bootstrap downloads the official Windows package into `tools\fasm`.

The compiled application is written to:

```text
bin\FasmNotepad.exe
```

To build and immediately launch the program:

```bat
build_and_run.cmd
```

### Downloading FASM manually through the included wrapper

Run:

```bat
get_fasm.cmd
```

Use the CMD wrapper rather than launching `get_fasm.ps1` directly. The wrapper starts a temporary PowerShell process with `ExecutionPolicy Bypass`; it does **not** change the persistent execution policy for the current user or the computer.

After the compiler has been downloaded, run `build.cmd` again. Normally `build.cmd` performs this bootstrap automatically.

### Manual FASM installation

Alternatively, download the official Windows FASM package and extract it so that the project contains a layout similar to:

```text
tools\fasm\fasm.exe
tools\fasm\INCLUDE\win32wx.inc
```

A different nested folder layout is also accepted as long as both files exist somewhere below `tools\`.

### Manual build command

```bat
set INCLUDE=C:\Path\To\FASM\INCLUDE
C:\Path\To\FASM\fasm.exe src\FasmNotepad.asm bin\FasmNotepad.exe
```

The complete FASM `INCLUDE` directory is required, especially `win32wx.inc`.

## Project structure

```text
FasmNotepad\
├─ src\FasmNotepad.asm
├─ bin\
├─ tools\
├─ build.cmd
├─ build_and_run.cmd
├─ clean.cmd
├─ get_fasm.cmd
├─ get_fasm.ps1
├─ LICENSE.txt
└─ README.md
```

## Keyboard shortcuts

| Action | Shortcut |
|---|---|
| New | Ctrl+N |
| Open | Ctrl+O |
| Save | Ctrl+S |
| Save As | Ctrl+Shift+S |
| Print | Ctrl+P |
| Find | Ctrl+F |
| Replace | Ctrl+H |
| Find Next | F3 |
| Undo | Ctrl+Z |
| Cut | Ctrl+X |
| Copy | Ctrl+C |
| Paste | Ctrl+V |
| Select All | Ctrl+A |
| Delete selection | Delete |
| About | F1 |

## Technical notes

- Output format: native 32-bit PE GUI application (`format PE GUI 5.1`).
- Runs on 32-bit Windows and through WoW64 on 64-bit Windows.
- No .NET runtime or external application framework is required.
- The editor uses the native multiline Windows `EDIT` control.
- The main window uses `WS_OVERLAPPEDWINDOW`, so resizing and maximizing are supported by Windows normally.
- File size is limited to 128 MiB as a safety limit for this simple single-buffer editor.
- The compiler is not bundled in the project archive; the bootstrap can download it when required.
