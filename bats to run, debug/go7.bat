@echo off
cls
SET var1=lab7
tasm ..\Files\%var1%\%var1%,..\Files\%var1%\%var1%
tlink ..\Files\%var1%\%var1%,..\Files\%var1%\%var1%,..\Files\%var1%\%var1%
..\Files\%var1%\%var1% c:\Files\%var1%\testf

cd c:\AJIOB.T\

newline