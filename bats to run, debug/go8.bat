@echo off
cls
SET var1=lab8
tasm ..\Files\%var1%\%var1%,..\Files\%var1%\%var1%
tlink /t /x ..\Files\%var1%\%var1%,..\Files\%var1%\%var1%,..\Files\%var1%\%var1%
..\Files\%var1%\%var1%.com 22 42 40 00 00 10
newline