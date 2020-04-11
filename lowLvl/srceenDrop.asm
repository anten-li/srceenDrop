.486
.MODEL  FLAT, STDCALL
OPTION  CASEMAP:NONE

;gdi32.dll
BitBlt PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateCompatibleBitmap PROTO STDCALL :DWORD,:DWORD,:DWORD
CreateCompatibleDC PROTO STDCALL :DWORD
DeleteDC PROTO STDCALL :DWORD
DeleteObject PROTO STDCALL :DWORD
SelectObject PROTO STDCALL :DWORD,:DWORD

;gdiplus.dll
GdipCreateBitmapFromHBITMAP PROTO STDCALL :DWORD,:DWORD,:DWORD
GdipDisposeImage PROTO STDCALL :DWORD
GdiplusShutdown PROTO STDCALL :DWORD
GdiplusStartup PROTO STDCALL :DWORD,:DWORD,:DWORD
GdipSaveImageToFile PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD

;kernel32.dll
CreateEventW PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD
CreateThread PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetDateFormatW PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetModuleHandleW PROTO STDCALL :DWORD
GetProcAddress PROTO STDCALL :DWORD,:DWORD
GetProcessHeap PROTO STDCALL
GetStdHandle PROTO STDCALL :DWORD
GetSystemTime PROTO STDCALL :DWORD
GetTimeFormatW PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
HeapAlloc PROTO STDCALL :DWORD,:DWORD,:DWORD
HeapFree PROTO STDCALL :DWORD,:DWORD,:DWORD
lstrcpyW PROTO STDCALL :DWORD,:DWORD
lstrlenW PROTO STDCALL :DWORD
ReadConsoleW PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetEvent PROTO STDCALL :DWORD
WaitForSingleObject PROTO STDCALL :DWORD,:DWORD
WriteConsoleW PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

;user32.dll
GetDC PROTO STDCALL :DWORD
GetSystemMetrics PROTO STDCALL :DWORD

.data

off_00403000 dd ?
off_00403004 dd ?
off_00403008 dd ?
off_0040300C dd ?
off_00403010 dd ?
off_00403014 dd ?
off_00403018 db 01h, 000h, 00h, 00h, 000h, 00h, 000h, 00h
             db 00h, 000h, 00h, 00h, 000h, 00h, 000h, 00h
off_00403028 db 06h, 0F4h, 7Ch, 55h, 004h, 1Ah, 0D3h, 11h
             db 9Ah, 073h, 00h, 00h, 0F8h, 1Eh, 0F3h, 2Eh
off_00403038 dw 'y','y','y','y','M','M','d','d','_','H','H','m','m','s','s','_','U','T','C', 0
off_00403060 db 1Dh, 04h, 30h, 04h, 36h, 04h, 3Ch, 04h 
             db 38h, 04h, 42h, 04h, 35h, 04h, 20h, 00h 
             db 45h, 00h, 6Eh, 00h, 74h, 00h, 65h, 00h 
             db 72h, 00h, 20h, 00h, 34h, 04h, 3Bh, 04h 
             db 4Fh, 04h, 20h, 00h, 37h, 04h, 30h, 04h 
             db 32h, 04h, 35h, 04h, 40h, 04h, 48h, 04h
             db 35h, 04h, 3Dh, 04h, 38h, 04h, 4Fh, 04h
             db 00h, 00h
off_0040309A dw '.','p','n','g',0
off_004030A4 dw 'U','s','e','r','3','2','.','d','l','l',0
off_004030BA db 'SetProcessDPIAware', 000h

.code

start:
    push ebp
    mov ebp, esp
    add esp, 0FFFFFFF8h
    push esi
    push 0FFFFFFF5h
    call GetStdHandle

    mov [off_00403000], eax
    push 0FFFFFFF6h
    call GetStdHandle

    mov [off_00403004], eax
    call GetProcessHeap

    mov [off_00403008], eax
    push 0
    call GetDC

    mov [off_00403010], eax
    push 0
    push offset off_00403018
    push offset off_00403014
    call GdiplusStartup

    push offset off_004030A4
    call GetModuleHandleW

    or eax, eax
    jz lbl0
    mov ecx, eax
    push offset off_004030BA
    push ecx
    call GetProcAddress

    or eax, eax
    jz lbl0
    call eax

  lbl0:
    xor esi, esi
    push 0
    push 0
    push 0
    push 0
    call CreateEventW

    mov [off_0040300C], eax
    push 0
    push 0
    push esi
    push offset off_004010BF
    push 0
    push 0
    call CreateThread

    push offset off_00403060
    call fn_00401247

    push 0
    lea eax, [ebp-4]
    push eax
    push 2
    lea eax, [ebp-8]
    push eax
    push DWORD PTR [off_00403004]
    call ReadConsoleW

    push DWORD PTR [off_0040300C]
    call SetEvent

    xor eax, eax
    pop esi
    leave
    ret

off_004010BF:
    push ebp
    mov ebp, esp
    add esp, 0FFFFFFDCh
    push esi
    push edi
    mov eax, 102h
    jmp lbl2

  lbl1:
    lea eax, [ebp-10h]
    push eax
    call GetSystemTime

    push 0
    push 0
    push offset off_00403038
    lea eax, [ebp-10h]
    push eax
    push 0
    push 800h
    call GetDateFormatW

    mov esi, eax
    shl eax, 1
    push eax
    push 1
    push DWORD PTR [off_00403008]
    call HeapAlloc

    mov edi, eax
    push esi
    push edi
    push offset off_00403038
    lea eax, [ebp-10h]
    push eax
    push 0
    push 800h
    call GetDateFormatW

    push 0
    push 0
    push edi
    lea eax, [ebp-10h]
    push eax
    push 0
    push 800h
    call GetTimeFormatW

    mov esi, eax
    add eax, 4
    shl eax, 1
    push eax
    push 1
    push DWORD PTR [off_00403008]
    call HeapAlloc

    mov [ebp-14h], eax
    push esi
    push DWORD PTR [ebp-14h]
    push edi
    lea eax, [ebp-10h]
    push eax
    push 0
    push 800h
    call GetTimeFormatW

    push edi
    push 1
    push DWORD PTR [off_00403008]
    call HeapFree

    mov eax, [ebp-14h]
    push offset off_0040309A
    lea eax, [eax+esi*2-2]
    push eax
    call lstrcpyW

    push 0
    call GetSystemMetrics

    mov [ebp-20h], eax
    push 1
    call GetSystemMetrics

    mov [ebp-1Ch], eax
    push DWORD PTR [ebp-1Ch]
    push DWORD PTR [ebp-20h]
    push DWORD PTR [off_00403010]
    call CreateCompatibleBitmap

    mov esi, eax
    push DWORD PTR [off_00403010]
    call CreateCompatibleDC

    mov edi, eax
    push esi
    push edi
    call SelectObject

    push 0CC0020h
    push 0
    push 0
    push DWORD PTR [off_00403010]
    push DWORD PTR [ebp-1Ch]
    push DWORD PTR [ebp-20h]
    push 0
    push 0
    push edi
    call BitBlt

    lea eax, [ebp-18h]
    push eax
    push 0
    push esi
    call GdipCreateBitmapFromHBITMAP

    push edi
    call DeleteDC

    push esi
    call DeleteObject

    push 0
    push offset off_00403028
    push DWORD PTR [ebp-14h]
    push DWORD PTR [ebp-18h]
    call GdipSaveImageToFile

    push DWORD PTR [ebp-14h]
    push 1
    push DWORD PTR [off_00403008]
    call HeapFree

    push DWORD PTR [ebp-18h]
    call GdipDisposeImage

    push 1770h
    push DWORD PTR [off_0040300C]
    call WaitForSingleObject

  lbl2:
    or eax, eax
    jne lbl1
    push DWORD PTR [off_00403014]
    call GdiplusShutdown

    xor eax, eax
    pop edi
    pop esi
    leave
    ret 4

; ----------------------------
fn_00401247:

    push ebp
    mov ebp, esp
    add esp, 0FFFFFFF8h
    mov DWORD PTR [ebp-8], 0Ah
    push DWORD PTR [ebp+8]
    call lstrlenW

    mov ecx, eax
    push 0
    lea eax, [ebp-4]
    push eax
    push ecx
    push DWORD PTR [ebp+8]
    push DWORD PTR [off_00403000]
    call WriteConsoleW

    push 0
    lea eax, [ebp-4]
    push eax
    push 1
    lea eax, [ebp-8]
    push eax
    push DWORD PTR [off_00403000]
    call WriteConsoleW

    leave
    ret 4
    
end start     
