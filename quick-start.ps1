# =====================================================================
# DRP Pro - Quick Start PowerShell Script
# =====================================================================
# PowerShell automation script for rapid DRP Pro setup on Windows
# Requires: PowerShell 5.0+ (Windows 10/11)
#
# Features:
#   - Automated Git repository clone
#   - Environment variable configuration
#   - Folder structure creation
#   - Basic validation and error checking
#   - Optional Docker setup
#
# Usage:
#   1. Open PowerShell as Administrator
#   2. Run: .\quick-start.ps1
#   3. Follow the prompts
# =====================================================================

# Set up error handling
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

# Define color functions for console output
function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# Banner
Clear-Host
Write-Host " " -ForegroundColor Green
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║          DRP Pro - Quick Start Setup                          ║" -ForegroundColor Green
Write-Host "║    Djarum Retail Partner Hub System - Windows Installer       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host " " -ForegroundColor Green

# Step 1: Check Administrator Rights
Write-Info "Step 1: Checking administrator privileges..."
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires administrator privileges!"
    Write-Warning "Please run PowerShell as Administrator and try again."
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Success "Administrator privileges confirmed."

# Step 2: Check Prerequisites
Write-Info "Step 2: Checking prerequisites..."

# Check Git
$gitPath = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitPath) {
    Write-Error "Git is not installed or not in PATH!"
    Write-Warning "Please install Git for Windows from: https://git-scm.com/download/win"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Success "Git found: $(git --version)"

# Check Node.js (Optional)
$nodePath = Get-Command node -ErrorAction SilentlyContinue
if ($nodePath) {
    Write-Success "Node.js found: $(node --version)"
} else {
    Write-Warning "Node.js not found (optional for API development)"
}

# Step 3: Get Installation Path
Write-Info "Step 3: Selecting installation directory..."
$installPath = Read-Host "Enter installation path (default: C:\\DRP-Pro) [Press Enter for default]"
if ([string]::IsNullOrWhiteSpace($installPath)) {
    $installPath = "C:\DRP-Pro"
}

# Create directory if it doesn't exist
if (-not (Test-Path $installPath)) {
    try {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        Write-Success "Created installation directory: $installPath"
    } catch {
        Write-Error "Failed to create directory: $_"
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Info "Installation directory: $installPath"

# Step 4: Clone Repository
Write-Info "Step 4: Cloning DRP Pro repository..."
try {
    $repoPath = Join-Path $installPath "drp-pro-retail-system"
    
    if (Test-Path $repoPath) {
        Write-Warning "Repository already exists at: $repoPath"
        $response = Read-Host "Overwrite existing installation? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Remove-Item -Path $repoPath -Recurse -Force
            Write-Info "Removed existing installation."
        } else {
            Write-Info "Installation cancelled."
            exit 0
        }
    }
    
    git clone https://github.com/rendyafx-arch/drp-pro-retail-system.git $repoPath
    Write-Success "Repository cloned successfully."
} catch {
    Write-Error "Failed to clone repository: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 5: Set Up Environment
Write-Info "Step 5: Setting up environment configuration..."
try {
    Set-Location $repoPath
    
    # Create .env from template
    if (Test-Path ".env.example") {
        if (Test-Path ".env") {
            Rename-Item ".env" ".env.backup" -Force
            Write-Info "Backed up existing .env to .env.backup"
        }
        
        Copy-Item ".env.example" ".env"
        Write-Success ".env configuration file created."
    } else {
        Write-Warning ".env.example not found in repository."
    }
} catch {
    Write-Error "Failed to set up environment: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 6: Create Required Folders
Write-Info "Step 6: Creating folder structure..."
try {
    $folders = @(
        "backups",
        "logs",
        "data",
        "temp"
    )
    
    foreach ($folder in $folders) {
        $folderPath = Join-Path $repoPath $folder
        if (-not (Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            Write-Info "Created folder: $folder"
        }
    }
    Write-Success "Folder structure created."
} catch {
    Write-Error "Failed to create folders: $_"
}

# Step 7: Display Configuration Instructions
Write-Info "Step 7: Configuration required..."
Write-Host " " 
Write-Host "========== NEXT STEPS =========" -ForegroundColor Cyan
Write-Host "" 
Write-Host "1. EDIT CONFIGURATION:" -ForegroundColor Yellow
Write-Host "   - Open the .env file in your favorite editor"
Write-Host "   - Configure Supabase credentials"
Write-Host "   - Configure Power Apps credentials"
Write-Host "   - Configure database connection settings"
Write-Host " "
Write-Host "2. INITIALIZE DATABASE:" -ForegroundColor Yellow
Write-Host "   - Visit: https://supabase.com"
Write-Host "   - Create a new project"
Write-Host "   - Run database/schema.sql in SQL Editor"
Write-Host " "
Write-Host "3. DEPLOY POWER APPS:" -ForegroundColor Yellow
Write-Host "   - Go to: https://make.powerapps.com"
Write-Host "   - Follow setup-guides/POWERAPPS_SETUP.md"
Write-Host " "
Write-Host "4. CONFIGURE POWER AUTOMATE:" -ForegroundColor Yellow
Write-Host "   - Go to: https://make.powerautomate.com"
Write-Host "   - Follow setup-guides/POWER_AUTOMATE_SETUP.md"
Write-Host " "
Write-Host "5. READ DOCUMENTATION:" -ForegroundColor Yellow
Write-Host "   - docs/FEATURES.md - Feature overview"
Write-Host "   - docs/ARCHITECTURE.md - System architecture"
Write-Host "   - docs/DATABASE.md - Database schema"
Write-Host "   - docs/API.md - API endpoints"
Write-Host " "
Write-Host "========== PATHS =========" -ForegroundColor Cyan
Write-Host "Installation: $repoPath"
Write-Host "Config File: $(Join-Path $repoPath '.env')"
Write-Host "Documentation: $(Join-Path $repoPath 'docs')"
Write-Host "Database Script: $(Join-Path $repoPath 'database\schema.sql')"
Write-Host " "
Write-Host "========== OPTIONAL: DOCKER SETUP =========" -ForegroundColor Cyan
$dockerResponse = Read-Host "Do you want to set up Docker? (y/n)"
if ($dockerResponse -eq 'y' -or $dockerResponse -eq 'Y') {
    $dockerPath = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerPath) {
        Write-Info "Docker found. You can use docker-compose.yml to run the system."
        Write-Info "Command: docker-compose up -d"
    } else {
        Write-Warning "Docker is not installed."
        Write-Warning "Download Docker Desktop from: https://www.docker.com/products/docker-desktop"
    }
}

Write-Host " " 
Write-Success "DRP Pro has been successfully set up!"
Write-Host " " 
Write-Info "For support, visit: https://github.com/rendyafx-arch/drp-pro-retail-system"
Write-Host " " 

# Wait before closing
Read-Host "Press Enter to complete setup"

exit 0
