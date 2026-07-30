; -----------------------------------------------------------------------------
; FasmNotepad - a small native Win32 Notepad clone written in FASM
; Target: 32-bit Windows GUI (runs through WoW64 on 64-bit Windows)
; Build:  fasm FasmNotepad.asm FasmNotepad.exe
; Requires the standard FASM INCLUDE directory (win32wx.inc).
; -----------------------------------------------------------------------------

format PE GUI 5.1
entry start

include 'win32wx.inc'

; ----- application constants --------------------------------------------------

APP_VERSION        equ 132
MAX_PATH_CHARS     equ 260
TITLE_CHARS        equ 640
MAX_FILE_BYTES     equ 134217728       ; 128 MiB safety limit for this simple editor
INVALID_FILE_SIZE_VALUE equ 0FFFFFFFFh ; GetFileSize failure sentinel

IDR_ICON           equ 101

UI_LANG_ENGLISH       equ 0
UI_LANG_GERMAN        equ 1
UI_LANG_FRENCH        equ 2
UI_LANG_PORTUGUESE    equ 3
UI_LANG_DANISH        equ 4
UI_LANG_UKRAINIAN     equ 5
UI_LANG_RUSSIAN       equ 6
UI_LANG_CHINESE       equ 7
UI_LANG_KOREAN        equ 8
UI_LANG_ARABIC        equ 9
UI_LANG_TURKISH       equ 10
LANGUAGE_COUNT     equ 11

THEME_LIGHT        equ 0
THEME_DARK         equ 1
THEME_AURORA       equ 2
THEME_MATRIX       equ 3

STR_TOP_FILE                 equ 0
STR_TOP_EDIT                 equ 1
STR_TOP_FORMAT               equ 2
STR_TOP_ENCODING             equ 3
STR_TOP_LANGUAGE             equ 4
STR_TOP_HELP                 equ 5
STR_FILE_NEW                 equ 6
STR_FILE_OPEN                equ 7
STR_FILE_SAVE                equ 8
STR_FILE_SAVE_AS             equ 9
STR_FILE_PRINT               equ 10
STR_FILE_EXIT                equ 11
STR_EDIT_UNDO                equ 12
STR_EDIT_FIND                equ 13
STR_EDIT_FIND_NEXT           equ 14
STR_EDIT_REPLACE             equ 15
STR_EDIT_CUT                 equ 16
STR_EDIT_COPY                equ 17
STR_EDIT_PASTE               equ 18
STR_EDIT_DELETE              equ 19
STR_EDIT_SELECT_ALL          equ 20
STR_FORMAT_WRAP              equ 21
STR_FORMAT_FONT              equ 22
STR_FORMAT_THEME             equ 23
STR_THEME_LIGHT              equ 24
STR_THEME_DARK               equ 25
STR_THEME_AURORA             equ 26
STR_THEME_MATRIX             equ 27
STR_ENC_RELOAD               equ 28
STR_HELP_ABOUT               equ 29
STR_FIND_TITLE               equ 30
STR_FIND_LABEL               equ 31
STR_REPLACE_LABEL            equ 32
STR_MATCH_CASE               equ 33
STR_WHOLE_WORD               equ 34
STR_FIND_NEXT_BTN            equ 35
STR_REPLACE_BTN              equ 36
STR_REPLACE_ALL_BTN          equ 37
STR_CLOSE_BTN                equ 38
STR_STATUS_FORMAT            equ 39
STR_UNTITLED                 equ 40
STR_MSG_FATAL                equ 41
STR_MSG_SAVE                 equ 42
STR_MSG_OPEN                 equ 43
STR_MSG_READ                 equ 44
STR_MSG_WRITE                equ 45
STR_MSG_MEMORY               equ 46
STR_MSG_CONVERSION           equ 47
STR_MSG_TOO_LARGE            equ 48
STR_MSG_LOSSY                equ 49
STR_MSG_ENTER_SEARCH         equ 50
STR_MSG_NOT_FOUND            equ 51
STR_MSG_PRINT                equ 52
STR_ABOUT_TEXT               equ 53
STR_FILE_FILTER              equ 54
STR_REPLACE_ALL_FORMAT       equ 55
STR_MSG_FONT_ERROR           equ 56
LANG_STRING_COUNT  equ 57
IDC_EDITOR         equ 1001
IDC_STATUS         equ 1002

STATUS_HEIGHT      equ 24
STATUS_TIMER_ID    equ 1
STATUS_TIMER_MS    equ 250
SEARCH_TEXT_CHARS  equ 512
STATUS_TEXT_CHARS  equ 256

ID_FILE_NEW        equ 2001
ID_FILE_OPEN       equ 2002
ID_FILE_SAVE       equ 2003
ID_FILE_SAVE_AS    equ 2004
ID_FILE_EXIT       equ 2005
ID_FILE_PRINT      equ 2006

ID_EDIT_UNDO       equ 2101
ID_EDIT_CUT        equ 2102
ID_EDIT_COPY       equ 2103
ID_EDIT_PASTE      equ 2104
ID_EDIT_DELETE     equ 2105
ID_EDIT_SELECT_ALL equ 2106
ID_EDIT_FIND       equ 2107
ID_EDIT_REPLACE    equ 2108
ID_EDIT_FIND_NEXT  equ 2109

ID_FORMAT_WRAP     equ 2201
ID_FORMAT_FONT     equ 2202

ID_THEME_LIGHT     equ 2251
ID_THEME_DARK      equ 2252
ID_THEME_AURORA    equ 2253
ID_THEME_MATRIX    equ 2254

ID_ENC_UTF8        equ 2301
ID_ENC_UTF8_BOM    equ 2302
ID_ENC_UTF16_LE    equ 2303
ID_ENC_UTF16_BE    equ 2304
ID_ENC_CP1252      equ 2305
ID_ENC_CP1250      equ 2306
ID_ENC_CP1251      equ 2307
ID_ENC_ISO8859_1   equ 2308
ID_ENC_CP437       equ 2309
ID_ENC_CP850       equ 2310
ID_ENC_RELOAD      equ 2311

ID_HELP_ABOUT      equ 2401

ID_LANG_ENGLISH    equ 2501
ID_LANG_GERMAN     equ 2502
ID_LANG_FRENCH     equ 2503
ID_LANG_PORTUGUESE equ 2504
ID_LANG_DANISH     equ 2505
ID_LANG_UKRAINIAN  equ 2506
ID_LANG_RUSSIAN    equ 2507
ID_LANG_CHINESE    equ 2508
ID_LANG_KOREAN     equ 2509
ID_LANG_ARABIC     equ 2510
ID_LANG_TURKISH    equ 2511

IDC_FIND_TEXT      equ 3101
IDC_REPLACE_TEXT   equ 3102
IDC_MATCH_CASE     equ 3103
IDC_WHOLE_WORD     equ 3104
IDC_FIND_LABEL     equ 3105
IDC_REPLACE_LABEL  equ 3106
ID_FIND_NEXT       equ 3111
ID_REPLACE_ONE     equ 3112
ID_REPLACE_ALL     equ 3113
ID_FIND_CLOSE      equ 3114

ENC_UTF8           equ 1
ENC_UTF8_BOM       equ 2
ENC_UTF16_LE       equ 3
ENC_UTF16_BE       equ 4
ENC_CP1252         equ 5
ENC_CP1250         equ 6
ENC_CP1251         equ 7
ENC_ISO8859_1      equ 8
ENC_CP437          equ 9
ENC_CP850          equ 10

CP_UTF8_VALUE      equ 65001
CP_1252_VALUE      equ 1252
CP_1250_VALUE      equ 1250
CP_1251_VALUE      equ 1251
CP_ISO8859_1       equ 28591
CP_437_VALUE       equ 437
CP_850_VALUE       equ 850

WC_NO_BEST_FIT_CHARS equ 00000400h
MB_ERR_INVALID_CHARS equ 00000008h

FVIRTKEY_VALUE     equ 01h
FSHIFT_VALUE       equ 04h
FCONTROL_VALUE     equ 08h

WS_EX_CONTROLPARENT_VALUE equ 00010000h
SS_LEFTNOWORDWRAP_VALUE   equ 0000000Ch
BM_GETCHECK_VALUE         equ 00F0h
BST_CHECKED_VALUE         equ 1
BS_AUTOCHECKBOX_VALUE     equ 3
BS_DEFPUSHBUTTON_VALUE    equ 1

LOCALE_USER_DEFAULT_VALUE equ 0400h
NORM_IGNORECASE_VALUE     equ 00000001h
CSTR_EQUAL_VALUE          equ 2

PD_NOSELECTION_VALUE      equ 00000004h
PD_NOPAGENUMS_VALUE       equ 00000008h
PD_RETURNDC_VALUE         equ 00000100h
PD_USEDEVMODECOPIES_VALUE equ 00040000h

HORZRES_VALUE             equ 8
VERTRES_VALUE             equ 10
LOGPIXELSX_VALUE          equ 88
LOGPIXELSY_VALUE          equ 90

DT_WORDBREAK_VALUE        equ 00000010h
DT_EXPANDTABS_VALUE       equ 00000040h
DT_CALCRECT_VALUE         equ 00000400h
DT_NOPREFIX_VALUE         equ 00000800h

GWL_WNDPROC_VALUE          equ -4
MK_CONTROL_VALUE           equ 0008h
WM_MOUSEWHEEL_VALUE        equ 020Ah

MIN_FONT_HEIGHT            equ -72
MAX_FONT_HEIGHT            equ -8
FONT_ZOOM_STEP             equ 2

MIM_BACKGROUND_VALUE       equ 00000002h
MIM_APPLYTOSUBMENUS_VALUE  equ 80000000h
MENUINFO_SIZE_VALUE        equ 28

RDW_INVALIDATE_VALUE       equ 0001h
RDW_ERASE_VALUE            equ 0004h
RDW_ALLCHILDREN_VALUE      equ 0080h
RDW_UPDATENOW_VALUE        equ 0100h
RDW_FRAME_VALUE            equ 0400h
THEME_REDRAW_FLAGS         equ RDW_INVALIDATE_VALUE or RDW_ERASE_VALUE or RDW_ALLCHILDREN_VALUE or RDW_UPDATENOW_VALUE or RDW_FRAME_VALUE

DWMWA_USE_IMMERSIVE_DARK_MODE_OLD equ 19
DWMWA_USE_IMMERSIVE_DARK_MODE     equ 20
DWMWA_BORDER_COLOR                equ 34
DWMWA_CAPTION_COLOR               equ 35
DWMWA_TEXT_COLOR                  equ 36

; ----- program entry ----------------------------------------------------------

section '.text' code readable executable

start:
        invoke  GetModuleHandleW,0
        mov     [hInstance],eax
        mov     [wc.hInstance],eax

        invoke  LoadIconW,[hInstance],IDR_ICON
        test    eax,eax
        jnz     .icon_ready
        invoke  LoadIconW,0,IDI_APPLICATION
.icon_ready:
        mov     [wc.hIcon],eax
        invoke  LoadCursorW,0,IDC_ARROW
        mov     [wc.hCursor],eax

        invoke  RegisterClassW,wc
        test    eax,eax
        jz      fatal_start

        mov     eax,[hInstance]
        mov     [findWc.hInstance],eax
        invoke  LoadCursorW,0,IDC_ARROW
        mov     [findWc.hCursor],eax
        invoke  RegisterClassW,findWc
        test    eax,eax
        jz      fatal_start

        invoke  CreateWindowExW,0,className,initialTitle,WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN,\
                CW_USEDEFAULT,CW_USEDEFAULT,920,680,0,0,[hInstance],0
        test    eax,eax
        jz      fatal_start
        mov     [hWndMain],eax

        call    CreateAccelerators

        invoke  ShowWindow,[hWndMain],SW_SHOWNORMAL
        invoke  UpdateWindow,[hWndMain]

        call    OpenCommandLineFile

.message_loop:
        invoke  GetMessageW,msg,0,0,0
        cmp     eax,0
        jle     .quit

        cmp     dword [hFindReplace],0
        je      .check_accelerator
        invoke  IsWindowVisible,dword [hFindReplace]
        test    eax,eax
        jz      .check_accelerator
        invoke  IsDialogMessageW,dword [hFindReplace],msg
        test    eax,eax
        jnz     .message_loop
        invoke  GetFocus
        test    eax,eax
        jz      .check_accelerator
        mov     ecx,eax
        invoke  IsChild,dword [hFindReplace],ecx
        test    eax,eax
        jnz     .normal_message

.check_accelerator:
        cmp     dword [hAccel],0
        je      .normal_message
        invoke  TranslateAcceleratorW,[hWndMain],dword [hAccel],msg
        test    eax,eax
        jnz     .message_loop

.normal_message:
        invoke  TranslateMessage,msg
        invoke  DispatchMessageW,msg
        jmp     .message_loop

.quit:
        cmp     dword [hAccel],0
        je      .no_accel_cleanup
        invoke  DestroyAcceleratorTable,dword [hAccel]
.no_accel_cleanup:
        mov     eax,[msg.wParam]
        invoke  ExitProcess,eax

fatal_start:
        stdcall ShowLangMessage,0,STR_MSG_FATAL,MB_OK or MB_ICONERROR
        invoke  ExitProcess,1

; ----- main window procedure --------------------------------------------------

proc WindowProc hwnd,wmsg,wparam,lparam
        push    ebx esi edi

        cmp     dword [wmsg],WM_CREATE
        je      .wm_create
        cmp     dword [wmsg],WM_SIZE
        je      .wm_size
        cmp     dword [wmsg],WM_ERASEBKGND
        je      .wm_erase_background
        cmp     dword [wmsg],WM_CTLCOLOREDIT
        je      .wm_color_edit
        cmp     dword [wmsg],WM_CTLCOLORSTATIC
        je      .wm_color_static
        cmp     dword [wmsg],WM_CTLCOLORBTN
        je      .wm_color_button
        cmp     dword [wmsg],WM_SETFOCUS
        je      .wm_setfocus
        cmp     dword [wmsg],WM_COMMAND
        je      .wm_command
        cmp     dword [wmsg],WM_TIMER
        je      .wm_timer
        cmp     dword [wmsg],WM_DROPFILES
        je      .wm_dropfiles
        cmp     dword [wmsg],WM_CLOSE
        je      .wm_close
        cmp     dword [wmsg],WM_DESTROY
        je      .wm_destroy

.default:
        invoke  DefWindowProcW,[hwnd],dword [wmsg],[wparam],[lparam]
        jmp     .finish

.wm_create:
        mov     eax,[hwnd]
        mov     [hWndMain],eax
        call    InitializeEditorFont
        call    CreateApplicationMenu
        call    CreateEditor
        call    CreateStatusLine
        call    ApplyTheme
        call    LayoutControls
        invoke  SetTimer,[hwnd],STATUS_TIMER_ID,STATUS_TIMER_MS,0
        invoke  DragAcceptFiles,[hwnd],TRUE
        call    UpdateEncodingMenu
        call    UpdateTitle
        call    UpdateStatusLine
        xor     eax,eax
        jmp     .finish

.wm_size:
        call    LayoutControls
        jmp     .handled_zero

.wm_erase_background:
        cmp     dword [hThemeBrush],0
        je      .default
        invoke  GetClientRect,[hwnd],clientRect
        invoke  FillRect,[wparam],clientRect,dword [hThemeBrush]
        mov     eax,1
        jmp     .finish

.wm_color_edit:
        invoke  SetTextColor,[wparam],dword [themeTextColor]
        invoke  SetBkColor,[wparam],dword [themeBackColor]
        mov     eax,dword [hThemeBrush]
        jmp     .finish

.wm_color_static:
        mov     eax,[lparam]
        cmp     eax,dword [hStatus]
        jne     .wm_color_edit
        invoke  SetTextColor,[wparam],dword [themeStatusTextColor]
        invoke  SetBkColor,[wparam],dword [themeStatusBackColor]
        mov     eax,dword [hThemeStatusBrush]
        jmp     .finish

.wm_color_button:
        invoke  SetTextColor,[wparam],dword [themeTextColor]
        invoke  SetBkColor,[wparam],dword [themeBackColor]
        mov     eax,dword [hThemeBrush]
        jmp     .finish

.handled_zero:
        xor     eax,eax
        jmp     .finish

.wm_setfocus:
        cmp     dword [hEdit],0
        je      .handled_zero
        invoke  SetFocus,dword [hEdit]
        xor     eax,eax
        jmp     .finish

.wm_command:
        mov     eax,[lparam]
        cmp     eax,dword [hEdit]
        jne     .menu_command

        mov     eax,[wparam]
        shr     eax,16
        cmp     ax,EN_CHANGE
        jne     .menu_command
        cmp     dword [loadingText],0
        jne     .status_only
        cmp     dword [contentModified],1
        je      .status_only
        mov     dword [contentModified],1
        mov     dword [modified],1
        call    UpdateTitle
.status_only:
        call    UpdateStatusLine
        xor     eax,eax
        jmp     .finish

.menu_command:
        mov     eax,[wparam]
        and     eax,0FFFFh

        cmp     eax,ID_FILE_NEW
        je      .cmd_new
        cmp     eax,ID_FILE_OPEN
        je      .cmd_open
        cmp     eax,ID_FILE_SAVE
        je      .cmd_save
        cmp     eax,ID_FILE_SAVE_AS
        je      .cmd_save_as
        cmp     eax,ID_FILE_PRINT
        je      .cmd_print
        cmp     eax,ID_FILE_EXIT
        je      .cmd_exit

        cmp     eax,ID_EDIT_UNDO
        je      .cmd_undo
        cmp     eax,ID_EDIT_CUT
        je      .cmd_cut
        cmp     eax,ID_EDIT_COPY
        je      .cmd_copy
        cmp     eax,ID_EDIT_PASTE
        je      .cmd_paste
        cmp     eax,ID_EDIT_DELETE
        je      .cmd_delete
        cmp     eax,ID_EDIT_SELECT_ALL
        je      .cmd_select_all
        cmp     eax,ID_EDIT_FIND
        je      .cmd_find
        cmp     eax,ID_EDIT_REPLACE
        je      .cmd_replace
        cmp     eax,ID_EDIT_FIND_NEXT
        je      .cmd_find_next

        cmp     eax,ID_FORMAT_WRAP
        je      .cmd_wrap
        cmp     eax,ID_FORMAT_FONT
        je      .cmd_font

        cmp     eax,ID_THEME_LIGHT
        jb      .check_language
        cmp     eax,ID_THEME_MATRIX
        ja      .check_language
        sub     eax,ID_THEME_LIGHT
        mov     dword [currentTheme],eax
        call    ApplyTheme
        jmp     .handled_zero

.check_language:
        cmp     eax,ID_LANG_ENGLISH
        jb      .check_encoding
        cmp     eax,ID_LANG_TURKISH
        ja      .check_encoding
        sub     eax,ID_LANG_ENGLISH
        mov     dword [currentLanguage],eax
        call    ApplyLanguage
        jmp     .handled_zero

.check_encoding:
        cmp     eax,ID_ENC_UTF8
        je      .enc_utf8
        cmp     eax,ID_ENC_UTF8_BOM
        je      .enc_utf8_bom
        cmp     eax,ID_ENC_UTF16_LE
        je      .enc_utf16_le
        cmp     eax,ID_ENC_UTF16_BE
        je      .enc_utf16_be
        cmp     eax,ID_ENC_CP1252
        je      .enc_cp1252
        cmp     eax,ID_ENC_CP1250
        je      .enc_cp1250
        cmp     eax,ID_ENC_CP1251
        je      .enc_cp1251
        cmp     eax,ID_ENC_ISO8859_1
        je      .enc_iso8859_1
        cmp     eax,ID_ENC_CP437
        je      .enc_cp437
        cmp     eax,ID_ENC_CP850
        je      .enc_cp850
        cmp     eax,ID_ENC_RELOAD
        je      .cmd_reload

        cmp     eax,ID_HELP_ABOUT
        je      .cmd_about
        jmp     .handled_zero

.cmd_new:
        call    NewDocument
        jmp     .handled_zero
.cmd_open:
        call    OpenDocumentDialog
        jmp     .handled_zero
.cmd_save:
        call    SaveCurrentDocument
        jmp     .handled_zero
.cmd_save_as:
        call    SaveDocumentAs
        jmp     .handled_zero
.cmd_print:
        call    PrintDocument
        jmp     .handled_zero
.cmd_exit:
        invoke  SendMessageW,[hwnd],WM_CLOSE,0,0
        jmp     .handled_zero

.cmd_undo:
        invoke  SendMessageW,dword [hEdit],WM_UNDO,0,0
        jmp     .handled_zero
.cmd_cut:
        invoke  SendMessageW,dword [hEdit],WM_CUT,0,0
        jmp     .handled_zero
.cmd_copy:
        invoke  SendMessageW,dword [hEdit],WM_COPY,0,0
        jmp     .handled_zero
.cmd_paste:
        invoke  SendMessageW,dword [hEdit],WM_PASTE,0,0
        jmp     .handled_zero
.cmd_delete:
        invoke  SendMessageW,dword [hEdit],EM_REPLACESEL,TRUE,emptyString
        jmp     .handled_zero
.cmd_select_all:
        invoke  SendMessageW,dword [hEdit],EM_SETSEL,0,-1
        jmp     .handled_zero
.cmd_find:
        call    ShowFindReplaceDialog
        jmp     .handled_zero
.cmd_replace:
        call    ShowFindReplaceDialog
        jmp     .handled_zero
.cmd_find_next:
        call    FindNextInDocument
        jmp     .handled_zero
.cmd_wrap:
        call    ToggleWordWrap
        jmp     .handled_zero
.cmd_font:
        call    ChooseEditorFont
        jmp     .handled_zero
.cmd_reload:
        call    ReloadCurrentDocument
        jmp     .handled_zero
.cmd_about:
        stdcall GetLangString,STR_ABOUT_TEXT
        invoke  MessageBoxW,[hwnd],eax,appName,MB_OK or MB_ICONINFORMATION
        jmp     .handled_zero

.enc_utf8:
        mov     dword [currentEncoding],ENC_UTF8
        jmp     .encoding_changed
.enc_utf8_bom:
        mov     dword [currentEncoding],ENC_UTF8_BOM
        jmp     .encoding_changed
.enc_utf16_le:
        mov     dword [currentEncoding],ENC_UTF16_LE
        jmp     .encoding_changed
.enc_utf16_be:
        mov     dword [currentEncoding],ENC_UTF16_BE
        jmp     .encoding_changed
.enc_cp1252:
        mov     dword [currentEncoding],ENC_CP1252
        jmp     .encoding_changed
.enc_cp1250:
        mov     dword [currentEncoding],ENC_CP1250
        jmp     .encoding_changed
.enc_cp1251:
        mov     dword [currentEncoding],ENC_CP1251
        jmp     .encoding_changed
.enc_iso8859_1:
        mov     dword [currentEncoding],ENC_ISO8859_1
        jmp     .encoding_changed
.enc_cp437:
        mov     dword [currentEncoding],ENC_CP437
        jmp     .encoding_changed
.enc_cp850:
        mov     dword [currentEncoding],ENC_CP850
.encoding_changed:
        call    RefreshModifiedState
        call    UpdateEncodingMenu
        call    UpdateTitle
        jmp     .handled_zero

.wm_timer:
        cmp     dword [wparam],STATUS_TIMER_ID
        jne     .handled_zero
        call    UpdateStatusLine
        jmp     .handled_zero

.wm_dropfiles:
        stdcall ConfirmDiscardChanges
        test    eax,eax
        jz      .drop_finish
        invoke  DragQueryFileW,[wparam],0,dropPath,MAX_PATH_CHARS
        test    eax,eax
        jz      .drop_finish
        stdcall LoadFile,dropPath
.drop_finish:
        invoke  DragFinish,[wparam]
        xor     eax,eax
        jmp     .finish

.wm_close:
        stdcall ConfirmDiscardChanges
        test    eax,eax
        jz      .handled_zero
        invoke  DestroyWindow,[hwnd]
        xor     eax,eax
        jmp     .finish

.wm_destroy:
        invoke  KillTimer,[hwnd],STATUS_TIMER_ID
        invoke  DragAcceptFiles,[hwnd],FALSE
        call    CleanupTheme
        cmp     dword [hDwmApi],0
        je      .dwm_clean
        invoke  FreeLibrary,dword [hDwmApi]
        mov     dword [hDwmApi],0
        mov     dword [pDwmSetWindowAttribute],0
.dwm_clean:
        cmp     dword [ownsEditorFont],0
        je      .font_clean
        cmp     dword [hEditorFont],0
        je      .font_clean
        invoke  DeleteObject,dword [hEditorFont]
        mov     dword [hEditorFont],0
.font_clean:
        invoke  PostQuitMessage,0
        xor     eax,eax

.finish:
        pop     edi esi ebx
        ret
endp

; ----- editor and menus -------------------------------------------------------

CreateEditor:
        invoke  GetClientRect,[hWndMain],clientRect

        mov     eax,WS_CHILD or WS_VISIBLE or WS_VSCROLL or ES_MULTILINE or ES_AUTOVSCROLL or ES_NOHIDESEL or ES_WANTRETURN
        cmp     dword [wordWrap],0
        jne     .style_ready
        or      eax,WS_HSCROLL or ES_AUTOHSCROLL
.style_ready:
        mov     [editorStyle],eax

        invoke  CreateWindowExW,WS_EX_CLIENTEDGE,editClass,emptyString,[editorStyle],\
                0,0,[clientRect.right],[clientRect.bottom],[hWndMain],IDC_EDITOR,[hInstance],0
        mov     dword [hEdit],eax
        test    eax,eax
        jz      .done

        cmp     dword [hEditorFont],0
        jne     .font_ready
        call    InitializeEditorFont
.font_ready:
        invoke  SendMessageW,dword [hEdit],WM_SETFONT,dword [hEditorFont],TRUE
        invoke  SendMessageW,dword [hEdit],EM_SETLIMITTEXT,07FFFFFFEh,0
        invoke  SetWindowLongW,dword [hEdit],GWL_WNDPROC_VALUE,EditorProc
        mov     dword [hOldEditProc],eax
.done:
        ret

CreateStatusLine:
        invoke  CreateWindowExW,WS_EX_STATICEDGE,staticClass,emptyString,\
                WS_CHILD or WS_VISIBLE or SS_LEFTNOWORDWRAP_VALUE,0,0,0,STATUS_HEIGHT,\
                [hWndMain],IDC_STATUS,[hInstance],0
        mov     dword [hStatus],eax
        test    eax,eax
        jz      .done
        cmp     dword [hUiFont],0
        jne     .font_ready
        invoke  GetStockObject,DEFAULT_GUI_FONT
        mov     dword [hUiFont],eax
.font_ready:
        invoke  SendMessageW,dword [hStatus],WM_SETFONT,dword [hUiFont],TRUE
.done:
        ret

LayoutControls:
        cmp     dword [hWndMain],0
        je      .done
        invoke  GetClientRect,dword [hWndMain],clientRect
        mov     eax,[clientRect.bottom]
        sub     eax,STATUS_HEIGHT
        jns     .height_ready
        xor     eax,eax
.height_ready:
        mov     dword [layoutEditorHeight],eax
        cmp     dword [hEdit],0
        je      .status
        invoke  MoveWindow,dword [hEdit],0,0,dword [clientRect.right],dword [layoutEditorHeight],TRUE
.status:
        cmp     dword [hStatus],0
        je      .done
        invoke  MoveWindow,dword [hStatus],0,dword [layoutEditorHeight],dword [clientRect.right],STATUS_HEIGHT,TRUE
.done:
        ret


; ----- localization, font, zoom, and themes ----------------------------------

proc GetLangString index
        push    ebx
        mov     eax,dword [currentLanguage]
        cmp     eax,LANGUAGE_COUNT
        jb      .language_ok
        xor     eax,eax
.language_ok:
        mov     ebx,dword [languageTablePointers+eax*4]
        mov     ecx,[index]
        cmp     ecx,LANG_STRING_COUNT
        jb      .index_ok
        xor     ecx,ecx
.index_ok:
        mov     eax,dword [ebx+ecx*4]
        pop     ebx
        ret
endp

proc ShowLangMessage owner,index,flags
        stdcall GetLangString,[index]
        invoke  MessageBoxW,[owner],eax,appName,[flags]
        ret
endp

InitializeEditorFont:
        cmp     dword [hUiFont],0
        jne     .ui_ready
        invoke  GetStockObject,DEFAULT_GUI_FONT
        mov     dword [hUiFont],eax
.ui_ready:
        cmp     dword [hEditorFont],0
        jne     .done
        invoke  GetObjectW,dword [hUiFont],sizeof.LOGFONT,editorLogFont
        test    eax,eax
        jz      .fallback
        cmp     dword [editorLogFont.lfHeight],0
        jne     .create
        mov     dword [editorLogFont.lfHeight],-16
.create:
        invoke  CreateFontIndirectW,editorLogFont
        test    eax,eax
        jz      .fallback
        mov     dword [hEditorFont],eax
        mov     dword [ownsEditorFont],1
        ret
.fallback:
        mov     eax,dword [hUiFont]
        mov     dword [hEditorFont],eax
        mov     dword [ownsEditorFont],0
.done:
        ret

RecreateEditorFont:
        push    ebx esi
        invoke  CreateFontIndirectW,editorLogFont
        test    eax,eax
        jz      .failed
        mov     esi,eax
        mov     ebx,dword [hEditorFont]
        mov     eax,dword [ownsEditorFont]
        mov     dword [oldFontOwned],eax
        mov     dword [hEditorFont],esi
        mov     dword [ownsEditorFont],1
        cmp     dword [hEdit],0
        je      .delete_old
        invoke  SendMessageW,dword [hEdit],WM_SETFONT,esi,TRUE
        invoke  InvalidateRect,dword [hEdit],0,TRUE
.delete_old:
        cmp     dword [oldFontOwned],0
        je      .success
        test    ebx,ebx
        jz      .success
        invoke  DeleteObject,ebx
.success:
        mov     eax,1
        jmp     .finish
.failed:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_FONT_ERROR,MB_OK or MB_ICONERROR
        xor     eax,eax
.finish:
        pop     esi ebx
        ret

ChooseEditorFont:
        mov     dword [fontDialog.lStructSize],sizeof.CHOOSEFONT
        mov     eax,dword [hWndMain]
        mov     dword [fontDialog.hwndOwner],eax
        mov     dword [fontDialog.hDC],0
        mov     dword [fontDialog.lpLogFont],editorLogFont
        mov     dword [fontDialog.iPointSize],0
        mov     dword [fontDialog.Flags],CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT or CF_FORCEFONTEXIST
        mov     dword [fontDialog.rgbColors],0
        mov     dword [fontDialog.lCustData],0
        mov     dword [fontDialog.lpfnHook],0
        mov     dword [fontDialog.lpTemplateName],0
        mov     dword [fontDialog.hInstance],0
        mov     dword [fontDialog.lpszStyle],0
        mov     word [fontDialog.nFontType],0
        mov     word [fontDialog.wReserved],0
        mov     dword [fontDialog.nSizeMin],0
        mov     dword [fontDialog.nSizeMax],0
        invoke  ChooseFontW,fontDialog
        test    eax,eax
        jz      .done
        call    RecreateEditorFont
.done:
        ret

proc AdjustFontZoom direction
        mov     eax,dword [editorLogFont.lfHeight]
        test    eax,eax
        js      .height_ready
        mov     eax,-16
.height_ready:
        cmp     dword [direction],0
        jle     .zoom_out
        sub     eax,FONT_ZOOM_STEP
        cmp     eax,MIN_FONT_HEIGHT
        jge     .set_height
        mov     eax,MIN_FONT_HEIGHT
        jmp     .set_height
.zoom_out:
        add     eax,FONT_ZOOM_STEP
        cmp     eax,MAX_FONT_HEIGHT
        jle     .set_height
        mov     eax,MAX_FONT_HEIGHT
.set_height:
        cmp     eax,dword [editorLogFont.lfHeight]
        je      .done
        mov     dword [editorLogFont.lfHeight],eax
        call    RecreateEditorFont
.done:
        ret
endp

proc EditorProc hwnd,wmsg,wparam,lparam
        cmp     dword [wmsg],WM_MOUSEWHEEL_VALUE
        jne     .default
        mov     eax,[wparam]
        and     eax,0FFFFh
        test    eax,MK_CONTROL_VALUE
        jz      .default
        mov     eax,[wparam]
        sar     eax,16
        test    eax,eax
        jg      .zoom_in
        stdcall AdjustFontZoom,-1
        xor     eax,eax
        ret
.zoom_in:
        stdcall AdjustFontZoom,1
        xor     eax,eax
        ret
.default:
        cmp     dword [hOldEditProc],0
        je      .def_window
        invoke  CallWindowProcW,dword [hOldEditProc],[hwnd],[wmsg],[wparam],[lparam]
        ret
.def_window:
        invoke  DefWindowProcW,[hwnd],[wmsg],[wparam],[lparam]
        ret
endp

CleanupTheme:
        cmp     dword [hThemeBrush],0
        je      .status
        invoke  DeleteObject,dword [hThemeBrush]
        mov     dword [hThemeBrush],0
.status:
        cmp     dword [hThemeStatusBrush],0
        je      .menu
        invoke  DeleteObject,dword [hThemeStatusBrush]
        mov     dword [hThemeStatusBrush],0
.menu:
        cmp     dword [hThemeMenuBrush],0
        je      .done
        invoke  DeleteObject,dword [hThemeMenuBrush]
        mov     dword [hThemeMenuBrush],0
.done:
        ret

EnsureDwmApi:
        cmp     dword [dwmApiChecked],0
        jne     .done
        mov     dword [dwmApiChecked],1
        invoke  LoadLibraryW,dwmApiLibraryName
        mov     dword [hDwmApi],eax
        test    eax,eax
        jz      .done
        invoke  GetProcAddress,eax,dwmSetWindowAttributeName
        mov     dword [pDwmSetWindowAttribute],eax
.done:
        ret

proc ApplyDwmThemeToWindow hwnd
        cmp     dword [hwnd],0
        je      .done
        call    EnsureDwmApi
        cmp     dword [pDwmSetWindowAttribute],0
        je      .done

        mov     dword [dwmDarkModeValue],0
        cmp     dword [currentTheme],THEME_LIGHT
        je      .dark_ready
        mov     dword [dwmDarkModeValue],1
.dark_ready:
        mov     eax,dword [pDwmSetWindowAttribute]
        push    4
        push    dwmDarkModeValue
        push    DWMWA_USE_IMMERSIVE_DARK_MODE
        push    dword [hwnd]
        call    eax

        mov     eax,dword [pDwmSetWindowAttribute]
        push    4
        push    dwmDarkModeValue
        push    DWMWA_USE_IMMERSIVE_DARK_MODE_OLD
        push    dword [hwnd]
        call    eax

        mov     eax,dword [pDwmSetWindowAttribute]
        push    4
        push    themeBorderColor
        push    DWMWA_BORDER_COLOR
        push    dword [hwnd]
        call    eax

        mov     eax,dword [pDwmSetWindowAttribute]
        push    4
        push    themeCaptionColor
        push    DWMWA_CAPTION_COLOR
        push    dword [hwnd]
        call    eax

        mov     eax,dword [pDwmSetWindowAttribute]
        push    4
        push    themeCaptionTextColor
        push    DWMWA_TEXT_COLOR
        push    dword [hwnd]
        call    eax
.done:
        ret
endp

ApplyMenuTheme:
        cmp     dword [hThemeMenuBrush],0
        je      .done
        cmp     dword [hMainMenu],0
        je      .done
        mov     dword [menuInfo.cbSize],MENUINFO_SIZE_VALUE
        mov     dword [menuInfo.fMask],MIM_BACKGROUND_VALUE or MIM_APPLYTOSUBMENUS_VALUE
        mov     eax,dword [hThemeMenuBrush]
        mov     dword [menuInfo.hbrBack],eax
        invoke  SetMenuInfo,dword [hMainMenu],menuInfo
        cmp     dword [hFileMenu],0
        je      .edit
        invoke  SetMenuInfo,dword [hFileMenu],menuInfo
.edit:
        cmp     dword [hEditMenu],0
        je      .format
        invoke  SetMenuInfo,dword [hEditMenu],menuInfo
.format:
        cmp     dword [hFormatMenu],0
        je      .theme
        invoke  SetMenuInfo,dword [hFormatMenu],menuInfo
.theme:
        cmp     dword [hThemeMenu],0
        je      .encoding
        invoke  SetMenuInfo,dword [hThemeMenu],menuInfo
.encoding:
        cmp     dword [hEncodingMenu],0
        je      .language
        invoke  SetMenuInfo,dword [hEncodingMenu],menuInfo
.language:
        cmp     dword [hLanguageMenu],0
        je      .help
        invoke  SetMenuInfo,dword [hLanguageMenu],menuInfo
.help:
        cmp     dword [hHelpMenu],0
        je      .draw
        invoke  SetMenuInfo,dword [hHelpMenu],menuInfo
.draw:
        invoke  DrawMenuBar,dword [hWndMain]
.done:
        ret

RedrawThemeWindows:
        cmp     dword [hEdit],0
        je      .status
        invoke  InvalidateRect,dword [hEdit],0,TRUE
        invoke  UpdateWindow,dword [hEdit]
.status:
        cmp     dword [hStatus],0
        je      .main
        invoke  InvalidateRect,dword [hStatus],0,TRUE
        invoke  UpdateWindow,dword [hStatus]
.main:
        cmp     dword [hWndMain],0
        je      .find
        invoke  RedrawWindow,dword [hWndMain],0,0,THEME_REDRAW_FLAGS
.find:
        cmp     dword [hFindReplace],0
        je      .done
        invoke  RedrawWindow,dword [hFindReplace],0,0,THEME_REDRAW_FLAGS
.done:
        ret

ApplyTheme:
        call    CleanupTheme
        mov     eax,dword [currentTheme]
        cmp     eax,THEME_DARK
        je      .dark
        cmp     eax,THEME_AURORA
        je      .aurora
        cmp     eax,THEME_MATRIX
        je      .matrix
.light:
        mov     dword [themeBackColor],00FFFFFFh
        mov     dword [themeTextColor],00241C18h
        mov     dword [themeStatusBackColor],00F8F4F1h
        mov     dword [themeStatusTextColor],00483A32h
        mov     dword [themeMenuBackColor],00F8F4F1h
        mov     dword [themeBorderColor],00B8AAA2h
        mov     dword [themeCaptionColor],00F8F4F1h
        mov     dword [themeCaptionTextColor],00241C18h
        jmp     .create_brushes
.dark:
        mov     dword [themeBackColor],0028201Eh
        mov     dword [themeTextColor],00F5EEEBh
        mov     dword [themeStatusBackColor],00352A27h
        mov     dword [themeStatusTextColor],00E1D4CEh
        ; Native menus use system text colours. A light neutral background
        ; keeps their labels readable while still distinguishing the theme.
        mov     dword [themeMenuBackColor],00DDD7D3h
        mov     dword [themeBorderColor],00504440h
        mov     dword [themeCaptionColor],00352A27h
        mov     dword [themeCaptionTextColor],00F5EEEBh
        jmp     .create_brushes
.aurora:
        mov     dword [themeBackColor],002B1416h
        mov     dword [themeTextColor],00FFF6E2h
        mov     dword [themeStatusBackColor],00441D25h
        mov     dword [themeStatusTextColor],00E2EE7Bh
        mov     dword [themeMenuBackColor],00E7D8F0h
        mov     dword [themeBorderColor],00724963h
        mov     dword [themeCaptionColor],00441D25h
        mov     dword [themeCaptionTextColor],00FFF6E2h
        jmp     .create_brushes
.matrix:
        mov     dword [themeBackColor],00081200h
        mov     dword [themeTextColor],0080FF4Ah
        mov     dword [themeStatusBackColor],000D1F00h
        mov     dword [themeStatusTextColor],0093FF62h
        mov     dword [themeMenuBackColor],00D2F0CCh
        mov     dword [themeBorderColor],002B6A20h
        mov     dword [themeCaptionColor],000D1F00h
        mov     dword [themeCaptionTextColor],0093FF62h
.create_brushes:
        invoke  CreateSolidBrush,dword [themeBackColor]
        mov     dword [hThemeBrush],eax
        invoke  CreateSolidBrush,dword [themeStatusBackColor]
        mov     dword [hThemeStatusBrush],eax
        invoke  CreateSolidBrush,dword [themeMenuBackColor]
        mov     dword [hThemeMenuBrush],eax

        call    UpdateThemeMenu
        call    ApplyMenuTheme
        stdcall ApplyDwmThemeToWindow,dword [hWndMain]
        cmp     dword [hFindReplace],0
        je      .redraw
        stdcall ApplyDwmThemeToWindow,dword [hFindReplace]
.redraw:
        call    RedrawThemeWindows
        ret

UpdateThemeMenu:
        cmp     dword [hThemeMenu],0
        je      .done
        mov     eax,dword [currentTheme]
        add     eax,ID_THEME_LIGHT
        invoke  CheckMenuRadioItem,dword [hThemeMenu],ID_THEME_LIGHT,ID_THEME_MATRIX,eax,MF_BYCOMMAND
.done:
        ret

UpdateLanguageMenu:
        cmp     dword [hLanguageMenu],0
        je      .done
        mov     eax,dword [currentLanguage]
        add     eax,ID_LANG_ENGLISH
        invoke  CheckMenuRadioItem,dword [hLanguageMenu],ID_LANG_ENGLISH,ID_LANG_TURKISH,eax,MF_BYCOMMAND
.done:
        ret

ApplyLanguage:
        call    RebuildApplicationMenu
        call    UpdateFindReplaceLanguage
        call    UpdateTitle
        call    UpdateStatusLine
        ret

RebuildApplicationMenu:
        cmp     dword [hMainMenu],0
        je      .create
        invoke  SetMenu,dword [hWndMain],0
        invoke  DestroyMenu,dword [hMainMenu]
        mov     dword [hMainMenu],0
        mov     dword [hFileMenu],0
        mov     dword [hEditMenu],0
        mov     dword [hFormatMenu],0
        mov     dword [hThemeMenu],0
        mov     dword [hEncodingMenu],0
        mov     dword [hLanguageMenu],0
        mov     dword [hHelpMenu],0
.create:
        call    CreateApplicationMenu
        ret

UpdateFindReplaceLanguage:
        cmp     dword [hFindReplace],0
        je      .done
        stdcall GetLangString,STR_FIND_TITLE
        invoke  SetWindowTextW,dword [hFindReplace],eax

        invoke  GetDlgItem,dword [hFindReplace],IDC_FIND_LABEL
        mov     ebx,eax
        stdcall GetLangString,STR_FIND_LABEL
        invoke  SetWindowTextW,ebx,eax

        invoke  GetDlgItem,dword [hFindReplace],IDC_REPLACE_LABEL
        mov     ebx,eax
        stdcall GetLangString,STR_REPLACE_LABEL
        invoke  SetWindowTextW,ebx,eax

        stdcall GetLangString,STR_MATCH_CASE
        invoke  SetWindowTextW,dword [hMatchCase],eax
        stdcall GetLangString,STR_WHOLE_WORD
        invoke  SetWindowTextW,dword [hWholeWord],eax

        invoke  GetDlgItem,dword [hFindReplace],ID_FIND_NEXT
        mov     ebx,eax
        stdcall GetLangString,STR_FIND_NEXT_BTN
        invoke  SetWindowTextW,ebx,eax

        invoke  GetDlgItem,dword [hFindReplace],ID_REPLACE_ONE
        mov     ebx,eax
        stdcall GetLangString,STR_REPLACE_BTN
        invoke  SetWindowTextW,ebx,eax

        invoke  GetDlgItem,dword [hFindReplace],ID_REPLACE_ALL
        mov     ebx,eax
        stdcall GetLangString,STR_REPLACE_ALL_BTN
        invoke  SetWindowTextW,ebx,eax

        invoke  GetDlgItem,dword [hFindReplace],ID_FIND_CLOSE
        mov     ebx,eax
        stdcall GetLangString,STR_CLOSE_BTN
        invoke  SetWindowTextW,ebx,eax
.done:
        ret

UpdateStatusLine:
        cmp     dword [hEdit],0
        je      .done
        cmp     dword [hStatus],0
        je      .done
        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [statusCharCount],eax
        add     eax,3
        shr     eax,2
        mov     dword [statusTokenCount],eax
        ; -1 asks the EDIT control for the line containing the active caret.
        invoke  SendMessageW,dword [hEdit],EM_LINEFROMCHAR,-1,0
        inc     eax
        mov     dword [statusLineNumber],eax
        stdcall GetLangString,STR_STATUS_FORMAT
        mov     dword [tmpLangPointer],eax
        cinvoke wsprintfW,statusBuffer,dword [tmpLangPointer],dword [statusLineNumber],dword [statusCharCount],dword [statusTokenCount]
        invoke  SetWindowTextW,dword [hStatus],statusBuffer
.done:
        ret

CreateApplicationMenu:
        invoke  CreateMenu
        mov     dword [hMainMenu],eax

        invoke  CreatePopupMenu
        mov     dword [hFileMenu],eax
        stdcall GetLangString,STR_FILE_NEW
        invoke  AppendMenuW,dword [hFileMenu],MF_STRING,ID_FILE_NEW,eax
        stdcall GetLangString,STR_FILE_OPEN
        invoke  AppendMenuW,dword [hFileMenu],MF_STRING,ID_FILE_OPEN,eax
        stdcall GetLangString,STR_FILE_SAVE
        invoke  AppendMenuW,dword [hFileMenu],MF_STRING,ID_FILE_SAVE,eax
        stdcall GetLangString,STR_FILE_SAVE_AS
        invoke  AppendMenuW,dword [hFileMenu],MF_STRING,ID_FILE_SAVE_AS,eax
        invoke  AppendMenuW,dword [hFileMenu],MF_SEPARATOR,0,0
        stdcall GetLangString,STR_FILE_PRINT
        invoke  AppendMenuW,dword [hFileMenu],MF_STRING,ID_FILE_PRINT,eax
        invoke  AppendMenuW,dword [hFileMenu],MF_SEPARATOR,0,0
        stdcall GetLangString,STR_FILE_EXIT
        invoke  AppendMenuW,dword [hFileMenu],MF_STRING,ID_FILE_EXIT,eax

        invoke  CreatePopupMenu
        mov     dword [hEditMenu],eax
        stdcall GetLangString,STR_EDIT_UNDO
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_UNDO,eax
        invoke  AppendMenuW,dword [hEditMenu],MF_SEPARATOR,0,0
        stdcall GetLangString,STR_EDIT_FIND
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_FIND,eax
        stdcall GetLangString,STR_EDIT_FIND_NEXT
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_FIND_NEXT,eax
        stdcall GetLangString,STR_EDIT_REPLACE
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_REPLACE,eax
        invoke  AppendMenuW,dword [hEditMenu],MF_SEPARATOR,0,0
        stdcall GetLangString,STR_EDIT_CUT
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_CUT,eax
        stdcall GetLangString,STR_EDIT_COPY
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_COPY,eax
        stdcall GetLangString,STR_EDIT_PASTE
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_PASTE,eax
        stdcall GetLangString,STR_EDIT_DELETE
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_DELETE,eax
        invoke  AppendMenuW,dword [hEditMenu],MF_SEPARATOR,0,0
        stdcall GetLangString,STR_EDIT_SELECT_ALL
        invoke  AppendMenuW,dword [hEditMenu],MF_STRING,ID_EDIT_SELECT_ALL,eax

        invoke  CreatePopupMenu
        mov     dword [hFormatMenu],eax
        stdcall GetLangString,STR_FORMAT_WRAP
        invoke  AppendMenuW,dword [hFormatMenu],MF_STRING or MF_CHECKED,ID_FORMAT_WRAP,eax
        stdcall GetLangString,STR_FORMAT_FONT
        invoke  AppendMenuW,dword [hFormatMenu],MF_STRING,ID_FORMAT_FONT,eax
        invoke  AppendMenuW,dword [hFormatMenu],MF_SEPARATOR,0,0

        invoke  CreatePopupMenu
        mov     dword [hThemeMenu],eax
        stdcall GetLangString,STR_THEME_LIGHT
        invoke  AppendMenuW,dword [hThemeMenu],MF_STRING,ID_THEME_LIGHT,eax
        stdcall GetLangString,STR_THEME_DARK
        invoke  AppendMenuW,dword [hThemeMenu],MF_STRING,ID_THEME_DARK,eax
        stdcall GetLangString,STR_THEME_AURORA
        invoke  AppendMenuW,dword [hThemeMenu],MF_STRING,ID_THEME_AURORA,eax
        stdcall GetLangString,STR_THEME_MATRIX
        invoke  AppendMenuW,dword [hThemeMenu],MF_STRING,ID_THEME_MATRIX,eax
        stdcall GetLangString,STR_FORMAT_THEME
        invoke  AppendMenuW,dword [hFormatMenu],MF_POPUP,dword [hThemeMenu],eax

        invoke  CreatePopupMenu
        mov     dword [hEncodingMenu],eax
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_UTF8,menuEncUtf8
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_UTF8_BOM,menuEncUtf8Bom
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_UTF16_LE,menuEncUtf16Le
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_UTF16_BE,menuEncUtf16Be
        invoke  AppendMenuW,dword [hEncodingMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_CP1252,menuEncCp1252
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_CP1250,menuEncCp1250
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_CP1251,menuEncCp1251
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_ISO8859_1,menuEncIso
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_CP437,menuEncCp437
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_CP850,menuEncCp850
        invoke  AppendMenuW,dword [hEncodingMenu],MF_SEPARATOR,0,0
        stdcall GetLangString,STR_ENC_RELOAD
        invoke  AppendMenuW,dword [hEncodingMenu],MF_STRING,ID_ENC_RELOAD,eax

        invoke  CreatePopupMenu
        mov     dword [hLanguageMenu],eax
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_ENGLISH,dword [languageNamePointers+UI_LANG_ENGLISH*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_GERMAN,dword [languageNamePointers+UI_LANG_GERMAN*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_FRENCH,dword [languageNamePointers+UI_LANG_FRENCH*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_PORTUGUESE,dword [languageNamePointers+UI_LANG_PORTUGUESE*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_DANISH,dword [languageNamePointers+UI_LANG_DANISH*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_UKRAINIAN,dword [languageNamePointers+UI_LANG_UKRAINIAN*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_RUSSIAN,dword [languageNamePointers+UI_LANG_RUSSIAN*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_CHINESE,dword [languageNamePointers+UI_LANG_CHINESE*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_KOREAN,dword [languageNamePointers+UI_LANG_KOREAN*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_ARABIC,dword [languageNamePointers+UI_LANG_ARABIC*4]
        invoke  AppendMenuW,dword [hLanguageMenu],MF_STRING,ID_LANG_TURKISH,dword [languageNamePointers+UI_LANG_TURKISH*4]

        invoke  CreatePopupMenu
        mov     dword [hHelpMenu],eax
        stdcall GetLangString,STR_HELP_ABOUT
        invoke  AppendMenuW,dword [hHelpMenu],MF_STRING,ID_HELP_ABOUT,eax

        stdcall GetLangString,STR_TOP_FILE
        invoke  AppendMenuW,dword [hMainMenu],MF_POPUP,dword [hFileMenu],eax
        stdcall GetLangString,STR_TOP_EDIT
        invoke  AppendMenuW,dword [hMainMenu],MF_POPUP,dword [hEditMenu],eax
        stdcall GetLangString,STR_TOP_FORMAT
        invoke  AppendMenuW,dword [hMainMenu],MF_POPUP,dword [hFormatMenu],eax
        stdcall GetLangString,STR_TOP_ENCODING
        invoke  AppendMenuW,dword [hMainMenu],MF_POPUP,dword [hEncodingMenu],eax
        stdcall GetLangString,STR_TOP_LANGUAGE
        invoke  AppendMenuW,dword [hMainMenu],MF_POPUP,dword [hLanguageMenu],eax
        stdcall GetLangString,STR_TOP_HELP
        invoke  AppendMenuW,dword [hMainMenu],MF_POPUP,dword [hHelpMenu],eax

        invoke  SetMenu,dword [hWndMain],dword [hMainMenu]
        call    UpdateEncodingMenu
        call    UpdateLanguageMenu
        call    UpdateThemeMenu
        cmp     dword [wordWrap],0
        je      .wrap_off
        invoke  CheckMenuItem,dword [hFormatMenu],ID_FORMAT_WRAP,MF_BYCOMMAND or MF_CHECKED
        jmp     .draw
.wrap_off:
        invoke  CheckMenuItem,dword [hFormatMenu],ID_FORMAT_WRAP,MF_BYCOMMAND or MF_UNCHECKED
.draw:
        call    ApplyMenuTheme
        invoke  DrawMenuBar,dword [hWndMain]
        ret

CreateAccelerators:
        invoke  CreateAcceleratorTableW,accelerators,ACCELERATOR_COUNT
        mov     dword [hAccel],eax
        ret

ToggleWordWrap:
        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [tmpTextChars],eax
        inc     eax
        shl     eax,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        mov     dword [tmpWideBuffer],eax
        test    eax,eax
        jz      .done

        mov     ecx,dword [tmpTextChars]
        inc     ecx
        invoke  GetWindowTextW,dword [hEdit],dword [tmpWideBuffer],ecx
        invoke  SendMessageW,dword [hEdit],EM_GETSEL,selectionStart,selectionEnd

        xor     dword [wordWrap],1
        invoke  DestroyWindow,dword [hEdit]
        mov     dword [hEdit],0
        call    CreateEditor
        call    LayoutControls

        mov     dword [loadingText],1
        invoke  SetWindowTextW,dword [hEdit],dword [tmpWideBuffer]
        mov     dword [loadingText],0
        invoke  SendMessageW,dword [hEdit],EM_SETSEL,[selectionStart],[selectionEnd]
        invoke  SendMessageW,dword [hEdit],EM_SETMODIFY,dword [contentModified],0
        invoke  SetFocus,dword [hEdit]
        call    UpdateStatusLine

        cmp     dword [wordWrap],0
        je      .wrap_off
        invoke  CheckMenuItem,[hFormatMenu],ID_FORMAT_WRAP,MF_BYCOMMAND or MF_CHECKED
        jmp     .free
.wrap_off:
        invoke  CheckMenuItem,[hFormatMenu],ID_FORMAT_WRAP,MF_BYCOMMAND or MF_UNCHECKED
.free:
        invoke  GlobalFree,dword [tmpWideBuffer]
        mov     dword [tmpWideBuffer],0
.done:
        ret

; ----- find, replace, and printing -------------------------------------------

ShowFindReplaceDialog:
        cmp     dword [hFindReplace],0
        jne     .show_existing
        stdcall GetLangString,STR_FIND_TITLE
        mov     dword [tmpLangPointer],eax
        invoke  CreateWindowExW,WS_EX_TOOLWINDOW or WS_EX_CONTROLPARENT_VALUE,findClassName,dword [tmpLangPointer],\
                WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU,CW_USEDEFAULT,CW_USEDEFAULT,500,245,\
                [hWndMain],0,[hInstance],0
        test    eax,eax
        jz      .done
        mov     dword [hFindReplace],eax
        stdcall ApplyDwmThemeToWindow,eax
.show_existing:
        invoke  ShowWindow,dword [hFindReplace],SW_SHOWNORMAL
        invoke  SetForegroundWindow,dword [hFindReplace]
        invoke  SetFocus,dword [hFindText]
.done:
        ret

proc FindReplaceProc hwnd,wmsg,wparam,lparam
        push    ebx esi edi
        cmp     dword [wmsg],WM_CREATE
        je      .create
        cmp     dword [wmsg],WM_ERASEBKGND
        je      .erase_background
        cmp     dword [wmsg],WM_CTLCOLOREDIT
        je      .color_edit
        cmp     dword [wmsg],WM_CTLCOLORSTATIC
        je      .color_edit
        cmp     dword [wmsg],WM_CTLCOLORBTN
        je      .color_button
        cmp     dword [wmsg],WM_COMMAND
        je      .command
        cmp     dword [wmsg],WM_CLOSE
        je      .close
        cmp     dword [wmsg],WM_DESTROY
        je      .destroy
        invoke  DefWindowProcW,[hwnd],dword [wmsg],[wparam],[lparam]
        jmp     .finish

.erase_background:
        cmp     dword [hThemeBrush],0
        je      .default_message
        invoke  GetClientRect,[hwnd],clientRect
        invoke  FillRect,[wparam],clientRect,dword [hThemeBrush]
        mov     eax,1
        jmp     .finish

.color_edit:
        invoke  SetTextColor,[wparam],dword [themeTextColor]
        invoke  SetBkColor,[wparam],dword [themeBackColor]
        mov     eax,dword [hThemeBrush]
        jmp     .finish

.color_button:
        invoke  SetTextColor,[wparam],dword [themeTextColor]
        invoke  SetBkColor,[wparam],dword [themeBackColor]
        mov     eax,dword [hThemeBrush]
        jmp     .finish

.default_message:
        invoke  DefWindowProcW,[hwnd],dword [wmsg],[wparam],[lparam]
        jmp     .finish

.create:
        mov     eax,[hwnd]
        mov     dword [hFindReplace],eax
        invoke  CreateWindowExW,0,staticClass,emptyString,WS_CHILD or WS_VISIBLE,12,16,92,20,[hwnd],IDC_FIND_LABEL,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE
        invoke  CreateWindowExW,WS_EX_CLIENTEDGE,editClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP or ES_AUTOHSCROLL,\
                108,12,360,25,[hwnd],IDC_FIND_TEXT,[hInstance],0
        mov     dword [hFindText],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE

        invoke  CreateWindowExW,0,staticClass,emptyString,WS_CHILD or WS_VISIBLE,12,53,92,20,[hwnd],IDC_REPLACE_LABEL,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE
        invoke  CreateWindowExW,WS_EX_CLIENTEDGE,editClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP or ES_AUTOHSCROLL,\
                108,49,360,25,[hwnd],IDC_REPLACE_TEXT,[hInstance],0
        mov     dword [hReplaceText],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE

        invoke  CreateWindowExW,0,buttonClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX_VALUE,\
                108,84,135,22,[hwnd],IDC_MATCH_CASE,[hInstance],0
        mov     dword [hMatchCase],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX_VALUE,\
                255,84,150,22,[hwnd],IDC_WHOLE_WORD,[hInstance],0
        mov     dword [hWholeWord],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE

        invoke  CreateWindowExW,0,buttonClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_DEFPUSHBUTTON_VALUE,\
                108,119,110,30,[hwnd],ID_FIND_NEXT,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP,\
                228,119,110,30,[hwnd],ID_REPLACE_ONE,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP,\
                348,119,120,30,[hwnd],ID_REPLACE_ALL,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP,\
                358,160,110,30,[hwnd],ID_FIND_CLOSE,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hUiFont],TRUE
        call    UpdateFindReplaceLanguage
        call    SeedFindTextFromSelection
        xor     eax,eax
        jmp     .finish

.command:
        mov     eax,[wparam]
        and     eax,0FFFFh
        cmp     eax,ID_FIND_NEXT
        je      .find_next
        cmp     eax,ID_REPLACE_ONE
        je      .replace_one
        cmp     eax,ID_REPLACE_ALL
        je      .replace_all
        cmp     eax,ID_FIND_CLOSE
        je      .close
        cmp     eax,IDCANCEL
        je      .close
        xor     eax,eax
        jmp     .finish
.find_next:
        call    FindNextInDocument
        xor     eax,eax
        jmp     .finish
.replace_one:
        call    ReplaceCurrentAndFind
        xor     eax,eax
        jmp     .finish
.replace_all:
        call    ReplaceAllInDocument
        xor     eax,eax
        jmp     .finish
.close:
        invoke  ShowWindow,[hwnd],SW_HIDE
        xor     eax,eax
        jmp     .finish
.destroy:
        mov     dword [hFindReplace],0
        mov     dword [hFindText],0
        mov     dword [hReplaceText],0
        mov     dword [hMatchCase],0
        mov     dword [hWholeWord],0
        xor     eax,eax
.finish:
        pop     edi esi ebx
        ret
endp

SeedFindTextFromSelection:
        cmp     dword [hFindText],0
        je      .done
        invoke  SendMessageW,dword [hEdit],EM_GETSEL,selectionStart,selectionEnd
        mov     eax,dword [selectionEnd]
        sub     eax,dword [selectionStart]
        jbe     .done
        cmp     eax,SEARCH_TEXT_CHARS-1
        ja      .done
        mov     dword [searchNeedleLength],eax
        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [searchTextLength],eax
        inc     eax
        shl     eax,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        mov     dword [tmpSearchBuffer],eax
        test    eax,eax
        jz      .done
        mov     ecx,dword [searchTextLength]
        inc     ecx
        invoke  GetWindowTextW,dword [hEdit],dword [tmpSearchBuffer],ecx
        mov     esi,dword [tmpSearchBuffer]
        mov     eax,dword [selectionStart]
        lea     esi,[esi+eax*2]
        mov     edi,findTextBuffer
        mov     ecx,dword [searchNeedleLength]
        rep     movsw
        mov     word [edi],0
        invoke  SetWindowTextW,dword [hFindText],findTextBuffer
        invoke  GlobalFree,dword [tmpSearchBuffer]
        mov     dword [tmpSearchBuffer],0
.done:
        ret

ReadSearchOptions:
        mov     dword [searchMatchCase],0
        mov     dword [searchWholeWord],0
        cmp     dword [hFindText],0
        je      .from_buffer
        invoke  GetWindowTextW,dword [hFindText],findTextBuffer,SEARCH_TEXT_CHARS
        invoke  GetWindowTextW,dword [hReplaceText],replaceTextBuffer,SEARCH_TEXT_CHARS
        cmp     dword [hMatchCase],0
        je      .whole
        invoke  SendMessageW,dword [hMatchCase],BM_GETCHECK_VALUE,0,0
        cmp     eax,BST_CHECKED_VALUE
        jne     .whole
        mov     dword [searchMatchCase],1
.whole:
        cmp     dword [hWholeWord],0
        je      .lengths
        invoke  SendMessageW,dword [hWholeWord],BM_GETCHECK_VALUE,0,0
        cmp     eax,BST_CHECKED_VALUE
        jne     .lengths
        mov     dword [searchWholeWord],1
        jmp     .lengths
.from_buffer:
.lengths:
        invoke  lstrlenW,findTextBuffer
        mov     dword [searchNeedleLength],eax
        invoke  lstrlenW,replaceTextBuffer
        mov     dword [searchReplacementLength],eax
        ret

proc IsWordChar ch
        mov     eax,[ch]
        cmp     eax,'_'
        je      .yes
        invoke  IsCharAlphaNumericW,eax
        test    eax,eax
        jz      .no
.yes:
        mov     eax,1
        ret
.no:
        xor     eax,eax
        ret
endp

proc MatchAtPosition textPtr,textLen,needlePtr,needleLen,pos
        push    ebx esi edi
        mov     eax,[pos]
        mov     ecx,[needleLen]
        add     ecx,eax
        cmp     ecx,[textLen]
        ja      .no
        mov     esi,[textPtr]
        lea     esi,[esi+eax*2]
        xor     edx,edx
        cmp     dword [searchMatchCase],0
        jne     .compare
        mov     edx,NORM_IGNORECASE_VALUE
.compare:
        invoke  CompareStringW,LOCALE_USER_DEFAULT_VALUE,edx,esi,[needleLen],[needlePtr],[needleLen]
        cmp     eax,CSTR_EQUAL_VALUE
        jne     .no
        cmp     dword [searchWholeWord],0
        je      .yes
        cmp     dword [pos],0
        je      .check_after
        movzx   eax,word [esi-2]
        stdcall IsWordChar,eax
        test    eax,eax
        jnz     .no
.check_after:
        mov     eax,[pos]
        add     eax,[needleLen]
        cmp     eax,[textLen]
        jae     .yes
        mov     ecx,[needleLen]
        movzx   eax,word [esi+ecx*2]
        stdcall IsWordChar,eax
        test    eax,eax
        jnz     .no
.yes:
        mov     eax,1
        jmp     .finish
.no:
        xor     eax,eax
.finish:
        pop     edi esi ebx
        ret
endp

proc FindInRange textPtr,textLen,needlePtr,needleLen,startPos,lastPos
        push    ebx esi edi
        mov     ebx,[startPos]
.loop:
        cmp     ebx,[lastPos]
        ja      .not_found
        stdcall MatchAtPosition,[textPtr],[textLen],[needlePtr],[needleLen],ebx
        test    eax,eax
        jnz     .found
        inc     ebx
        jmp     .loop
.found:
        mov     eax,ebx
        jmp     .finish
.not_found:
        mov     eax,-1
.finish:
        pop     edi esi ebx
        ret
endp

FindNextInDocument:
        call    ReadSearchOptions
        cmp     dword [searchNeedleLength],0
        jne     .have_needle
        call    ShowFindReplaceDialog
        stdcall ShowLangMessage,dword [hFindReplace],STR_MSG_ENTER_SEARCH,MB_OK or MB_ICONINFORMATION
        xor     eax,eax
        ret
.have_needle:
        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [searchTextLength],eax
        mov     ecx,eax
        inc     ecx
        shl     ecx,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,ecx
        mov     dword [tmpSearchBuffer],eax
        test    eax,eax
        jz      .memory_error
        mov     ecx,dword [searchTextLength]
        inc     ecx
        invoke  GetWindowTextW,dword [hEdit],dword [tmpSearchBuffer],ecx
        invoke  SendMessageW,dword [hEdit],EM_GETSEL,selectionStart,selectionEnd
        mov     eax,dword [searchTextLength]
        sub     eax,dword [searchNeedleLength]
        js      .not_found
        mov     dword [searchLastPosition],eax
        mov     ebx,dword [selectionEnd]
        cmp     ebx,eax
        ja      .wrap
        stdcall FindInRange,dword [tmpSearchBuffer],dword [searchTextLength],findTextBuffer,\
                dword [searchNeedleLength],ebx,dword [searchLastPosition]
        cmp     eax,-1
        jne     .found
.wrap:
        cmp     dword [selectionEnd],0
        je      .not_found
        mov     eax,dword [selectionEnd]
        dec     eax
        cmp     eax,dword [searchLastPosition]
        jbe     .wrap_limit_ready
        mov     eax,dword [searchLastPosition]
.wrap_limit_ready:
        stdcall FindInRange,dword [tmpSearchBuffer],dword [searchTextLength],findTextBuffer,\
                dword [searchNeedleLength],0,eax
        cmp     eax,-1
        je      .not_found
.found:
        mov     ebx,eax
        add     eax,dword [searchNeedleLength]
        invoke  SendMessageW,dword [hEdit],EM_SETSEL,ebx,eax
        invoke  SendMessageW,dword [hEdit],EM_SCROLLCARET,0,0
        invoke  SetFocus,dword [hEdit]
        call    FreeSearchBuffer
        call    UpdateStatusLine
        mov     eax,1
        ret
.not_found:
        call    FreeSearchBuffer
        stdcall ShowLangMessage,dword [hFindReplace],STR_MSG_NOT_FOUND,MB_OK or MB_ICONINFORMATION
        xor     eax,eax
        ret
.memory_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_MEMORY,MB_OK or MB_ICONERROR
        xor     eax,eax
        ret

SelectionMatchesFind:
        invoke  SendMessageW,dword [hEdit],EM_GETSEL,selectionStart,selectionEnd
        mov     eax,dword [selectionEnd]
        sub     eax,dword [selectionStart]
        cmp     eax,dword [searchNeedleLength]
        jne     .no
        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [searchTextLength],eax
        inc     eax
        shl     eax,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        mov     dword [tmpSearchBuffer],eax
        test    eax,eax
        jz      .no
        mov     ecx,dword [searchTextLength]
        inc     ecx
        invoke  GetWindowTextW,dword [hEdit],dword [tmpSearchBuffer],ecx
        stdcall MatchAtPosition,dword [tmpSearchBuffer],dword [searchTextLength],findTextBuffer,\
                dword [searchNeedleLength],dword [selectionStart]
        mov     dword [searchTempResult],eax
        call    FreeSearchBuffer
        mov     eax,dword [searchTempResult]
        ret
.no:
        xor     eax,eax
        ret

ReplaceCurrentAndFind:
        call    ReadSearchOptions
        cmp     dword [searchNeedleLength],0
        jne     .check_selection
        stdcall ShowLangMessage,dword [hFindReplace],STR_MSG_ENTER_SEARCH,MB_OK or MB_ICONINFORMATION
        ret
.check_selection:
        call    SelectionMatchesFind
        test    eax,eax
        jz      .find
        invoke  SendMessageW,dword [hEdit],EM_REPLACESEL,TRUE,replaceTextBuffer
.find:
        call    FindNextInDocument
        ret

ReplaceAllInDocument:
        mov     dword [tmpSearchBuffer],0
        mov     dword [tmpReplaceOutput],0
        call    ReadSearchOptions
        cmp     dword [searchNeedleLength],0
        jne     .load_text
        stdcall ShowLangMessage,dword [hFindReplace],STR_MSG_ENTER_SEARCH,MB_OK or MB_ICONINFORMATION
        ret
.load_text:
        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [searchTextLength],eax
        mov     ecx,eax
        inc     ecx
        shl     ecx,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,ecx
        mov     dword [tmpSearchBuffer],eax
        test    eax,eax
        jz      .memory_error
        mov     ecx,dword [searchTextLength]
        inc     ecx
        invoke  GetWindowTextW,dword [hEdit],dword [tmpSearchBuffer],ecx

        mov     dword [replaceMatchCount],0
        mov     eax,dword [searchTextLength]
        cmp     eax,dword [searchNeedleLength]
        jb      .count_done
        xor     ebx,ebx
.count_loop:
        mov     eax,dword [searchTextLength]
        sub     eax,dword [searchNeedleLength]
        cmp     ebx,eax
        ja      .count_done
        stdcall MatchAtPosition,dword [tmpSearchBuffer],dword [searchTextLength],findTextBuffer,\
                dword [searchNeedleLength],ebx
        test    eax,eax
        jz      .count_advance_one
        inc     dword [replaceMatchCount]
        add     ebx,dword [searchNeedleLength]
        jmp     .count_loop
.count_advance_one:
        inc     ebx
        jmp     .count_loop
.count_done:
        cmp     dword [replaceMatchCount],0
        jne     .allocate_output
        call    FreeSearchBuffer
        stdcall ShowLangMessage,dword [hFindReplace],STR_MSG_NOT_FOUND,MB_OK or MB_ICONINFORMATION
        ret
.allocate_output:
        mov     eax,dword [searchReplacementLength]
        cmp     eax,dword [searchNeedleLength]
        jb      .replacement_shorter
        sub     eax,dword [searchNeedleLength]
        imul    eax,dword [replaceMatchCount]
        jo      .memory_error
        add     eax,dword [searchTextLength]
        jc      .memory_error
        jmp     .new_length_ready
.replacement_shorter:
        mov     eax,dword [searchNeedleLength]
        sub     eax,dword [searchReplacementLength]
        imul    eax,dword [replaceMatchCount]
        jo      .memory_error
        cmp     eax,dword [searchTextLength]
        ja      .memory_error
        mov     ecx,dword [searchTextLength]
        sub     ecx,eax
        mov     eax,ecx
.new_length_ready:
        mov     dword [replaceNewLength],eax
        inc     eax
        shl     eax,1
        jc      .memory_error
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        mov     dword [tmpReplaceOutput],eax
        test    eax,eax
        jz      .memory_error

        mov     esi,dword [tmpSearchBuffer]
        mov     edi,dword [tmpReplaceOutput]
        xor     ebx,ebx
.copy_loop:
        cmp     ebx,dword [searchTextLength]
        jae     .copy_done
        mov     eax,dword [searchTextLength]
        sub     eax,dword [searchNeedleLength]
        cmp     ebx,eax
        ja      .copy_one
        stdcall MatchAtPosition,dword [tmpSearchBuffer],dword [searchTextLength],findTextBuffer,\
                dword [searchNeedleLength],ebx
        test    eax,eax
        jz      .copy_one
        push    esi
        mov     esi,replaceTextBuffer
        mov     ecx,dword [searchReplacementLength]
        rep     movsw
        pop     esi
        mov     eax,dword [searchNeedleLength]
        add     ebx,eax
        lea     esi,[esi+eax*2]
        jmp     .copy_loop
.copy_one:
        movsw
        inc     ebx
        jmp     .copy_loop
.copy_done:
        mov     word [edi],0
        mov     dword [loadingText],1
        invoke  SetWindowTextW,dword [hEdit],dword [tmpReplaceOutput]
        mov     dword [loadingText],0
        mov     dword [contentModified],1
        mov     dword [modified],1
        invoke  SendMessageW,dword [hEdit],EM_SETMODIFY,TRUE,0
        invoke  SendMessageW,dword [hEdit],EM_SETSEL,0,0
        call    UpdateTitle
        call    UpdateStatusLine
        stdcall GetLangString,STR_REPLACE_ALL_FORMAT
        mov     dword [tmpLangPointer],eax
        cinvoke wsprintfW,replaceAllMessage,dword [tmpLangPointer],dword [replaceMatchCount]
        invoke  MessageBoxW,dword [hFindReplace],replaceAllMessage,appName,MB_OK or MB_ICONINFORMATION
        call    FreeReplaceBuffers
        ret
.memory_error:
        call    FreeReplaceBuffers
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_MEMORY,MB_OK or MB_ICONERROR
        ret

FreeSearchBuffer:
        cmp     dword [tmpSearchBuffer],0
        je      .done
        invoke  GlobalFree,dword [tmpSearchBuffer]
        mov     dword [tmpSearchBuffer],0
.done:
        ret

FreeReplaceBuffers:
        call    FreeSearchBuffer
        cmp     dword [tmpReplaceOutput],0
        je      .done
        invoke  GlobalFree,dword [tmpReplaceOutput]
        mov     dword [tmpReplaceOutput],0
.done:
        ret

PrintDocument:
        mov     dword [printDC],0
        mov     dword [hPrintFont],0
        mov     dword [hOldPrintFont],0
        mov     dword [tmpPrintBuffer],0
        mov     dword [printDocStarted],0
        mov     dword [printPageStarted],0
        mov     dword [printDialog.lStructSize],sizeof.PRINTDLG
        mov     eax,dword [hWndMain]
        mov     dword [printDialog.hwndOwner],eax
        mov     dword [printDialog.hDevMode],0
        mov     dword [printDialog.hDevNames],0
        mov     dword [printDialog.hDC],0
        mov     dword [printDialog.Flags],PD_RETURNDC_VALUE or PD_NOSELECTION_VALUE or PD_NOPAGENUMS_VALUE or PD_USEDEVMODECOPIES_VALUE
        mov     word [printDialog.nFromPage],1
        mov     word [printDialog.nToPage],1
        mov     word [printDialog.nMinPage],1
        mov     word [printDialog.nMaxPage],1
        mov     word [printDialog.nCopies],1
        mov     dword [printDialog.hInstance],0
        mov     dword [printDialog.lCustData],0
        mov     dword [printDialog.lpfnPrintHook],0
        mov     dword [printDialog.lpfnSetupHook],0
        mov     dword [printDialog.lpPrintTemplateName],0
        mov     dword [printDialog.lpSetupTemplateName],0
        mov     dword [printDialog.hPrintTemplate],0
        mov     dword [printDialog.hSetupTemplate],0
        invoke  PrintDlgW,printDialog
        test    eax,eax
        jz      .cleanup_silent
        mov     eax,dword [printDialog.hDC]
        mov     dword [printDC],eax
        test    eax,eax
        jz      .print_error

        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [printTextLength],eax
        inc     eax
        shl     eax,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        mov     dword [tmpPrintBuffer],eax
        test    eax,eax
        jz      .memory_error
        mov     ecx,dword [printTextLength]
        inc     ecx
        invoke  GetWindowTextW,dword [hEdit],dword [tmpPrintBuffer],ecx

        mov     dword [printDocInfo.cbSize],20
        mov     dword [printDocInfo.lpszDocName],printJobName
        mov     dword [printDocInfo.lpszOutput],0
        mov     dword [printDocInfo.lpszDatatype],0
        mov     dword [printDocInfo.fwType],0
        invoke  StartDocW,dword [printDC],printDocInfo
        test    eax,eax
        jle     .print_error
        mov     dword [printDocStarted],1

        invoke  GetDeviceCaps,dword [printDC],LOGPIXELSY_VALUE
        mov     dword [printDpiY],eax
        invoke  MulDiv,10,eax,72
        mov     dword [printLineHeight],eax
        add     dword [printLineHeight],3
        neg     eax
        invoke  CreateFontW,eax,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,\
                OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FIXED_PITCH or FF_MODERN,printerFontName
        mov     dword [hPrintFont],eax
        test    eax,eax
        jz      .print_error
        invoke  SelectObject,dword [printDC],eax
        mov     dword [hOldPrintFont],eax

        invoke  GetDeviceCaps,dword [printDC],LOGPIXELSX_VALUE
        mov     dword [printDpiX],eax
        mov     ecx,eax
        shl     ecx,1
        add     ecx,eax
        shr     ecx,2
        mov     dword [printMarginX],ecx
        mov     eax,dword [printDpiY]
        mov     ecx,eax
        shl     ecx,1
        add     ecx,eax
        shr     ecx,2
        mov     dword [printMarginY],ecx

        invoke  GetDeviceCaps,dword [printDC],HORZRES_VALUE
        sub     eax,dword [printMarginX]
        mov     dword [printPageRect.right],eax
        mov     eax,dword [printMarginX]
        mov     dword [printPageRect.left],eax
        invoke  GetDeviceCaps,dword [printDC],VERTRES_VALUE
        sub     eax,dword [printMarginY]
        mov     dword [printPageRect.bottom],eax
        mov     eax,dword [printMarginY]
        mov     dword [printPageRect.top],eax

        call    StartPrintPage
        test    eax,eax
        jz      .print_error
        mov     esi,dword [tmpPrintBuffer]
.next_line:
        mov     edi,esi
        xor     ecx,ecx
.scan_line:
        mov     ax,word [edi]
        test    ax,ax
        jz      .line_at_end
        cmp     ax,13
        je      .line_ready
        cmp     ax,10
        je      .line_ready
        add     edi,2
        inc     ecx
        jmp     .scan_line
.line_at_end:
        mov     dword [printAtEnd],1
        jmp     .measure_line
.line_ready:
        mov     dword [printAtEnd],0
.measure_line:
        mov     dword [printLineChars],ecx
        test    ecx,ecx
        jz      .blank_line
        mov     dword [printCalcRect.left],0
        mov     eax,dword [printPageRect.right]
        sub     eax,dword [printPageRect.left]
        mov     dword [printCalcRect.right],eax
        mov     dword [printCalcRect.top],0
        mov     dword [printCalcRect.bottom],0
        invoke  DrawTextW,dword [printDC],esi,ecx,printCalcRect,\
                DT_CALCRECT_VALUE or DT_WORDBREAK_VALUE or DT_EXPANDTABS_VALUE or DT_NOPREFIX_VALUE
        mov     eax,dword [printCalcRect.bottom]
        sub     eax,dword [printCalcRect.top]
        test    eax,eax
        jg      .height_ready
.blank_line:
        mov     eax,dword [printLineHeight]
.height_ready:
        mov     dword [printCurrentLineHeight],eax
        add     eax,dword [printCurrentY]
        cmp     eax,dword [printPageRect.bottom]
        jbe     .draw_line
        invoke  EndPage,dword [printDC]
        mov     dword [printPageStarted],0
        call    StartPrintPage
        test    eax,eax
        jz      .print_error
.draw_line:
        mov     eax,dword [printPageRect.left]
        mov     dword [printDrawRect.left],eax
        mov     eax,dword [printPageRect.right]
        mov     dword [printDrawRect.right],eax
        mov     eax,dword [printCurrentY]
        mov     dword [printDrawRect.top],eax
        mov     eax,dword [printPageRect.bottom]
        mov     dword [printDrawRect.bottom],eax
        cmp     dword [printLineChars],0
        je      .advance_y
        invoke  DrawTextW,dword [printDC],esi,dword [printLineChars],printDrawRect,\
                DT_WORDBREAK_VALUE or DT_EXPANDTABS_VALUE or DT_NOPREFIX_VALUE
.advance_y:
        mov     eax,dword [printCurrentLineHeight]
        add     dword [printCurrentY],eax
        cmp     dword [printAtEnd],1
        je      .finish_pages
        mov     ax,word [edi]
        cmp     ax,13
        jne     .skip_lf
        add     edi,2
        cmp     word [edi],10
        jne     .next_pointer
.skip_lf:
        cmp     word [edi],10
        jne     .next_pointer
        add     edi,2
.next_pointer:
        mov     esi,edi
        jmp     .next_line
.finish_pages:
        cmp     dword [printPageStarted],0
        je      .end_document
        invoke  EndPage,dword [printDC]
        mov     dword [printPageStarted],0
.end_document:
        invoke  EndDoc,dword [printDC]
        mov     dword [printDocStarted],0
        call    CleanupPrintResources
        ret
.memory_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_MEMORY,MB_OK or MB_ICONERROR
        jmp     .abort_cleanup
.print_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_PRINT,MB_OK or MB_ICONERROR
.abort_cleanup:
        cmp     dword [printDocStarted],0
        je      .cleanup_silent
        invoke  AbortDoc,dword [printDC]
        mov     dword [printDocStarted],0
.cleanup_silent:
        call    CleanupPrintResources
        ret

StartPrintPage:
        invoke  StartPage,dword [printDC]
        test    eax,eax
        jle     .fail
        mov     dword [printPageStarted],1
        mov     eax,dword [printPageRect.top]
        mov     dword [printCurrentY],eax
        mov     eax,1
        ret
.fail:
        xor     eax,eax
        ret

CleanupPrintResources:
        cmp     dword [printDC],0
        je      .font
        cmp     dword [hOldPrintFont],0
        je      .font
        invoke  SelectObject,dword [printDC],dword [hOldPrintFont]
        mov     dword [hOldPrintFont],0
.font:
        cmp     dword [hPrintFont],0
        je      .buffer
        invoke  DeleteObject,dword [hPrintFont]
        mov     dword [hPrintFont],0
.buffer:
        cmp     dword [tmpPrintBuffer],0
        je      .dc
        invoke  GlobalFree,dword [tmpPrintBuffer]
        mov     dword [tmpPrintBuffer],0
.dc:
        cmp     dword [printDC],0
        je      .devmode
        invoke  DeleteDC,dword [printDC]
        mov     dword [printDC],0
.devmode:
        cmp     dword [printDialog.hDevMode],0
        je      .devnames
        invoke  GlobalFree,dword [printDialog.hDevMode]
        mov     dword [printDialog.hDevMode],0
.devnames:
        cmp     dword [printDialog.hDevNames],0
        je      .done
        invoke  GlobalFree,dword [printDialog.hDevNames]
        mov     dword [printDialog.hDevNames],0
.done:
        mov     dword [printPageStarted],0
        ret

; ----- document commands -----------------------------------------------------

NewDocument:
        stdcall ConfirmDiscardChanges
        test    eax,eax
        jz      .done

        mov     dword [loadingText],1
        invoke  SetWindowTextW,dword [hEdit],emptyString
        mov     dword [loadingText],0
        mov     word [currentPath],0
        mov     dword [currentEncoding],ENC_UTF8
        mov     dword [savedEncoding],ENC_UTF8
        mov     dword [contentModified],0
        mov     dword [encodingDirty],0
        mov     dword [modified],0
        invoke  SendMessageW,dword [hEdit],EM_SETMODIFY,FALSE,0
        call    UpdateEncodingMenu
        call    UpdateTitle
        call    UpdateStatusLine
.done:
        ret

OpenDocumentDialog:
        stdcall ConfirmDiscardChanges
        test    eax,eax
        jz      .cancel

        mov     word [dialogPath],0
        call    PrepareOpenFileName
        mov     dword [openFileName.Flags],OFN_EXPLORER or OFN_HIDEREADONLY or OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
        invoke  GetOpenFileNameW,openFileName
        test    eax,eax
        jz      .cancel
        stdcall LoadFile,dialogPath
.cancel:
        ret

SaveCurrentDocument:
        cmp     word [currentPath],0
        je      SaveDocumentAs
        stdcall SaveFile,currentPath
        ret

SaveDocumentAs:
        cmp     word [currentPath],0
        je      .empty_name
        invoke  lstrcpyW,dialogPath,currentPath
        jmp     .dialog_ready
.empty_name:
        mov     word [dialogPath],0
.dialog_ready:
        call    PrepareOpenFileName
        mov     dword [openFileName.Flags],OFN_EXPLORER or OFN_HIDEREADONLY or OFN_OVERWRITEPROMPT or OFN_PATHMUSTEXIST
        invoke  GetSaveFileNameW,openFileName
        test    eax,eax
        jz      .cancel
        call    EnsureSaveExtension
        stdcall SaveFile,dialogPath
        ret
.cancel:
        xor     eax,eax
        ret

ReloadCurrentDocument:
        cmp     word [currentPath],0
        je      .done

        ; A pure encoding selection is the purpose of this command and can be
        ; discarded directly. Real text edits still receive the normal prompt.
        cmp     dword [contentModified],0
        je      .reload
        stdcall ConfirmDiscardChanges
        test    eax,eax
        jz      .done
.reload:
        stdcall LoadFile,currentPath
.done:
        ret


EnsureSaveExtension:
        mov     esi,dialogPath
        xor     edi,edi
.scan:
        mov     ax,word [esi]
        test    ax,ax
        jz      .scan_done
        cmp     ax,'\'
        je      .separator
        cmp     ax,'/'
        je      .separator
        cmp     ax,'.'
        jne     .next
        mov     edi,esi
        jmp     .next
.separator:
        xor     edi,edi
.next:
        add     esi,2
        jmp     .scan
.scan_done:
        test    edi,edi
        jnz     .done
        mov     eax,dword [openFileName.nFilterIndex]
        cmp     eax,2
        je      .markdown
        cmp     eax,4
        je      .done
        invoke  lstrcatW,dialogPath,extensionTxt
        ret
.markdown:
        invoke  lstrcatW,dialogPath,extensionMd
.done:
        ret

PrepareOpenFileName:
        mov     dword [openFileName.lStructSize],sizeof.OPENFILENAME
        mov     eax,[hWndMain]
        mov     [openFileName.hwndOwner],eax
        mov     eax,[hInstance]
        mov     [openFileName.hInstance],eax
        stdcall GetLangString,STR_FILE_FILTER
        mov     dword [openFileName.lpstrFilter],eax
        mov     dword [openFileName.lpstrCustomFilter],0
        mov     dword [openFileName.nMaxCustFilter],0
        mov     dword [openFileName.nFilterIndex],1
        mov     dword [openFileName.lpstrFile],dialogPath
        mov     dword [openFileName.nMaxFile],MAX_PATH_CHARS
        mov     dword [openFileName.lpstrFileTitle],0
        mov     dword [openFileName.nMaxFileTitle],0
        mov     dword [openFileName.lpstrInitialDir],0
        mov     dword [openFileName.lpstrTitle],0
        mov     word [openFileName.nFileOffset],0
        mov     word [openFileName.nFileExtension],0
        mov     dword [openFileName.lpstrDefExt],0
        mov     dword [openFileName.lCustData],0
        mov     dword [openFileName.lpfnHook],0
        mov     dword [openFileName.lpTemplateName],0
        ret

proc ConfirmDiscardChanges
        cmp     dword [modified],0
        jne     .ask
        mov     eax,1
        ret
.ask:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_SAVE,MB_YESNOCANCEL or MB_ICONQUESTION
        cmp     eax,IDYES
        je      .save
        cmp     eax,IDNO
        je      .discard
        xor     eax,eax
        ret
.save:
        call    SaveCurrentDocument
        ret
.discard:
        mov     eax,1
        ret
endp

; ----- load and save ----------------------------------------------------------

proc LoadFile,path
        mov     dword [tmpFileHandle],INVALID_HANDLE_VALUE
        mov     dword [tmpFileBuffer],0
        mov     dword [tmpWideBuffer],0

        invoke  CreateFileW,[path],GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
        cmp     eax,INVALID_HANDLE_VALUE
        je      .open_error
        mov     dword [tmpFileHandle],eax

        invoke  GetFileSize,dword [tmpFileHandle],0
        cmp     eax,INVALID_FILE_SIZE_VALUE
        je      .read_error
        cmp     eax,MAX_FILE_BYTES
        ja      .too_large
        mov     [tmpFileSize],eax

        mov     ecx,eax
        add     ecx,4
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,ecx
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpFileBuffer],eax

        invoke  ReadFile,dword [tmpFileHandle],dword [tmpFileBuffer],[tmpFileSize],tmpBytesRead,0
        test    eax,eax
        jz      .read_error
        invoke  CloseHandle,dword [tmpFileHandle]
        mov     dword [tmpFileHandle],INVALID_HANDLE_VALUE

        mov     eax,[tmpBytesRead]
        mov     dword [tmpSourceLength],eax
        mov     eax,dword [tmpFileBuffer]
        mov     dword [tmpSourcePointer],eax
        mov     eax,dword [currentEncoding]
        mov     dword [tmpDetectedEncoding],eax

        cmp     dword [tmpSourceLength],3
        jb      .check_utf16_bom
        mov     esi,dword [tmpSourcePointer]
        cmp     byte [esi],0EFh
        jne     .check_utf16_bom
        cmp     byte [esi+1],0BBh
        jne     .check_utf16_bom
        cmp     byte [esi+2],0BFh
        jne     .check_utf16_bom
        add     dword [tmpSourcePointer],3
        sub     dword [tmpSourceLength],3
        mov     dword [tmpDetectedEncoding],ENC_UTF8_BOM
        jmp     .convert_multibyte

.check_utf16_bom:
        cmp     dword [tmpSourceLength],2
        jb      .no_bom
        mov     esi,dword [tmpSourcePointer]
        cmp     byte [esi],0FFh
        jne     .check_utf16_be_bom
        cmp     byte [esi+1],0FEh
        jne     .check_utf16_be_bom
        add     dword [tmpSourcePointer],2
        sub     dword [tmpSourceLength],2
        mov     dword [tmpDetectedEncoding],ENC_UTF16_LE
        jmp     .convert_utf16_le

.check_utf16_be_bom:
        cmp     byte [esi],0FEh
        jne     .no_bom
        cmp     byte [esi+1],0FFh
        jne     .no_bom
        add     dword [tmpSourcePointer],2
        sub     dword [tmpSourceLength],2
        mov     dword [tmpDetectedEncoding],ENC_UTF16_BE
        jmp     .convert_utf16_be

.no_bom:
        mov     eax,dword [currentEncoding]
        cmp     eax,ENC_UTF16_LE
        je      .convert_utf16_le
        cmp     eax,ENC_UTF16_BE
        je      .convert_utf16_be
        jmp     .convert_multibyte

.convert_utf16_le:
        mov     eax,dword [tmpSourceLength]
        test    eax,1
        jnz     .conversion_error
        add     eax,2
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpWideBuffer],eax

        mov     edi,eax
        mov     esi,dword [tmpSourcePointer]
        mov     ecx,dword [tmpSourceLength]
        rep     movsb
        jmp     .show_text

.convert_utf16_be:
        mov     eax,dword [tmpSourceLength]
        test    eax,1
        jnz     .conversion_error
        add     eax,2
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpWideBuffer],eax

        mov     esi,dword [tmpSourcePointer]
        mov     edi,dword [tmpWideBuffer]
        mov     ecx,dword [tmpSourceLength]
        shr     ecx,1
.be_loop:
        test    ecx,ecx
        jz      .show_text
        mov     al,[esi]
        mov     ah,[esi+1]
        mov     [edi],ah
        mov     [edi+1],al
        add     esi,2
        add     edi,2
        dec     ecx
        jmp     .be_loop

.convert_multibyte:
        call    GetSelectedCodePage
        mov     dword [tmpCodePage],eax

        cmp     dword [tmpSourceLength],0
        jne     .measure_mb
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,2
        mov     dword [tmpWideBuffer],eax
        test    eax,eax
        jz      .memory_error
        jmp     .show_text

.measure_mb:
        mov     dword [tmpMbFlags],0
        cmp     dword [tmpCodePage],CP_UTF8_VALUE
        jne     .measure_call
        mov     dword [tmpMbFlags],MB_ERR_INVALID_CHARS
.measure_call:
        invoke  MultiByteToWideChar,dword [tmpCodePage],dword [tmpMbFlags],dword [tmpSourcePointer],dword [tmpSourceLength],0,0
        test    eax,eax
        jnz     .mb_count_ok

        cmp     dword [tmpCodePage],CP_UTF8_VALUE
        jne     .conversion_error
        mov     dword [tmpCodePage],CP_1252_VALUE
        mov     dword [tmpDetectedEncoding],ENC_CP1252
        mov     dword [tmpMbFlags],0
        invoke  MultiByteToWideChar,dword [tmpCodePage],0,dword [tmpSourcePointer],dword [tmpSourceLength],0,0
        test    eax,eax
        jz      .conversion_error

.mb_count_ok:
        mov     dword [tmpTextChars],eax
        inc     eax
        shl     eax,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpWideBuffer],eax

        invoke  MultiByteToWideChar,dword [tmpCodePage],0,dword [tmpSourcePointer],dword [tmpSourceLength],\
                dword [tmpWideBuffer],dword [tmpTextChars]
        test    eax,eax
        jz      .conversion_error

.show_text:
        mov     dword [loadingText],1
        invoke  SetWindowTextW,dword [hEdit],dword [tmpWideBuffer]
        mov     dword [loadingText],0
        invoke  SendMessageW,dword [hEdit],EM_SETMODIFY,FALSE,0

        invoke  lstrcpyW,currentPath,[path]
        mov     eax,dword [tmpDetectedEncoding]
        mov     dword [currentEncoding],eax
        mov     dword [savedEncoding],eax
        mov     dword [contentModified],0
        mov     dword [encodingDirty],0
        mov     dword [modified],0
        call    UpdateEncodingMenu
        call    UpdateTitle
        call    UpdateStatusLine
        invoke  SetFocus,dword [hEdit]

        call    FreeLoadBuffers
        mov     eax,1
        ret

.too_large:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_TOO_LARGE,MB_OK or MB_ICONWARNING
        jmp     .failure_cleanup
.open_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_OPEN,MB_OK or MB_ICONERROR
        jmp     .failure_cleanup
.read_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_READ,MB_OK or MB_ICONERROR
        jmp     .failure_cleanup
.memory_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_MEMORY,MB_OK or MB_ICONERROR
        jmp     .failure_cleanup
.conversion_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_CONVERSION,MB_OK or MB_ICONERROR
.failure_cleanup:
        call    FreeLoadBuffers
        xor     eax,eax
        ret
endp

FreeLoadBuffers:
        cmp     dword [tmpFileHandle],INVALID_HANDLE_VALUE
        je      .no_handle
        invoke  CloseHandle,dword [tmpFileHandle]
        mov     dword [tmpFileHandle],INVALID_HANDLE_VALUE
.no_handle:
        cmp     dword [tmpFileBuffer],0
        je      .no_file_buffer
        invoke  GlobalFree,dword [tmpFileBuffer]
        mov     dword [tmpFileBuffer],0
.no_file_buffer:
        cmp     dword [tmpWideBuffer],0
        je      .done
        invoke  GlobalFree,dword [tmpWideBuffer]
        mov     dword [tmpWideBuffer],0
.done:
        ret

proc SaveFile,path
        mov     eax,dword [currentEncoding]
        mov     dword [tmpDetectedEncoding],eax
        mov     dword [tmpWideBuffer],0
        mov     dword [tmpOutputBuffer],0
        mov     dword [tmpFileHandle],INVALID_HANDLE_VALUE
        mov     dword [tmpOutputSize],0
        mov     dword [tmpUsedDefault],0

        invoke  GetWindowTextLengthW,dword [hEdit]
        mov     dword [tmpTextChars],eax
        inc     eax
        shl     eax,1
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpWideBuffer],eax

        mov     ecx,dword [tmpTextChars]
        inc     ecx
        invoke  GetWindowTextW,dword [hEdit],dword [tmpWideBuffer],ecx

        mov     eax,dword [currentEncoding]
        cmp     eax,ENC_UTF16_LE
        je      .prepare_utf16_le
        cmp     eax,ENC_UTF16_BE
        je      .prepare_utf16_be
        jmp     .prepare_multibyte

.prepare_utf16_le:
        mov     eax,dword [tmpTextChars]
        shl     eax,1
        add     eax,2
        mov     dword [tmpOutputSize],eax
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpOutputBuffer],eax
        mov     word [eax],0FEFFh
        lea     edi,[eax+2]
        mov     esi,dword [tmpWideBuffer]
        mov     ecx,dword [tmpTextChars]
        shl     ecx,1
        rep     movsb
        jmp     .write_output

.prepare_utf16_be:
        mov     eax,dword [tmpTextChars]
        shl     eax,1
        add     eax,2
        mov     dword [tmpOutputSize],eax
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpOutputBuffer],eax
        mov     byte [eax],0FEh
        mov     byte [eax+1],0FFh

        mov     esi,dword [tmpWideBuffer]
        lea     edi,[eax+2]
        mov     ecx,dword [tmpTextChars]
.save_be_loop:
        test    ecx,ecx
        jz      .write_output
        mov     al,[esi]
        mov     ah,[esi+1]
        mov     [edi],ah
        mov     [edi+1],al
        add     esi,2
        add     edi,2
        dec     ecx
        jmp     .save_be_loop

.prepare_multibyte:
        call    GetSelectedCodePage
        mov     dword [tmpCodePage],eax
        mov     dword [tmpPrefixSize],0
        cmp     dword [currentEncoding],ENC_UTF8_BOM
        jne     .measure_output
        mov     dword [tmpPrefixSize],3

.measure_output:
        cmp     dword [tmpTextChars],0
        jne     .measure_nonempty
        mov     eax,dword [tmpPrefixSize]
        cmp     eax,0
        jne     .allocate_output
        mov     eax,1
        jmp     .allocate_output_minimum

.measure_nonempty:
        cmp     dword [tmpCodePage],CP_UTF8_VALUE
        jne     .measure_legacy
        invoke  WideCharToMultiByte,dword [tmpCodePage],0,dword [tmpWideBuffer],dword [tmpTextChars],0,0,0,0
        jmp     .measured
.measure_legacy:
        mov     dword [tmpUsedDefault],0
        invoke  WideCharToMultiByte,dword [tmpCodePage],WC_NO_BEST_FIT_CHARS,dword [tmpWideBuffer],dword [tmpTextChars],\
                0,0,0,tmpUsedDefault
.measured:
        test    eax,eax
        jz      .conversion_error
        add     eax,dword [tmpPrefixSize]
.allocate_output:
        mov     dword [tmpOutputSize],eax
.allocate_output_minimum:
        invoke  GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
        test    eax,eax
        jz      .memory_error
        mov     dword [tmpOutputBuffer],eax

        cmp     dword [tmpPrefixSize],3
        jne     .convert_output
        mov     byte [eax],0EFh
        mov     byte [eax+1],0BBh
        mov     byte [eax+2],0BFh

.convert_output:
        cmp     dword [tmpTextChars],0
        je      .legacy_warning
        mov     edi,dword [tmpOutputBuffer]
        add     edi,dword [tmpPrefixSize]
        mov     eax,dword [tmpOutputSize]
        sub     eax,dword [tmpPrefixSize]
        mov     [tmpPayloadSize],eax

        cmp     dword [tmpCodePage],CP_UTF8_VALUE
        jne     .convert_legacy
        invoke  WideCharToMultiByte,dword [tmpCodePage],0,dword [tmpWideBuffer],dword [tmpTextChars],edi,[tmpPayloadSize],0,0
        test    eax,eax
        jz      .conversion_error
        jmp     .write_output

.convert_legacy:
        mov     dword [tmpUsedDefault],0
        invoke  WideCharToMultiByte,dword [tmpCodePage],WC_NO_BEST_FIT_CHARS,dword [tmpWideBuffer],dword [tmpTextChars],\
                edi,[tmpPayloadSize],0,tmpUsedDefault
        test    eax,eax
        jz      .conversion_error

.legacy_warning:
        cmp     dword [tmpUsedDefault],0
        je      .write_output
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_LOSSY,MB_YESNO or MB_ICONWARNING or MB_DEFBUTTON2
        cmp     eax,IDYES
        jne     .cancel

.write_output:
        invoke  CreateFileW,[path],GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
        cmp     eax,INVALID_HANDLE_VALUE
        je      .write_error
        mov     dword [tmpFileHandle],eax

        cmp     dword [tmpOutputSize],0
        je      .write_success
        invoke  WriteFile,dword [tmpFileHandle],dword [tmpOutputBuffer],dword [tmpOutputSize],tmpBytesWritten,0
        test    eax,eax
        jz      .write_error
        mov     eax,[tmpBytesWritten]
        cmp     eax,dword [tmpOutputSize]
        jne     .write_error

.write_success:
        invoke  CloseHandle,dword [tmpFileHandle]
        mov     dword [tmpFileHandle],INVALID_HANDLE_VALUE
        invoke  lstrcpyW,currentPath,[path]
        mov     eax,dword [currentEncoding]
        mov     dword [savedEncoding],eax
        mov     dword [contentModified],0
        mov     dword [encodingDirty],0
        mov     dword [modified],0
        invoke  SendMessageW,dword [hEdit],EM_SETMODIFY,FALSE,0
        call    UpdateTitle
        call    UpdateStatusLine
        call    FreeSaveBuffers
        mov     eax,1
        ret

.write_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_WRITE,MB_OK or MB_ICONERROR
        jmp     .failure
.memory_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_MEMORY,MB_OK or MB_ICONERROR
        jmp     .failure
.conversion_error:
        stdcall ShowLangMessage,dword [hWndMain],STR_MSG_CONVERSION,MB_OK or MB_ICONERROR
        jmp     .failure
.cancel:
.failure:
        call    FreeSaveBuffers
        xor     eax,eax
        ret
endp

FreeSaveBuffers:
        cmp     dword [tmpFileHandle],INVALID_HANDLE_VALUE
        je      .no_handle
        invoke  CloseHandle,dword [tmpFileHandle]
        mov     dword [tmpFileHandle],INVALID_HANDLE_VALUE
.no_handle:
        cmp     dword [tmpWideBuffer],0
        je      .no_wide
        invoke  GlobalFree,dword [tmpWideBuffer]
        mov     dword [tmpWideBuffer],0
.no_wide:
        cmp     dword [tmpOutputBuffer],0
        je      .done
        invoke  GlobalFree,dword [tmpOutputBuffer]
        mov     dword [tmpOutputBuffer],0
.done:
        ret

; ----- encoding helpers ------------------------------------------------------

GetSelectedCodePage:
        mov     eax,dword [tmpDetectedEncoding]
        cmp     eax,ENC_UTF8_BOM
        je      .utf8
        cmp     eax,ENC_UTF8
        je      .utf8
        cmp     eax,ENC_CP1252
        je      .cp1252
        cmp     eax,ENC_CP1250
        je      .cp1250
        cmp     eax,ENC_CP1251
        je      .cp1251
        cmp     eax,ENC_ISO8859_1
        je      .iso
        cmp     eax,ENC_CP437
        je      .cp437
        cmp     eax,ENC_CP850
        je      .cp850

        ; Defensive fallback for callers that have not staged an encoding.
        mov     eax,dword [currentEncoding]
        cmp     eax,ENC_UTF8_BOM
        je      .utf8
        cmp     eax,ENC_UTF8
        je      .utf8
        cmp     eax,ENC_CP1252
        je      .cp1252
        cmp     eax,ENC_CP1250
        je      .cp1250
        cmp     eax,ENC_CP1251
        je      .cp1251
        cmp     eax,ENC_ISO8859_1
        je      .iso
        cmp     eax,ENC_CP437
        je      .cp437
        cmp     eax,ENC_CP850
        je      .cp850
.utf8:
        mov     eax,CP_UTF8_VALUE
        ret
.cp1252:
        mov     eax,CP_1252_VALUE
        ret
.cp1250:
        mov     eax,CP_1250_VALUE
        ret
.cp1251:
        mov     eax,CP_1251_VALUE
        ret
.iso:
        mov     eax,CP_ISO8859_1
        ret
.cp437:
        mov     eax,CP_437_VALUE
        ret
.cp850:
        mov     eax,CP_850_VALUE
        ret

RefreshModifiedState:
        ; On a completely empty untitled document, choosing the initial
        ; encoding is a preference, not a reason to ask for an empty save.
        cmp     dword [contentModified],0
        jne     .compare_encoding
        cmp     word [currentPath],0
        jne     .compare_encoding
        invoke  GetWindowTextLengthW,dword [hEdit]
        test    eax,eax
        jnz     .compare_encoding
        mov     eax,dword [currentEncoding]
        mov     dword [savedEncoding],eax
        mov     dword [encodingDirty],0
        mov     dword [modified],0
        ret
.compare_encoding:
        mov     eax,dword [currentEncoding]
        cmp     eax,dword [savedEncoding]
        jne     .encoding_changed
        mov     dword [encodingDirty],0
        jmp     .combine
.encoding_changed:
        mov     dword [encodingDirty],1
.combine:
        cmp     dword [contentModified],0
        jne     .dirty
        cmp     dword [encodingDirty],0
        jne     .dirty
        mov     dword [modified],0
        ret
.dirty:
        mov     dword [modified],1
        ret

UpdateEncodingMenu:
        mov     eax,dword [currentEncoding]
        add     eax,ID_ENC_UTF8-ENC_UTF8
        invoke  CheckMenuRadioItem,[hEncodingMenu],ID_ENC_UTF8,ID_ENC_CP850,eax,MF_BYCOMMAND
        ret

GetEncodingName:
        mov     eax,dword [currentEncoding]
        cmp     eax,ENC_UTF8
        je      .utf8
        cmp     eax,ENC_UTF8_BOM
        je      .utf8bom
        cmp     eax,ENC_UTF16_LE
        je      .utf16le
        cmp     eax,ENC_UTF16_BE
        je      .utf16be
        cmp     eax,ENC_CP1252
        je      .cp1252
        cmp     eax,ENC_CP1250
        je      .cp1250
        cmp     eax,ENC_CP1251
        je      .cp1251
        cmp     eax,ENC_ISO8859_1
        je      .iso
        cmp     eax,ENC_CP437
        je      .cp437
        cmp     eax,ENC_CP850
        je      .cp850
.utf8:
        mov     eax,encNameUtf8
        ret
.utf8bom:
        mov     eax,encNameUtf8Bom
        ret
.utf16le:
        mov     eax,encNameUtf16Le
        ret
.utf16be:
        mov     eax,encNameUtf16Be
        ret
.cp1252:
        mov     eax,encNameCp1252
        ret
.cp1250:
        mov     eax,encNameCp1250
        ret
.cp1251:
        mov     eax,encNameCp1251
        ret
.iso:
        mov     eax,encNameIso
        ret
.cp437:
        mov     eax,encNameCp437
        ret
.cp850:
        mov     eax,encNameCp850
        ret

; ----- title and command-line helpers ----------------------------------------

UpdateTitle:
        cmp     word [currentPath],0
        jne     .has_path
        stdcall GetLangString,STR_UNTITLED
        invoke  lstrcpyW,titleBuffer,eax
        jmp     .base_ready
.has_path:
        invoke  lstrcpyW,titleBuffer,currentPath
.base_ready:
        cmp     dword [modified],0
        je      .not_modified
        invoke  lstrcatW,titleBuffer,modifiedSuffix
.not_modified:
        invoke  lstrcatW,titleBuffer,titleSeparator
        call    GetEncodingName
        invoke  lstrcatW,titleBuffer,eax
        invoke  lstrcatW,titleBuffer,titleEnd
        invoke  SetWindowTextW,[hWndMain],titleBuffer
        ret

OpenCommandLineFile:
        invoke  GetCommandLineW
        invoke  CommandLineToArgvW,eax,commandLineArgc
        test    eax,eax
        jz      .done
        mov     dword [commandLineArgv],eax
        cmp     dword [commandLineArgc],2
        jb      .free
        mov     edx,[eax+4]
        stdcall LoadFile,edx
.free:
        invoke  LocalFree,dword [commandLineArgv]
        mov     dword [commandLineArgv],0
.done:
        ret

; ----- data ------------------------------------------------------------------

section '.data' data readable writeable

hInstance          dd 0
hWndMain           dd 0
hEdit              dd 0
hStatus            dd 0
hEditorFont        dd 0
hUiFont            dd 0
hOldEditProc       dd 0
ownsEditorFont     dd 0
oldFontOwned       dd 0
hThemeBrush        dd 0
hThemeStatusBrush  dd 0
hThemeMenuBrush    dd 0
hFindReplace       dd 0
hFindText          dd 0
hReplaceText       dd 0
hMatchCase         dd 0
hWholeWord         dd 0
hMainMenu          dd 0
hFileMenu          dd 0
hEditMenu          dd 0
hFormatMenu        dd 0
hThemeMenu         dd 0
hEncodingMenu      dd 0
hLanguageMenu      dd 0
hHelpMenu          dd 0
hAccel             dd 0
hDwmApi            dd 0
pDwmSetWindowAttribute dd 0
dwmApiChecked      dd 0
dwmDarkModeValue   dd 0

modified           dd 0
contentModified    dd 0
encodingDirty      dd 0
loadingText        dd 0
wordWrap           dd 1
currentLanguage    dd UI_LANG_ENGLISH
currentTheme       dd THEME_LIGHT
currentEncoding    dd ENC_UTF8
savedEncoding      dd ENC_UTF8
editorStyle        dd 0
selectionStart     dd 0
selectionEnd       dd 0
layoutEditorHeight dd 0

themeBackColor       dd 00FFFFFFh
themeTextColor       dd 00241C18h
themeStatusBackColor dd 00F8F4F1h
themeStatusTextColor dd 00483A32h
themeMenuBackColor  dd 00F8F4F1h
themeBorderColor    dd 00B8AAA2h
themeCaptionColor   dd 00F8F4F1h
themeCaptionTextColor dd 00241C18h

statusCharCount    dd 0
statusTokenCount   dd 0
statusLineNumber   dd 1
statusSelectionStart dd 0
statusSelectionEnd dd 0

searchMatchCase    dd 0
searchWholeWord    dd 0
searchNeedleLength dd 0
searchReplacementLength dd 0
searchTextLength   dd 0
searchLastPosition dd 0
searchTempResult   dd 0
replaceMatchCount  dd 0
replaceNewLength   dd 0

printDC            dd 0
hPrintFont         dd 0
hOldPrintFont      dd 0
printDocStarted    dd 0
printPageStarted   dd 0
printTextLength    dd 0
printDpiX          dd 0
printDpiY          dd 0
printMarginX       dd 0
printMarginY       dd 0
printLineHeight    dd 0
printCurrentLineHeight dd 0
printCurrentY      dd 0
printLineChars     dd 0
printAtEnd         dd 0

commandLineArgc    dd 0
commandLineArgv    dd 0

; temporary working storage (single-threaded application)
tmpFileHandle      dd INVALID_HANDLE_VALUE
tmpFileBuffer      dd 0
tmpWideBuffer      dd 0
tmpOutputBuffer    dd 0
tmpFileSize        dd 0
tmpBytesRead       dd 0
tmpBytesWritten    dd 0
tmpSourcePointer   dd 0
tmpSourceLength    dd 0
tmpDetectedEncoding dd ENC_UTF8
tmpCodePage        dd CP_UTF8_VALUE
tmpMbFlags         dd 0
tmpTextChars       dd 0
tmpOutputSize      dd 0
tmpPayloadSize     dd 0
tmpPrefixSize      dd 0
tmpUsedDefault     dd 0
tmpSearchBuffer    dd 0
tmpReplaceOutput   dd 0
tmpPrintBuffer     dd 0
tmpLangPointer     dd 0

wc WNDCLASS CS_HREDRAW or CS_VREDRAW,WindowProc,0,0,0,0,0,COLOR_WINDOW+1,0,className
findWc WNDCLASS CS_HREDRAW or CS_VREDRAW,FindReplaceProc,0,0,0,0,0,COLOR_BTNFACE+1,0,findClassName
msg MSG
clientRect RECT
printPageRect RECT
printCalcRect RECT
printDrawRect RECT
openFileName OPENFILENAME
printDialog PRINTDLG
fontDialog CHOOSEFONT
editorLogFont LOGFONT

menuInfo:
 .cbSize         dd MENUINFO_SIZE_VALUE
 .fMask          dd MIM_BACKGROUND_VALUE or MIM_APPLYTOSUBMENUS_VALUE
 .dwStyle        dd 0
 .cyMax          dd 0
 .hbrBack        dd 0
 .dwContextHelpID dd 0
 .dwMenuData     dd 0

printDocInfo:
 .cbSize      dd 0
 .lpszDocName dd 0
 .lpszOutput  dd 0
 .lpszDatatype dd 0
 .fwType      dd 0

currentPath        rw MAX_PATH_CHARS
dialogPath         rw MAX_PATH_CHARS
dropPath           rw MAX_PATH_CHARS
titleBuffer        rw TITLE_CHARS
statusBuffer       rw STATUS_TEXT_CHARS
findTextBuffer     rw SEARCH_TEXT_CHARS
replaceTextBuffer  rw SEARCH_TEXT_CHARS
replaceAllMessage  rw 128

; ACCEL is packed as: BYTE fVirt, pad BYTE, WORD key, WORD command
accelerators:
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'N',ID_FILE_NEW
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'O',ID_FILE_OPEN
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'S',ID_FILE_SAVE
        db FVIRTKEY_VALUE or FCONTROL_VALUE or FSHIFT_VALUE,0
        dw 'S',ID_FILE_SAVE_AS
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'P',ID_FILE_PRINT
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'F',ID_EDIT_FIND
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'H',ID_EDIT_REPLACE
        db FVIRTKEY_VALUE,0
        dw VK_F3,ID_EDIT_FIND_NEXT
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'Z',ID_EDIT_UNDO
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'X',ID_EDIT_CUT
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'C',ID_EDIT_COPY
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'V',ID_EDIT_PASTE
        db FVIRTKEY_VALUE or FCONTROL_VALUE,0
        dw 'A',ID_EDIT_SELECT_ALL
        db FVIRTKEY_VALUE,0
        dw VK_DELETE,ID_EDIT_DELETE
        db FVIRTKEY_VALUE,0
        dw VK_F1,ID_HELP_ABOUT
ACCELERATOR_COUNT = ($-accelerators)/6

bomUtf8            db 0EFh,0BBh,0BFh

; ASCII-only source strings make the project independent of the assembler's
; source-file code page. The executable itself uses Unicode Win32 APIs.
className          du 'FasmNotepadWindow',0
editClass          du 'EDIT',0
staticClass        du 'STATIC',0
buttonClass        du 'BUTTON',0
findClassName      du 'FasmNotepadFindReplaceWindow',0
appName            du 'FASM Notepad',0
initialTitle       du 'FASM Notepad',0
modifiedSuffix     du ' *',0
titleSeparator     du ' - FASM Notepad [',0
titleEnd           du ']',0
emptyString        du 0

menuEncUtf8        du 'UTF-8',0
menuEncUtf8Bom     du 'UTF-8 BOM',0
menuEncUtf16Le     du 'UTF-16 LE BOM',0
menuEncUtf16Be     du 'UTF-16 BE BOM',0
menuEncCp1252      du 'Windows-1252',0
menuEncCp1250      du 'Windows-1250',0
menuEncCp1251      du 'Windows-1251',0
menuEncIso         du 'ISO-8859-1',0
menuEncCp437       du 'DOS/OEM 437',0
menuEncCp850       du 'DOS/OEM 850',0

printJobName       du 'FASM Notepad document',0
printerFontName    du 'Courier New',0

encNameUtf8        du 'UTF-8',0
encNameUtf8Bom     du 'UTF-8 BOM',0
encNameUtf16Le     du 'UTF-16 LE',0
encNameUtf16Be     du 'UTF-16 BE',0
encNameCp1252      du 'Windows-1252',0
encNameCp1250      du 'Windows-1250',0
encNameCp1251      du 'Windows-1251',0
encNameIso         du 'ISO-8859-1',0
encNameCp437       du 'OEM 437',0
encNameCp850       du 'OEM 850',0

extensionTxt       du '.txt',0
extensionMd        du '.md',0

dwmApiLibraryName  du 'dwmapi.dll',0
dwmSetWindowAttributeName db 'DwmSetWindowAttribute',0

include 'src\localization.inc'

; ----- imports ----------------------------------------------------------------

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        user32,'USER32.DLL',\
        gdi32,'GDI32.DLL',\
        comdlg32,'COMDLG32.DLL',\
        shell32,'SHELL32.DLL'

import kernel32,\
       GetModuleHandleW,'GetModuleHandleW',\
       ExitProcess,'ExitProcess',\
       GlobalAlloc,'GlobalAlloc',\
       GlobalFree,'GlobalFree',\
       CreateFileW,'CreateFileW',\
       GetFileSize,'GetFileSize',\
       ReadFile,'ReadFile',\
       WriteFile,'WriteFile',\
       CloseHandle,'CloseHandle',\
       MultiByteToWideChar,'MultiByteToWideChar',\
       WideCharToMultiByte,'WideCharToMultiByte',\
       GetCommandLineW,'GetCommandLineW',\
       LocalFree,'LocalFree',\
       lstrcpyW,'lstrcpyW',\
       lstrcatW,'lstrcatW',\
       lstrlenW,'lstrlenW',\
       CompareStringW,'CompareStringW',\
       MulDiv,'MulDiv',\
       LoadLibraryW,'LoadLibraryW',\
       GetProcAddress,'GetProcAddress',\
       FreeLibrary,'FreeLibrary'

import user32,\
       RegisterClassW,'RegisterClassW',\
       CreateWindowExW,'CreateWindowExW',\
       DefWindowProcW,'DefWindowProcW',\
       SetWindowLongW,'SetWindowLongW',\
       CallWindowProcW,'CallWindowProcW',\
       ShowWindow,'ShowWindow',\
       UpdateWindow,'UpdateWindow',\
       GetMessageW,'GetMessageW',\
       TranslateMessage,'TranslateMessage',\
       DispatchMessageW,'DispatchMessageW',\
       PostQuitMessage,'PostQuitMessage',\
       LoadCursorW,'LoadCursorW',\
       LoadIconW,'LoadIconW',\
       CreateMenu,'CreateMenu',\
       CreatePopupMenu,'CreatePopupMenu',\
       AppendMenuW,'AppendMenuW',\
       SetMenu,'SetMenu',\
       SetMenuInfo,'SetMenuInfo',\
       DrawMenuBar,'DrawMenuBar',\
       DestroyMenu,'DestroyMenu',\
       CheckMenuRadioItem,'CheckMenuRadioItem',\
       CheckMenuItem,'CheckMenuItem',\
       MessageBoxW,'MessageBoxW',\
       MoveWindow,'MoveWindow',\
       GetClientRect,'GetClientRect',\
       InvalidateRect,'InvalidateRect',\
       RedrawWindow,'RedrawWindow',\
       FillRect,'FillRect',\
       GetDlgItem,'GetDlgItem',\
       SetFocus,'SetFocus',\
       SendMessageW,'SendMessageW',\
       DestroyWindow,'DestroyWindow',\
       GetWindowTextLengthW,'GetWindowTextLengthW',\
       GetWindowTextW,'GetWindowTextW',\
       SetWindowTextW,'SetWindowTextW',\
       CreateAcceleratorTableW,'CreateAcceleratorTableW',\
       TranslateAcceleratorW,'TranslateAcceleratorW',\
       DestroyAcceleratorTable,'DestroyAcceleratorTable',\
       IsDialogMessageW,'IsDialogMessageW',\
       IsWindowVisible,'IsWindowVisible',\
       GetFocus,'GetFocus',\
       IsChild,'IsChild',\
       SetForegroundWindow,'SetForegroundWindow',\
       SetTimer,'SetTimer',\
       KillTimer,'KillTimer',\
       IsCharAlphaNumericW,'IsCharAlphaNumericW',\
       DrawTextW,'DrawTextW',\
       wsprintfW,'wsprintfW'

import gdi32,\
       GetStockObject,'GetStockObject',\
       GetDeviceCaps,'GetDeviceCaps',\
       CreateFontW,'CreateFontW',\
       CreateFontIndirectW,'CreateFontIndirectW',\
       CreateSolidBrush,'CreateSolidBrush',\
       GetObjectW,'GetObjectW',\
       SetTextColor,'SetTextColor',\
       SetBkColor,'SetBkColor',\
       SelectObject,'SelectObject',\
       DeleteObject,'DeleteObject',\
       DeleteDC,'DeleteDC',\
       StartDocW,'StartDocW',\
       EndDoc,'EndDoc',\
       AbortDoc,'AbortDoc',\
       StartPage,'StartPage',\
       EndPage,'EndPage'

import comdlg32,\
       GetOpenFileNameW,'GetOpenFileNameW',\
       GetSaveFileNameW,'GetSaveFileNameW',\
       PrintDlgW,'PrintDlgW',\
       ChooseFontW,'ChooseFontW'

import shell32,\
       DragAcceptFiles,'DragAcceptFiles',\
       DragQueryFileW,'DragQueryFileW',\
       DragFinish,'DragFinish',\
       CommandLineToArgvW,'CommandLineToArgvW'

; ----- resources --------------------------------------------------------------

section '.rsrc' resource data readable

directory RT_ICON,icons,\
          RT_GROUP_ICON,group_icons,\
          RT_VERSION,versions

resource icons,\
         1,LANG_NEUTRAL,icon_data

resource group_icons,\
         IDR_ICON,LANG_NEUTRAL,main_icon

resource versions,\
         1,LANG_NEUTRAL,version

icon main_icon,icon_data,'src\assets\FasmNotepad.ico'

versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_ENGLISH+SUBLANG_DEFAULT,0,\
            'FileDescription','FASM Notepad',\
            'FileVersion','1.3.2',\
            'ProductName','FASM Notepad',\
            'ProductVersion','1.3.2',\
            'OriginalFilename','FasmNotepad.exe',\
            'LegalCopyright','Copyright (c) 2026 zeittresor - MIT License',\
            'Comments','Source: github.com/zeittresor/fasm_notepad'

