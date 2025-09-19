Param(
  [Parameter(Position=0)][string]$Command = 'start'
)

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$JarPath = Join-Path $ProjectRoot 'stocky-api/target/stocky-api.jar'
$Profile = 'offline'

function Ensure-Java {
  if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error 'Java (JDK 17+) is required but not found in PATH'
    exit 1
  }
  $versionLine = (java -version 2>&1 | Select-String 'version').ToString()
  if ($versionLine -match '"([0-9]+)') {
    $major = [int]$Matches[1]
    if ($major -lt 17) {
      Write-Error "Java 17+ required. Detected: $versionLine"
      exit 1
    }
  }
}

function Setup {
  Write-Host '[INFO] Building project (frontend + backend) ...'
  Push-Location (Join-Path $ProjectRoot 'stocky-api')
  ./mvnw -q -DskipTests package
  Pop-Location
  Write-Host "[INFO] Build complete: $JarPath"
}

function Start-App {
  if (-not (Test-Path $JarPath)) {
    Write-Host '[INFO] JAR not found. Running setup first...'
    Setup
  }
  $dataDir = Join-Path $ProjectRoot 'stocky-api/data/h2'
  New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
  Write-Host "[INFO] Starting Stocky (profile=$Profile) on http://localhost:8080"
  & java -jar $JarPath --spring.profiles.active=$Profile
}

function Clean {
  Write-Host '[INFO] Cleaning build artifacts & local data'
  Push-Location (Join-Path $ProjectRoot 'stocky-api')
  ./mvnw -q clean
  Pop-Location
  Remove-Item -Recurse -Force (Join-Path $ProjectRoot 'stocky-api/data') -ErrorAction SilentlyContinue
  Write-Host '[INFO] Clean complete'
}

function Show-Help {
  @'
Usage: ./run.ps1 [Command]
Commands:
  setup   Build everything (downloads dependencies) without starting
  start   Build if needed then run the self-contained server (default)
  clean   Remove build outputs and local H2 data
  help    Show this help
'@
}

Ensure-Java
switch ($Command) {
  'setup' { Setup }
  'start' { Start-App }
  'clean' { Clean }
  'help' { Show-Help }
  default { Write-Host "Unknown command: $Command"; Show-Help; exit 1 }
}
