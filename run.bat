@ECHO OFF
SET SCRIPT_DIR=%~DP0%
SET SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
SET SCRIPT_PATH=%SCRIPT_DIR%\run.py
WHERE python /Q || ECHO Could not find python interpreter && EXIT /B
python "%SCRIPT_PATH%" %*
