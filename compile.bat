@ECHO OFF
SET SCRIPT_DIR=%~DP0%
SET SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
SET SCRIPT_PATH=%SCRIPT_DIR%\compile.py
WHERE python3 /Q || ECHO Could not find python3 interpreter && EXIT /B
python3 "%SCRIPT_PATH%"
