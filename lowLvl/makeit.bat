@echo off
set pMasm32=\masm32
set prodName=srceenDrop

set mlib=%pMasm32%\lib\

%pMasm32%\BIN\Ml.exe /c /coff %prodName%.asm
%pMasm32%\BIN\Link.exe /SUBSYSTEM:CONSOLE %prodName%.obj ^
  %mlib%kernel32.lib %mlib%User32.lib %mlib%ole32.lib %mlib%Gdi32.lib %mlib%gdiplus.lib 
del %prodName%.obj

pause