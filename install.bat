@echo off
REM =====================================================================
REM DRP Pro - Djarum Retail Partner Hub System
REM Windows Installation Script (install.bat)
REM =====================================================================
REM This script automates the installation and setup of DRP Pro
REM for Windows environments with Supabase backend and Power Apps frontend.
REM
REM Prerequisites:
REM   - Git for Windows
REM   - Node.js 18+ or npm for optional API development
REM   - Windows 10/11
REM
REM Usage:
REM   1. Download this file to your local directory
REM   2. Right-click and select "Run as administrator"
REM   3. Follow the prompts
REM =====================================================================

setlocal enabledelayedexpansion

REM Set color for console output
color 0A

echo.
echo =====================================================================
echo DRP Pro - Installation Wizard
echo =====================================================================
echo.
echo This script will help you set up DRP Pro on your Windows system.
echo.
pause

REM Check if running as administrator
openfiles >nul 2>&1
if errorlevel 1 (
    echo ERROR: This script must be run as Administrator!
    echo Please right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Step 1: Checking prerequisites...
echo.

REM Check for Git
where /q git
if errorlevel 1 (
    echo WARNING: Git not found in PATH
    echo Please install Git from https://git-scm.com/download/win
    echo Then run this script again
    pause
    exit /b 1
) else (
    echo [OK] Git is installed
    git --version
)

echo.
echo Step 2: Getting installation path...
echo.
echo Where would you like to install DRP Pro?
echo Current directory: %cd%
set /p INSTALL_PATH="Enter installation path (press Enter for current directory): "
if "%INSTALL_PATH%"==" " (
    set INSTALL_PATH=%cd%
)

REM Remove trailing backslash if present
if "%INSTALL_PATH:~-1%"==" " set INSTALL_PATH=%INSTALL_PATH:~0,-1%

echo Selected path: %INSTALL_PATH%

REM Create installation directory if it doesn't exist
if not exist "%INSTALL_PATH%" (
    echo Creating installation directory...
    mkdir "%INSTALL_PATH%"
    if errorlevel 1 (
        echo ERROR: Failed to create directory
        pause
        exit /b 1
    )
)

echo.
echo Step 3: Cloning repository...
echo.
cd /d "%INSTALL_PATH%"

if exist "drp-pro-retail-system" (
    echo Directory "drp-pro-retail-system" already exists.
    echo Would you like to overwrite it? (Y/N)
    set /p OVERWRITE=" "
    if /i "!OVERWRITE!"=="Y" (
        echo Removing existing directory...
        rmdir /s /q "drp-pro-retail-system"
    ) else (
        echo Installation cancelled.
        pause
        exit /b 0
    )
)

echo Cloning DRP Pro repository...
git clone https://github.com/rendyafx-arch/drp-pro-retail-system.git
if errorlevel 1 (
    echo ERROR: Failed to clone repository
    pause
    exit /b 1
)

cd "drp-pro-retail-system"
echo Repository cloned successfully

echo.
echo Step 4: Setting up environment configuration...
echo.

if exist ".env" (
    echo .env file already exists. Creating backup...
    ren ".env" ".env.backup"
)

echo Copying .env.example to .env...
copy ".env.example" ".env"
if errorlevel 1 (
    echo ERROR: Failed to copy .env.example
    pause
    exit /b 1
)

echo.
echo Step 5: Configuring environment variables...
echo.
echo Please configure the following settings in .env file:
echo.
echo Supabase Configuration:
echo   - SUPABASE_URL: Your Supabase project URL
echo   - SUPABASE_ANON_KEY: Your Supabase anonymous key
echo   - SUPABASE_SERVICE_KEY: Your Supabase service key
echo.
echo Power Apps Configuration:
echo   - POWERAPPS_TENANT_ID: Your Microsoft tenant ID
echo   - POWERAPPS_CLIENT_ID: Your Power Apps application ID
echo   - POWERAPPS_CLIENT_SECRET: Your Power Apps application secret
echo   - POWERAPPS_ENVIRONMENT_URL: Your Power Apps environment URL
echo.
echo Database Configuration:
echo   - DB_HOST: Database host (usually localhost for local setup)
echo   - DB_PORT: Database port (default 5432 for PostgreSQL)
echo   - DB_NAME: Database name (usually drp_pro)
echo   - DB_USER: Database user
echo   - DB_PASSWORD: Database password
echo.

echo Opening .env file for editing...
echo.
pause

REM Open .env file in default text editor
start .env

echo Please save the .env file after making your changes.
pause

echo.
echo Step 6: Installation complete!
echo.
echo Next steps:
echo   1. Configure your .env file with Supabase and Power Apps credentials
echo   2. Set up your Supabase database using setup-guides/SUPABASE_SETUP.md
echo   3. Deploy Power Apps using setup-guides/POWERAPPS_SETUP.md
echo   4. Configure Power Automate flows using setup-guides/POWER_AUTOMATE_SETUP.md
echo.
echo For detailed documentation, see:
echo   - docs/FEATURES.md: System features overview
echo   - docs/ARCHITECTURE.md: System architecture
echo   - docs/DATABASE.md: Database schema
echo   - docs/API.md: API endpoints
echo.
echo Installation directory: %cd%
echo.
echo For more information, visit: https://github.com/rendyafx-arch/drp-pro-retail-system
echo.
pause
exit /b 0
