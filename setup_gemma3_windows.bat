@echo off
echo ================================================
echo    Marhaba App - Gemma 3 Setup for Windows
echo ================================================
echo.

echo Checking if Ollama is installed...
ollama --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Ollama is not installed or not in PATH
    echo.
    echo Please install Ollama first:
    echo 1. Visit: https://ollama.ai/download
    echo 2. Download and install Ollama for Windows
    echo 3. Restart this script after installation
    echo.
    pause
    exit /b 1
)

echo ✓ Ollama is installed
echo.

echo Starting Ollama service...
start /B ollama serve
timeout /t 3 >nul

echo Checking if Gemma 3 model is available...
ollama list | findstr "gemma:3b" >nul
if %errorlevel% equ 0 (
    echo ✓ Gemma 3 model is already installed
    goto :test_model
)

echo Gemma 3 model not found. Downloading now...
echo This may take several minutes (approximately 2GB download)
echo.
ollama pull gemma:3b

if %errorlevel% neq 0 (
    echo ERROR: Failed to download Gemma 3 model
    echo Please check your internet connection and try again
    pause
    exit /b 1
)

echo ✓ Gemma 3 model downloaded successfully

:test_model
echo.
echo Testing Gemma 3 model...
echo.
ollama run gemma:3b "Hello, how can you help refugees?" --timeout 30s

if %errorlevel% neq 0 (
    echo WARNING: Model test failed, but installation appears complete
) else (
    echo ✓ Model test successful
)

echo.
echo ================================================
echo           Setup Complete!
echo ================================================
echo.
echo Gemma 3 is now ready for the Marhaba app.
echo You can now launch the Flutter app.
echo.
echo The app will work completely offline once this setup is complete.
echo.
pause
