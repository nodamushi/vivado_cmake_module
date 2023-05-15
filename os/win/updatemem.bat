@echo off
rem run updatemem

set exe=%1
set mmi=%2
set bit=%3
set elf=%4
set out=%5
set procfile=%6

set /p proc=<%procfile%

"%exe%" -meminfo "%mmi%" -bit "%bit%" -proc "%proc%" -data "%elf%" -out "%out%"
