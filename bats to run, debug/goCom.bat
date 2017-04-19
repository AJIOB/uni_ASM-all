@echo off
cls
SET var1=%1
tasm ..\Files\%var1%\%var1%,..\Files\%var1%\%var1%
tlink /t /x ..\Files\%var1%\%var1%,..\Files\%var1%\%var1%,..\Files\%var1%\%var1%
..\Files\%var1%\%var1%.com 14 20 30 00 00 10
newline