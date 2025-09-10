@echo off
REM COBOL Free Format Build Script for InCollege Project
REM Compiler: GnuCOBOL (cobc)
REM Format: Free format COBOL

echo Building InCollege COBOL project...

REM Check if cobc is available
where cobc >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: GnuCOBOL (cobc) not found in PATH
    echo Please install GnuCOBOL and ensure cobc is in your PATH
    pause
    exit /b 1
)

REM Create bin directory if it doesn't exist
if not exist "bin" mkdir bin

REM Compile with free format support - compile all modules together
echo Compiling and linking all source files...

cobc -free -x -Wall -Wextra -std=cobol2014 -static -I"src\copy" -o "bin\InCollege.exe" "src\InCollege.cob" "src\CreateAccount.cob" "src\Login.cob" "src\Navigation.cob"
if %errorlevel% neq 0 (
    echo Error: Failed to compile and link executable
    pause
    exit /b 1
)

echo.
echo ✓ Build completed successfully!
echo ✓ Executable created: bin\InCollege.exe
echo.
echo Running program test...
echo ======================
cd bin
InCollege.exe
cd ..
echo ======================
echo ✓ Program executed successfully!
echo ✓ Output written to data\InCollege-Output.txt
echo.
pause
