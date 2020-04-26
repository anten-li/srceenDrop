.486
.MODEL  FLAT, STDCALL
OPTION  CASEMAP:NONE

;   Const
;   ~~~~~
    LOCALE_SYSTEM_DEFAULT           equ 800h
    __UNICODE__                     equ 1
    TokenSize                       equ 255
    ToFile                          equ 0
    ToDrop                          equ 1
    WINHTTP_ACCESS_TYPE_NO_PROXY    equ 1
    WINHTTP_NO_PROXY_NAME           equ 0
    WINHTTP_NO_PROXY_BYPASS         equ 0
    INTERNET_DEFAULT_HTTPS_PORT     equ 443
    WINHTTP_NO_REFERER              equ 0
    WINHTTP_DEFAULT_ACCEPT_TYPES    equ 0
    WINHTTP_FLAG_SECURE             equ 00800000h
    WINHTTP_NO_ADDITIONAL_HEADERS   equ 0
    WINHTTP_NO_REQUEST_DATA         equ 0

;   include files
;   ~~~~~~~~~~~~~
    include \masm32\include\windows.inc         ;- константы
    include \masm32\include\Kernel32.inc        ;- Kernel32
    include \masm32\include\User32.inc          ;- User32
    include \masm32\include\ole32.inc           ;- ole32
    include \masm32\include\Gdi32.inc           ;- Gdi
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
    ;WinHttp
    WinHttpOpen                 PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    WinHttpCloseHandle          PROTO STDCALL :DWORD
    WinHttpConnect              PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD
    WinHttpOpenRequest          PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    WinHttpAddRequestHeaders    PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD
    WinHttpSendRequest          PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    WinHttpReceiveResponse      PROTO STDCALL :DWORD,:DWORD
    WinHttpReadData             PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD
    WinHttpSetTimeouts          PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    
;   Types
;   ~~~~~
    SetProcessDPIAware  TYPEDEF PTR pr0
    WINHTTPAPI          TYPEDEF Dword
    QueryInterface_     TYPEDEF PTR pr3
    AddRef_             TYPEDEF PTR pr1
    Release_            TYPEDEF PTR pr1
    

;   Structure
;   ~~~~~~~~~    
IUnknown STRUCT
    QueryInterface          QueryInterface_ ?
    AddRef                  AddRef_         ?
    Release                 Release_        ?
IUnknown ENDS

.DATA

StdHOut HANDLE          ?
StdHIn  HANDLE          ?
hHeap   HANDLE          ?
evExit  HANDLE          ?
hDisp   HANDLE          ?
gdiTok  HANDLE          ?
hWNHTTP WINHTTPAPI      ?
cnn     WINHTTPAPI      ?
gdiInp  GdiplusStartupInput <1, 0, 0, 0>
scrMode BYTE    ToDrop
 
encPNG  GUID <557CF406h, 1A04h, 11D3h, {9Ah, 73h, 00h, 00h, 0F8h, 1Eh, 0F3h, 2Eh}>
strflt  WCHAR   'y','y','y','y','M','M','d','d','_','H','H','m','m','s','s','_','U','T','C', 0
        WCHAR   005Fh, 0048h, 0048h, 006Dh, 006Dh, 0073h, 0073h, 005Fh
        WCHAR   0055h, 0054h, 0043h, 0000h 
str001  WCHAR   0412h, 0432h, 0435h, 0434h, 0438h, 0442h, 0435h, 0020h	; Введите токен:
        WCHAR   0442h, 043Eh, 043Ah, 0435h, 043Dh, 003Ah, 0000h
str002  WCHAR   041Dh, 0430h, 0436h, 043Ch, 0438h, 0442h, 0435h, 0020h  ; Нажмите Enter для завершения
        WCHAR   0045h, 006Eh, 0074h, 0065h, 0072h, 0020h, 0434h, 043Bh
        WCHAR   044Fh, 0020h, 0437h, 0430h, 0432h, 0435h, 0440h, 0448h
        WCHAR   0435h, 043Dh, 0438h, 044Fh, 0000h
str003  WCHAR   '.','p','n','g',0
str004  WCHAR   'U','s','e','r','3','2','.','d','l','l',0
str006  WCHAR   's','c','r','e','e','n','M','a','k','e','r', 0
strPOST WCHAR   'P','O','S','T',0
strUPL  WCHAR   '/','2','/','f','i','l','e','s','/','u','p','l','o','a','d',0
strCNT  WCHAR   'c','o','n','t','e','n','t','.','d','r','o','p','b','o','x','a','p','i','.','c'
        WCHAR   'o','m',0
strAuth WCHAR   'A','u','t','h','o','r','i','z','a','t','i','o','n',':',' ','B','e','a','r','e'
        WCHAR   'r',' ','%','s',0dh,0ah,0
strPATH WCHAR   'D','r','o','p','b','o','x','-','A','P','I','-','A','r','g',':',' ','{','"','p'
        WCHAR   'a','t','h','"',':',' ','"','/','%','s','"','}',0dh,0ah,0
strCNTN WCHAR   'C','o','n','t','e','n','t','-','T','y','p','e',':',' ','a','p','p','l','i','c'
        WCHAR   'a','t','i','o','n','/','o','c','t','e','t','-','s','t','r','e','a','m',0dh,0ah,0
strA01  CHAR    'SetProcessDPIAware', 0
buffer  TCHAR   TokenSize + 1 DUP(?)       
        
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
        
        .IF scrMode == ToDrop
         ; соединение с Dropbox
         mov    hWNHTTP,        rv(WinHttpOpen, &str006, WINHTTP_ACCESS_TYPE_NO_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, NULL)
         fn     WinHttpSetTimeouts, hWNHTTP, 10000, 10000, 10000, 10000
         mov    cnn,            rv(WinHttpConnect, hWNHTTP, &strCNT, INTERNET_DEFAULT_HTTPS_PORT, NULL)
        
         ; запрос токена
         fn     stdWriteLn,     &str001
         fn     ReadConsole,    StdHIn, &buffer, TokenSize, &nWriten, NULL
                
         ; добавим ноль в конец строки
         mov    ecx,            nWriten
         dec    ecx
         shl    ecx,            1
         mov    WORD PTR [buffer + ecx - 2], 0
         mov    esi,            rv(HeapAlloc, hHeap, HEAP_NO_SERIALIZE, ecx)
         fn     lstrcpy,        esi, &buffer
        .ENDIF
        
        ; запускаем поток
        mov     evExit,         rv(CreateEvent, NULL, FALSE, FALSE, NULL)
        mov     esi,            rv(CreateThread,   NULL, NULL, MakeScreen, esi, NULL, NULL)

        ; ожидание завершения
        fn      stdWriteLn,     &str002
        fn      ReadConsole,    StdHIn, &bufWait, 2, &nWriten, NULL

        ; выход
        fn      SetEvent,       evExit
        fn      WaitForSingleObject, esi, INFINITE
        fn      ExitProcess, NULL
        RET        
main            ENDP

; создание и отправка скриншота
MakeScreen      PROC    USES esi edi, pToken:DWORD
        LOCAL lpFileName:DWORD, bitMap:DWORD, scrHght:DWORD, scrWdth:DWORD, pStrm:DWORD
        LOCAL HTTPReq:WINHTTPAPI, lpStrMem:DWORD 
        LOCAL TimeBigin:SYSTEMTIME, TimeEnd:SYSTEMTIME, fTime:FILETIME
        
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
         mov    esi,            rv(GetTimeFormat,  LOCALE_SYSTEM_DEFAULT, NULL, &TimeBigin, edi, NULL, NULL)
         lea    eax,            [esi*2 + 4*2]
         mov    lpFileName,     rv(HeapAlloc, hHeap, HEAP_NO_SERIALIZE, eax)
         fn     GetTimeFormat,  LOCALE_SYSTEM_DEFAULT, NULL, &TimeBigin, edi, lpFileName, esi
         fn     HeapFree,       hHeap, HEAP_NO_SERIALIZE, edi
         mov    eax,            lpFileName
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
         
         .IF scrMode == ToFile
          ; сохраняем в файл
          fn    GdipSaveImageToFile, bitMap, lpFileName, &encPNG, NULL
         .else
          ; сохраняем в память
          fn    CreateStreamOnHGlobal, NULL, TRUE, &pStrm  
          .IF   eax == S_OK
            
           ; запрос на отправку фото 
           mov  HTTPReq,        rv(WinHttpOpenRequest, cnn, &strPOST, &strUPL, NULL, WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_SECURE)
          
           ; аутентификация
           fn   wsprintf,       &buffer, &strAuth, pToken  
           fn   WinHttpAddRequestHeaders, HTTPReq, &buffer, -1, NULL
          
           ; имя файла
           fn   wsprintf,       &buffer, &strPATH, lpFileName
           fn   WinHttpAddRequestHeaders, HTTPReq, &buffer, -1, NULL
           fn   WinHttpAddRequestHeaders, HTTPReq, &strCNTN, -1, NULL
           
           ; тело файла
           fn   GdipSaveImageToStream, bitMap, pStrm, &encPNG, NULL
           fn   GetHGlobalFromStream, pStrm, &lpStrMem
           mov  esi,            rv(GlobalLock, lpStrMem)
           fn   GlobalSize,     lpStrMem
           fn   WinHttpSendRequest, HTTPReq, WINHTTP_NO_ADDITIONAL_HEADERS, -1, esi, eax, eax, NULL
            
           ; освобождаем память
           fn   GlobalUnlock,   lpStrMem
           fn   WinHttpCloseHandle, HTTPReq
           mov  ecx,            pStrm
           mov  ecx,            [ecx]
           fn   [ecx].IUnknown.Release, pStrm
          .ENDIF
         .ENDIF
         
         ;ожидание
         fn     HeapFree,       hHeap, HEAP_NO_SERIALIZE, lpFileName
         fn     GdipDisposeImage, bitMap
         
         ;время окончания загрузки
         fn     GetSystemTime,  &TimeEnd
         fn     SystemTimeToFileTime, &TimeEnd, &fTime
         mov    esi,            fTime.dwLowDateTime
         fn     SystemTimeToFileTime, &TimeBigin, &fTime
         sub    esi,            fTime.dwLowDateTime
         xor    edx,            edx
         mov    eax,            esi
         mov    ebx,            10000
         div    ebx
         mov    ebx,            5000
         sub    ebx,            eax

         .IF SIGN? 
          mov   ebx,            1
         .ENDIF
         fn    WaitForSingleObject, evExit, ebx
        .ENDW
        
        ; выход
        fn      GdiplusShutdown, gdiTok
        .IF scrMode == ToDrop
         fn     WinHttpCloseHandle, cnn
         fn     WinHttpCloseHandle, hWNHTTP
        .ENDIF
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