@echo off
REM COBOL Clean Script for InCollege Project
REM Removes all generated object files and executables

echo Cleaning generated files...

REM Remove object files
if exist "bin\*.o" (
    echo Removing object files...
    del /q "bin\*.o"
)

REM Remove executable
if exist "bin\InCollege.exe" (
    echo Removing executable...
    del /q "bin\InCollege.exe"
)

REM Remove Linux executable if it exists
if exist "bin\InCollege" (
    echo Removing Linux executable...
    del /q "bin\InCollege"
)

REM Clear output file content (don't delete the file)
if exist "data\InCollege-Output.txt" (
    echo Clearing output file content...
    echo. > "data\InCollege-Output.txt"
)

REM Remove temporary files
if exist "*.tmp" (
    echo Removing temporary files...
    del /q "*.tmp"
)

if exist "*.bak" (
    echo Removing backup files...
    del /q "*.bak"
)

if exist "core" (
    echo Removing core dumps...
    del /q "core"
)

if exist "*.log" (
    echo Removing log files...
    del /q "*.log"
)

REM Remove bin directory if empty
if exist "bin" (
    rmdir "bin" 2>nul
    if %errorlevel% equ 0 (
        echo Removed empty bin directory
    )
)

echo.
echo ✓ Clean completed!
echo ✓ All generated files removed and output files cleared
echo.
pause
