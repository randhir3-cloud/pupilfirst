# Pupilfirst — Database Backup Script
# Usage: .\backup.ps1

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "$PSScriptRoot\backups"
$backupFile = "$backupDir\pupilfirst_db_$timestamp.sql"

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Backing up Pupilfirst PostgreSQL database..." -ForegroundColor Cyan

docker compose -f docker-compose.evaluation.yml exec -T pupilfirst-db pg_dump `
  -U pupilfirst `
  -d pupilfirst_evaluation `
  --clean `
  --if-exists `
  --no-owner `
  --no-acl `
  | Out-File -FilePath $backupFile -Encoding UTF8

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Backup saved to: $backupFile" -ForegroundColor Green
} else {
    Write-Host "[FAILED] Backup failed. Is the stack running?" -ForegroundColor Red
}
