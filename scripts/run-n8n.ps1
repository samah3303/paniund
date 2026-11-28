# Quick launcher script for self-hosted n8n container
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Starting paniund n8n Automation Engine  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Docker is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Check if .env.n8n exists; if not, create from template
$envFile = Join-Path $PSScriptRoot "..\.env.n8n"
$envExample = Join-Path $PSScriptRoot "..\.env.n8n.example"

if (-not (Test-Path $envFile)) {
    Write-Host "[INFO] Creating .env.n8n from template..." -ForegroundColor Yellow
    Copy-Item $envExample $envFile
    Write-Host "[INFO] Created .env.n8n. You can configure your DEEPSEEK_API_KEY and tokens inside it." -ForegroundColor Green
}

# Start n8n container
Write-Host "[INFO] Launching n8n container..." -ForegroundColor Cyan
docker compose -f docker-compose.n8n.yml --env-file .env.n8n up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host " SUCCESS: n8n is running in the background!" -ForegroundColor Green
    Write-Host " Web UI URL: http://localhost:5678" -ForegroundColor Green
    Write-Host " To stop: npm run n8n:stop  (or: docker compose -f docker-compose.n8n.yml down)" -ForegroundColor Yellow
} else {
    Write-Host "[ERROR] Failed to start Docker container." -ForegroundColor Red
}
