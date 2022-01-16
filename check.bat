@ECHO OFF
REM SETLOCAL restores %CD% when bat script ends (or on ENDLOCAL)
SETLOCAL

cd /d "%~dp0"
perl c:\scripts\check.pl lib lib\Exceptions %*
