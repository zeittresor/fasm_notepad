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

APP_VERSION        equ 3
MAX_PATH_CHARS     equ 260
TITLE_CHARS        equ 640
MAX_FILE_BYTES     equ 134217728       ; 128 MiB safety limit for this simple editor
INVALID_FILE_SIZE_VALUE equ 0FFFFFFFFh ; GetFileSize failure sentinel
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

IDC_FIND_TEXT      equ 3101
IDC_REPLACE_TEXT   equ 3102
IDC_MATCH_CASE     equ 3103
IDC_WHOLE_WORD     equ 3104
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

; ----- program entry ----------------------------------------------------------

section '.text' code readable executable

start:
        invoke  GetModuleHandleW,0
        mov     [hInstance],eax
        mov     [wc.hInstance],eax

        invoke  LoadIconW,0,IDI_APPLICATION
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
        invoke  MessageBoxW,0,msgFatalStart,appName,MB_OK or MB_ICONERROR
        invoke  ExitProcess,1

; ----- main window procedure --------------------------------------------------

proc WindowProc hwnd,wmsg,wparam,lparam
        push    ebx esi edi

        cmp     dword [wmsg],WM_CREATE
        je      .wm_create
        cmp     dword [wmsg],WM_SIZE
        je      .wm_size
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
        call    CreateApplicationMenu
        call    CreateEditor
        call    CreateStatusLine
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
.cmd_reload:
        call    ReloadCurrentDocument
        jmp     .handled_zero
.cmd_about:
        invoke  MessageBoxW,[hwnd],aboutText,appName,MB_OK or MB_ICONINFORMATION
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

        invoke  GetStockObject,DEFAULT_GUI_FONT
        mov     [hEditorFont],eax
        invoke  SendMessageW,dword [hEdit],WM_SETFONT,[hEditorFont],TRUE
        invoke  SendMessageW,dword [hEdit],EM_SETLIMITTEXT,07FFFFFFEh,0
.done:
        ret

CreateStatusLine:
        invoke  CreateWindowExW,WS_EX_STATICEDGE,staticClass,emptyString,\
                WS_CHILD or WS_VISIBLE or SS_LEFTNOWORDWRAP_VALUE,0,0,0,STATUS_HEIGHT,\
                [hWndMain],IDC_STATUS,[hInstance],0
        mov     dword [hStatus],eax
        test    eax,eax
        jz      .done
        cmp     dword [hEditorFont],0
        jne     .font_ready
        invoke  GetStockObject,DEFAULT_GUI_FONT
        mov     dword [hEditorFont],eax
.font_ready:
        invoke  SendMessageW,dword [hStatus],WM_SETFONT,dword [hEditorFont],TRUE
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
        cinvoke wsprintfW,statusBuffer,statusFormat,dword [statusLineNumber],dword [statusCharCount],dword [statusTokenCount]
        invoke  SetWindowTextW,dword [hStatus],statusBuffer
.done:
        ret

CreateApplicationMenu:
        invoke  CreateMenu
        mov     [hMainMenu],eax

        invoke  CreatePopupMenu
        mov     [hFileMenu],eax
        invoke  AppendMenuW,[hFileMenu],MF_STRING,ID_FILE_NEW,menuFileNew
        invoke  AppendMenuW,[hFileMenu],MF_STRING,ID_FILE_OPEN,menuFileOpen
        invoke  AppendMenuW,[hFileMenu],MF_STRING,ID_FILE_SAVE,menuFileSave
        invoke  AppendMenuW,[hFileMenu],MF_STRING,ID_FILE_SAVE_AS,menuFileSaveAs
        invoke  AppendMenuW,[hFileMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,[hFileMenu],MF_STRING,ID_FILE_PRINT,menuFilePrint
        invoke  AppendMenuW,[hFileMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,[hFileMenu],MF_STRING,ID_FILE_EXIT,menuFileExit

        invoke  CreatePopupMenu
        mov     [hEditMenu],eax
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_UNDO,menuEditUndo
        invoke  AppendMenuW,[hEditMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_FIND,menuEditFind
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_FIND_NEXT,menuEditFindNext
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_REPLACE,menuEditReplace
        invoke  AppendMenuW,[hEditMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_CUT,menuEditCut
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_COPY,menuEditCopy
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_PASTE,menuEditPaste
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_DELETE,menuEditDelete
        invoke  AppendMenuW,[hEditMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,[hEditMenu],MF_STRING,ID_EDIT_SELECT_ALL,menuEditSelectAll

        invoke  CreatePopupMenu
        mov     [hFormatMenu],eax
        invoke  AppendMenuW,[hFormatMenu],MF_STRING or MF_CHECKED,ID_FORMAT_WRAP,menuFormatWrap

        invoke  CreatePopupMenu
        mov     [hEncodingMenu],eax
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_UTF8,menuEncUtf8
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_UTF8_BOM,menuEncUtf8Bom
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_UTF16_LE,menuEncUtf16Le
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_UTF16_BE,menuEncUtf16Be
        invoke  AppendMenuW,[hEncodingMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_CP1252,menuEncCp1252
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_CP1250,menuEncCp1250
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_CP1251,menuEncCp1251
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_ISO8859_1,menuEncIso
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_CP437,menuEncCp437
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_CP850,menuEncCp850
        invoke  AppendMenuW,[hEncodingMenu],MF_SEPARATOR,0,0
        invoke  AppendMenuW,[hEncodingMenu],MF_STRING,ID_ENC_RELOAD,menuEncReload

        invoke  CreatePopupMenu
        mov     [hHelpMenu],eax
        invoke  AppendMenuW,[hHelpMenu],MF_STRING,ID_HELP_ABOUT,menuHelpAbout

        invoke  AppendMenuW,[hMainMenu],MF_POPUP,[hFileMenu],menuTopFile
        invoke  AppendMenuW,[hMainMenu],MF_POPUP,[hEditMenu],menuTopEdit
        invoke  AppendMenuW,[hMainMenu],MF_POPUP,[hFormatMenu],menuTopFormat
        invoke  AppendMenuW,[hMainMenu],MF_POPUP,[hEncodingMenu],menuTopEncoding
        invoke  AppendMenuW,[hMainMenu],MF_POPUP,[hHelpMenu],menuTopHelp

        invoke  SetMenu,[hWndMain],[hMainMenu]
        invoke  DrawMenuBar,[hWndMain]
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
        invoke  CreateWindowExW,WS_EX_TOOLWINDOW or WS_EX_CONTROLPARENT_VALUE,findClassName,findDialogTitle,\
                WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU,CW_USEDEFAULT,CW_USEDEFAULT,500,245,\
                [hWndMain],0,[hInstance],0
        test    eax,eax
        jz      .done
        mov     dword [hFindReplace],eax
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
        cmp     dword [wmsg],WM_COMMAND
        je      .command
        cmp     dword [wmsg],WM_CLOSE
        je      .close
        cmp     dword [wmsg],WM_DESTROY
        je      .destroy
        invoke  DefWindowProcW,[hwnd],dword [wmsg],[wparam],[lparam]
        jmp     .finish

.create:
        mov     eax,[hwnd]
        mov     dword [hFindReplace],eax
        invoke  CreateWindowExW,0,staticClass,findLabel,WS_CHILD or WS_VISIBLE,12,16,92,20,[hwnd],0,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE
        invoke  CreateWindowExW,WS_EX_CLIENTEDGE,editClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP or ES_AUTOHSCROLL,\
                108,12,360,25,[hwnd],IDC_FIND_TEXT,[hInstance],0
        mov     dword [hFindText],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE

        invoke  CreateWindowExW,0,staticClass,replaceLabel,WS_CHILD or WS_VISIBLE,12,53,92,20,[hwnd],0,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE
        invoke  CreateWindowExW,WS_EX_CLIENTEDGE,editClass,emptyString,WS_CHILD or WS_VISIBLE or WS_TABSTOP or ES_AUTOHSCROLL,\
                108,49,360,25,[hwnd],IDC_REPLACE_TEXT,[hInstance],0
        mov     dword [hReplaceText],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE

        invoke  CreateWindowExW,0,buttonClass,matchCaseLabel,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX_VALUE,\
                108,84,135,22,[hwnd],IDC_MATCH_CASE,[hInstance],0
        mov     dword [hMatchCase],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,wholeWordLabel,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX_VALUE,\
                255,84,150,22,[hwnd],IDC_WHOLE_WORD,[hInstance],0
        mov     dword [hWholeWord],eax
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE

        invoke  CreateWindowExW,0,buttonClass,findNextLabel,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_DEFPUSHBUTTON_VALUE,\
                108,119,110,30,[hwnd],ID_FIND_NEXT,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,replaceButtonLabel,WS_CHILD or WS_VISIBLE or WS_TABSTOP,\
                228,119,110,30,[hwnd],ID_REPLACE_ONE,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,replaceAllLabel,WS_CHILD or WS_VISIBLE or WS_TABSTOP,\
                348,119,120,30,[hwnd],ID_REPLACE_ALL,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE
        invoke  CreateWindowExW,0,buttonClass,closeButtonLabel,WS_CHILD or WS_VISIBLE or WS_TABSTOP,\
                358,160,110,30,[hwnd],ID_FIND_CLOSE,[hInstance],0
        invoke  SendMessageW,eax,WM_SETFONT,dword [hEditorFont],TRUE
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
        invoke  MessageBoxW,dword [hFindReplace],msgEnterSearch,appName,MB_OK or MB_ICONINFORMATION
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
        invoke  MessageBoxW,dword [hFindReplace],msgTextNotFound,appName,MB_OK or MB_ICONINFORMATION
        xor     eax,eax
        ret
.memory_error:
        invoke  MessageBoxW,dword [hWndMain],msgMemoryError,appName,MB_OK or MB_ICONERROR
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
        invoke  MessageBoxW,dword [hFindReplace],msgEnterSearch,appName,MB_OK or MB_ICONINFORMATION
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
        invoke  MessageBoxW,dword [hFindReplace],msgEnterSearch,appName,MB_OK or MB_ICONINFORMATION
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
        invoke  MessageBoxW,dword [hFindReplace],msgTextNotFound,appName,MB_OK or MB_ICONINFORMATION
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
        cinvoke wsprintfW,replaceAllMessage,replaceAllFormat,dword [replaceMatchCount]
        invoke  MessageBoxW,dword [hFindReplace],replaceAllMessage,appName,MB_OK or MB_ICONINFORMATION
        call    FreeReplaceBuffers
        ret
.memory_error:
        call    FreeReplaceBuffers
        invoke  MessageBoxW,dword [hWndMain],msgMemoryError,appName,MB_OK or MB_ICONERROR
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
        invoke  MessageBoxW,dword [hWndMain],msgMemoryError,appName,MB_OK or MB_ICONERROR
        jmp     .abort_cleanup
.print_error:
        invoke  MessageBoxW,dword [hWndMain],msgPrintError,appName,MB_OK or MB_ICONERROR
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

PrepareOpenFileName:
        mov     dword [openFileName.lStructSize],sizeof.OPENFILENAME
        mov     eax,[hWndMain]
        mov     [openFileName.hwndOwner],eax
        mov     eax,[hInstance]
        mov     [openFileName.hInstance],eax
        mov     dword [openFileName.lpstrFilter],fileFilter
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
        mov     dword [openFileName.lpstrDefExt],defaultExtension
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
        invoke  MessageBoxW,[hWndMain],msgSaveChanges,appName,MB_YESNOCANCEL or MB_ICONQUESTION
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
        invoke  MessageBoxW,[hWndMain],msgTooLarge,appName,MB_OK or MB_ICONWARNING
        jmp     .failure_cleanup
.open_error:
        invoke  MessageBoxW,[hWndMain],msgOpenError,appName,MB_OK or MB_ICONERROR
        jmp     .failure_cleanup
.read_error:
        invoke  MessageBoxW,[hWndMain],msgReadError,appName,MB_OK or MB_ICONERROR
        jmp     .failure_cleanup
.memory_error:
        invoke  MessageBoxW,[hWndMain],msgMemoryError,appName,MB_OK or MB_ICONERROR
        jmp     .failure_cleanup
.conversion_error:
        invoke  MessageBoxW,[hWndMain],msgConversionError,appName,MB_OK or MB_ICONERROR
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
        invoke  MessageBoxW,[hWndMain],msgLossyEncoding,appName,MB_YESNO or MB_ICONWARNING or MB_DEFBUTTON2
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
        invoke  MessageBoxW,[hWndMain],msgWriteError,appName,MB_OK or MB_ICONERROR
        jmp     .failure
.memory_error:
        invoke  MessageBoxW,[hWndMain],msgMemoryError,appName,MB_OK or MB_ICONERROR
        jmp     .failure
.conversion_error:
        invoke  MessageBoxW,[hWndMain],msgConversionError,appName,MB_OK or MB_ICONERROR
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
        invoke  lstrcpyW,titleBuffer,untitledName
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
hFindReplace       dd 0
hFindText          dd 0
hReplaceText       dd 0
hMatchCase         dd 0
hWholeWord         dd 0
hMainMenu          dd 0
hFileMenu          dd 0
hEditMenu          dd 0
hFormatMenu        dd 0
hEncodingMenu      dd 0
hHelpMenu          dd 0
hAccel             dd 0

modified           dd 0
contentModified    dd 0
encodingDirty      dd 0
loadingText        dd 0
wordWrap           dd 1
currentEncoding    dd ENC_UTF8
savedEncoding      dd ENC_UTF8
editorStyle        dd 0
selectionStart     dd 0
selectionEnd       dd 0
layoutEditorHeight dd 0

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

wc WNDCLASS CS_HREDRAW or CS_VREDRAW,WindowProc,0,0,0,0,0,COLOR_WINDOW+1,0,className
findWc WNDCLASS CS_HREDRAW or CS_VREDRAW,FindReplaceProc,0,0,0,0,0,COLOR_BTNFACE+1,0,findClassName
msg MSG
clientRect RECT
printPageRect RECT
printCalcRect RECT
printDrawRect RECT
openFileName OPENFILENAME
printDialog PRINTDLG

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
untitledName       du 'Unbenannt',0
modifiedSuffix     du ' *',0
titleSeparator     du ' - FASM Notepad [',0
titleEnd           du ']',0
emptyString        du 0

menuTopFile        du '&Datei',0
menuTopEdit        du '&Bearbeiten',0
menuTopFormat      du 'F&ormat',0
menuTopEncoding    du '&Zeichensatz',0
menuTopHelp        du '&Hilfe',0

menuFileNew        du '&Neu',9,'Ctrl+N',0
menuFileOpen       du '&Oeffnen...',9,'Ctrl+O',0
menuFileSave       du '&Speichern',9,'Ctrl+S',0
menuFileSaveAs     du 'Speichern &unter...',9,'Ctrl+Shift+S',0
menuFilePrint      du '&Drucken...',9,'Ctrl+P',0
menuFileExit       du '&Beenden',0

menuEditUndo       du '&Rueckgaengig',9,'Ctrl+Z',0
menuEditFind       du '&Suchen...',9,'Ctrl+F',0
menuEditFindNext   du 'Weitersuchen',9,'F3',0
menuEditReplace    du '&Ersetzen...',9,'Ctrl+H',0
menuEditCut        du 'A&usschneiden',9,'Ctrl+X',0
menuEditCopy       du '&Kopieren',9,'Ctrl+C',0
menuEditPaste      du '&Einfuegen',9,'Ctrl+V',0
menuEditDelete     du '&Loeschen',9,'Entf',0
menuEditSelectAll  du '&Alles markieren',9,'Ctrl+A',0

menuFormatWrap     du '&Zeilenumbruch',0

menuEncUtf8        du 'UTF-8 (ohne BOM)',0
menuEncUtf8Bom     du 'UTF-8 mit BOM',0
menuEncUtf16Le     du 'UTF-16 Little Endian mit BOM',0
menuEncUtf16Be     du 'UTF-16 Big Endian mit BOM',0
menuEncCp1252      du 'Windows-1252 (Westeuropa)',0
menuEncCp1250      du 'Windows-1250 (Mitteleuropa)',0
menuEncCp1251      du 'Windows-1251 (Kyrillisch)',0
menuEncIso         du 'ISO-8859-1 (Latin-1)',0
menuEncCp437       du 'DOS/OEM 437',0
menuEncCp850       du 'DOS/OEM 850',0
menuEncReload      du 'Datei mit Auswahl &neu laden',0

menuHelpAbout      du '&Info...',9,'F1',0

findDialogTitle    du 'Suchen und Ersetzen',0
findLabel          du 'Suchen nach:',0
replaceLabel       du 'Ersetzen durch:',0
matchCaseLabel     du 'Gross/Klein beachten',0
wholeWordLabel     du 'Nur ganze Woerter',0
findNextLabel      du 'Weitersuchen',0
replaceButtonLabel du 'Ersetzen',0
replaceAllLabel    du 'Alle ersetzen',0
closeButtonLabel   du 'Schliessen',0
statusFormat       du 'Zeile: %u    Zeichen: %u    Token ca.: %u',0
replaceAllFormat   du '%u Vorkommen wurden ersetzt.',0
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

defaultExtension   du 'txt',0
fileFilter         du 'Textdateien (*.txt)',0,'*.txt',0,'Alle Dateien (*.*)',0,'*.*',0,0

msgFatalStart      du 'Die Anwendung konnte nicht gestartet werden.',0
msgSaveChanges     du 'Die Datei wurde geaendert. Aenderungen speichern?',0
msgOpenError       du 'Die Datei konnte nicht geoeffnet werden.',0
msgReadError       du 'Die Datei konnte nicht vollstaendig gelesen werden.',0
msgWriteError      du 'Die Datei konnte nicht vollstaendig geschrieben werden.',0
msgMemoryError     du 'Nicht genug Arbeitsspeicher fuer diesen Vorgang.',0
msgConversionError du 'Die Zeichensatz-Konvertierung ist fehlgeschlagen.',0
msgTooLarge        du 'Die Datei ist fuer diesen einfachen Editor zu gross (Maximum: 128 MiB).',0
msgLossyEncoding   du 'Der gewaehlte Zeichensatz kann nicht alle Zeichen darstellen. Nicht darstellbare Zeichen werden ersetzt. Trotzdem speichern?',0
msgEnterSearch     du 'Bitte einen Suchtext eingeben.',0
msgTextNotFound    du 'Der Suchtext wurde nicht gefunden.',0
msgPrintError      du 'Das Dokument konnte nicht gedruckt werden.',0

aboutText          du 'FASM Notepad 1.2.2',13,10,\
                       'Ein kleiner nativer Win32-Texteditor in Flat Assembler.',13,10,13,10,\
                       'Funktionen:',13,10,\
                       '- Neu, Oeffnen, Speichern, Drucken und Speichern unter',13,10,\
                       '- Drag-and-drop von Dateien',13,10,\
                       '- Suchen und Ersetzen',13,10,\
                       '- Undo, Cut, Copy, Paste und Alles markieren',13,10,\
                       '- Dynamische Statuszeile mit Zeile, Zeichen und Token-Schaetzung',13,10,\
                       '- Zeilenumbruch und mehrere Zeichensaetze',0

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
       MulDiv,'MulDiv'

import user32,\
       RegisterClassW,'RegisterClassW',\
       CreateWindowExW,'CreateWindowExW',\
       DefWindowProcW,'DefWindowProcW',\
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
       DrawMenuBar,'DrawMenuBar',\
       CheckMenuRadioItem,'CheckMenuRadioItem',\
       CheckMenuItem,'CheckMenuItem',\
       MessageBoxW,'MessageBoxW',\
       MoveWindow,'MoveWindow',\
       GetClientRect,'GetClientRect',\
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
       PrintDlgW,'PrintDlgW'

import shell32,\
       DragAcceptFiles,'DragAcceptFiles',\
       DragQueryFileW,'DragQueryFileW',\
       DragFinish,'DragFinish',\
       CommandLineToArgvW,'CommandLineToArgvW'
