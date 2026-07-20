# Pupilfirst — Database Restore Script
# Usage: .\restore.ps1 .\backups\pupilfirst_db_YYYYMMDD_HHMMSS.sql

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile
)

if (-not (Test-Path $BackupFile)) {
    Write-Host "[ERROR] Backup file not found: $BackupFile" -ForegroundColor Red
    exit 1
}

Write-Host "Restoring Pupilfirst database from: $BackupFile" -ForegroundColor Cyan
Write-Host "WARNING: This will overwrite the current database!" -ForegroundColor Yellow
$confirm = Read-Host "Type 'yes' to continue"

if ($confirm -ne "yes") {
    Write-Host "Restore cancelled." -ForegroundColor Yellow
    exit 0
}

Get-Content $BackupFile | docker compose -f docker-compose.evaluation.yml exec -T pupilfirst-db psql `
  -U pupilfirst `
  -d pupilfirst_evaluation

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Database restored successfully." -ForegroundColor Green
} else {
    Write-Host "[FAILED] Restore failed." -ForegroundColor Red
}
