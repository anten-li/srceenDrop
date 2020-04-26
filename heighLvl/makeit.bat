@echo off
set pMasm32=\masm32\BIN
rem set pMasm32=D:\Program\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.24.28314\bin\Hostx86\x86
set prodName=srceenDrop

"%pMasm32%\polib.exe" /def:WinHttp.def /out:WinHttp.lib /machine:x86

"%pMasm32%\Ml.exe" /c /coff %prodName%.asm
"%pMasm32%\Link.exe" /SUBSYSTEM:CONSOLE %prodName%.obj WinHttp.lib
del %prodName%.obj
del WinHttp.lib
del WinHttp.exp

pause