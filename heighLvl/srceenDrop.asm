.486
.MODEL  FLAT, STDCALL
OPTION  CASEMAP:NONE

;   Const
;   ~~~~~
    LOCALE_SYSTEM_DEFAULT   equ 800h
    __UNICODE__             equ 1
;    TokenSize               equ 255
;    ToFile                  equ 0

;   include files
;   ~~~~~~~~~~~~~
    include \masm32\include\windows.inc         ;- константы
    include \masm32\include\Kernel32.inc        ;- Kernel32
    include \masm32\include\User32.inc          ;- User32
    include \masm32\include\ole32.inc           ;- ole32
    include \masm32\include\Gdi32.inc           ;- User32
    include \masm32\include\gdiplus.inc         ;- GDI+
    include \masm32\macros\macros.asm           ;- макросы

;   libraries
;   ~~~~~~~~~
    includelib \masm32\LIB\Kernel32.lib
    includelib \masm32\LIB\User32.lib
    includelib \masm32\LIB\ole32.lib           
    includelib \masm32\LIB\Gdi32.lib
    includelib \masm32\LIB\gdiplus.lib

;   Prototypes
;   ~~~~~~~~~~
    stdWriteLn  PROTO :DWORD
    MakeScreen  PROTO :DWORD
    
;   Types
;   ~~~~~~~~~~
    SetProcessDPIAware TYPEDEF PTR pr0

.DATA

StdHOut HANDLE  ?
StdHIn  HANDLE  ?
hHeap   HANDLE  ?
evExit  HANDLE  ?
hDisp   HANDLE  ?
gdiTok  LONG    ?
;scrMode BYTE    ToFile     
gdiInp  GdiplusStartupInput <1, 0, 0, 0>
encPNG  GUID <557CF406h, 1A04h, 11D3h, {9Ah, 73h, 00h, 00h, 0F8h, 1Eh, 0F3h, 2Eh}>
strflt  WCHAR   'y','y','y','y','M','M','d','d','_','H','H','m','m','s','s','_','U','T','C', 0
        WCHAR   005Fh, 0048h, 0048h, 006Dh, 006Dh, 0073h, 0073h, 005Fh
        WCHAR   0055h, 0054h, 0043h, 0000h 
;str001  WCHAR   0412h, 0432h, 0435h, 0434h, 0438h, 0442h, 0435h, 0020h	; Введите токен:
;        WCHAR   0442h, 043Eh, 043Ah, 0435h, 043Dh, 003Ah, 0000h
str002  WCHAR   041Dh, 0430h, 0436h, 043Ch, 0438h, 0442h, 0435h, 0020h  ; Нажмите Enter для завершения
        WCHAR   0045h, 006Eh, 0074h, 0065h, 0072h, 0020h, 0434h, 043Bh
        WCHAR   044Fh, 0020h, 0437h, 0430h, 0432h, 0435h, 0440h, 0448h
        WCHAR   0435h, 043Dh, 0438h, 044Fh, 0000h
str003  WCHAR   '.','p','n','g',0
str004  WCHAR   'U','s','e','r','3','2','.','d','l','l',0
strA01  CHAR    "SetProcessDPIAware", 0
;buffer  TCHAR   TokenSize + 1 DUP(?)       
           
.CODE

main            PROC USES esi
        LOCAL nWriten:DWORD, bufWait:DWORD

        ; Инициализация
        mov     StdHOut,        rv(GetStdHandle, STD_OUTPUT_HANDLE)
        mov     StdHIn,         rv(GetStdHandle, STD_INPUT_HANDLE)
        mov     hHeap,          rv(GetProcessHeap)
        mov     hDisp,          rv(GetDC, NULL)
        fn      GdiplusStartup, &gdiTok, &gdiInp, NULL
        
        ; DPI для win 7+
        .IF rv(GetModuleHandle, &str004)
         mov    ecx,            eax
         .IF rv(GetProcAddress, ecx, &strA01)
          fn    SetProcessDPIAware PTR eax
         .ENDIF
        .ENDIF
        
        xor     esi,            esi
;        .IF scrMode != ToFile
;         ; запрос токена
;         fn      stdWriteLn,     &str001
;         fn      ReadConsole,    StdHIn, &buffer, TokenSize, &nWriten, NULL
;
;         ; добавим ноль в конец строки
;         mov     ecx,            nWriten
;         dec     ecx
;         shl     ecx,            1
;         mov     WORD PTR [buffer + ecx - 2], 0
;         mov     esi,            rv(HeapAlloc, hHeap, HEAP_NO_SERIALIZE, ecx)
;         fn      lstrcpy,        esi, &buffer
;        .ENDIF
        
        ; запускаем поток
        mov     evExit,         rv(CreateEvent, NULL, FALSE, FALSE, NULL)
        fn      CreateThread,   NULL, NULL, MakeScreen, esi, NULL, NULL

        ; ожидание завершения
        fn      stdWriteLn,     &str002
        fn      ReadConsole,    StdHIn, &bufWait, 2, &nWriten, NULL

        ; выход
        fn      SetEvent,       evExit
        xor     eax,            eax
        RET        
main            ENDP

; создание и отправка скриншота
MakeScreen      PROC    USES esi edi, pToken:DWORD
        LOCAL TimeBigin:SYSTEMTIME, lpFileName:DWORD, bitMap:DWORD, scrHght:DWORD, scrWdth:DWORD, pStrm:DWORD
        
        mov     eax,            WAIT_TIMEOUT
        .WHILE  eax             != WAIT_OBJECT_0
        
         ;время начала загрузки
         fn     GetSystemTime,  &TimeBigin
         
         ; получаем имя файла
         fn     GetDateFormat,  LOCALE_SYSTEM_DEFAULT, NULL, &TimeBigin, &strflt, NULL, NULL
         mov    esi,            eax
         shl    eax,            1
         mov    edi,            rv(HeapAlloc, hHeap, HEAP_NO_SERIALIZE, eax)
         fn     GetDateFormat,  LOCALE_SYSTEM_DEFAULT, NULL, &TimeBigin, &strflt, edi, esi
         fn     GetTimeFormat,  LOCALE_SYSTEM_DEFAULT, NULL, &TimeBigin, edi, NULL, NULL
         mov    esi,            eax
         add    eax,            4
         shl    eax,            1
         mov    lpFileName,     rv(HeapAlloc, hHeap, HEAP_NO_SERIALIZE, eax)
         fn     GetTimeFormat,  LOCALE_SYSTEM_DEFAULT, NULL, &TimeBigin, edi, lpFileName, esi
         fn     HeapFree,       hHeap, HEAP_NO_SERIALIZE, edi
         mov    eax,             lpFileName
         fn     lstrcpy,        &[eax + esi * 2 - 2], &str003
         
         ;скриншот
         mov    scrWdth,        rv(GetSystemMetrics, SM_CXSCREEN)   
         mov    scrHght,        rv(GetSystemMetrics, SM_CYSCREEN)   
         mov    esi,            rv(CreateCompatibleBitmap, hDisp, scrWdth, scrHght)
         mov    edi,            rv(CreateCompatibleDC, hDisp)
         fn     SelectObject,   edi, esi
         fn     BitBlt,         edi, 0, 0, scrWdth, scrHght, hDisp, 0, 0, SRCCOPY
         fn     GdipCreateBitmapFromHBITMAP, esi, NULL, &bitMap
         fn     DeleteDC,       edi
         fn     DeleteObject,   esi
         
         ; сохраняем в файл
;         .IF scrMode == ToFile
          fn    GdipSaveImageToFile, bitMap, lpFileName, &encPNG, NULL
;         .else 
          
;         .ENDIF
         
         ;ожидание
         fn     HeapFree,       hHeap, HEAP_NO_SERIALIZE, lpFileName
         fn     GdipDisposeImage, bitMap
         fn     WaitForSingleObject, evExit, 6000
        .ENDW
        fn      GdiplusShutdown, gdiTok
        xor     eax,            eax
        RET
MakeScreen      ENDP

; вывод строки в консоль с переносом строки
stdWriteLn      PROC    pText:DWORD
        LOCAL nWriten:DWORD, strBR:DWORD

        mov     strBR,          0Ah
        mov     ecx,            rv(lstrlen, pText) 
        fn      WriteConsole,   StdHOut, pText, ecx, &nWriten, NULL
        fn      WriteConsole,   StdHOut, &strBR, 1, &nWriten, NULL
        RET
stdWriteLn      ENDP

END main

;GdipGetImageEncodersSize
;GdipGetImageEncoders

;GetMonitorInfo
;SetProcessDPIAware
