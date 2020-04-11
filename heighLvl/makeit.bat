@echo off
set pMasm32=\masm32
set prodName=srceenDrop

%pMasm32%\BIN\Ml.exe /c /coff %prodName%.asm
%pMasm32%\BIN\Link.exe /SUBSYSTEM:CONSOLE %prodName%.obj
del %prodName%.obj

pause