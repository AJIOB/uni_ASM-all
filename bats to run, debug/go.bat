@echo off
cls
tasm ..\Files\%1\%1,..\Files\%1\%1
tlink ..\Files\%1\%1,..\Files\%1\%1,..\Files\%1\%1
..\Files\%1\%1
newline