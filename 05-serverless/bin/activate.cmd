@echo off
rem Makes node, npm, npx and sls in this cmd.exe window run inside Docker.
rem   Usage:  bin\activate.cmd
rem   Undo:   close the window
set "PATH=%~dp0;%PATH%"
echo node, npm, npx and sls now run inside Docker (this window only).
