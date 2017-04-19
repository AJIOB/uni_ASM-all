@echo off
cls
tasm ..\Files\lab5\lab5,..\Files\lab5\lab5
tlink ..\Files\lab5\lab5,..\Files\lab5\lab5,..\Files\lab5\lab5
..\Files\lab5\lab5 c:\Files\lab5\text.txt c:\Files\lab5\res.txt
newline