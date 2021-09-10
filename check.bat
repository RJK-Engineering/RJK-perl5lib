@echo off
set PREVD="%CD%"
cd /d "%~dp0"
perl c:\scripts\check.pl lib lib\Exceptions %*
cd /d %PREVD%
