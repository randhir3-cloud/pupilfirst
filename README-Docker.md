# Pupilfirst LMS — Docker Evaluation Guide

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) ≥ 4.x
- Port **3002** available on the host
- 4 GB RAM recommended

> **Build time:** `Dockerfile.evaluation` installs Ruby gems, Node modules, compiles ReScript, and builds Vite assets. First build takes **10–20 minutes**.

## How This Works

This evaluation setup uses the project's **official `Dockerfile.evaluation`** — unchanged.
It automatically:
1. Loads the database schema on first boot
2. Seeds the database with sample data
3. Starts the Rails server

The `bin/evaluate` script handles initialization automatically.

## Quick Start

```powershell
# 1. Copy environment file
Copy-Item .env.example .env

# 2. Build and start the stack
docker compose -f docker-compose.evaluation.yml up -d

# 3. Wait ~3 minutes for Rails to compile and seed data, then open:
#    http://localhost:3002
```

## Default Credentials

| Field    | Value                    |
|----------|--------------------------|
| URL      | http://localhost:3002    |
| Email    | `admin@example.com`      |
| Mode     | Developer sign-in (seed) |

> Pupilfirst uses a "Developer sign-in" in development mode — no password required.
> In production mode (as configured here), use email-based OTP login.

## Commands

```powershell
# Start stack (evaluation compose)
docker compose -f docker-compose.evaluation.yml up -d

# Stop stack
docker compose -f docker-compose.evaluation.yml down

# Full reset (removes all data)
docker compose -f docker-compose.evaluation.yml down -v

# View all logs
docker compose -f docker-compose.evaluation.yml logs -f

# View specific service logs
docker compose -f docker-compose.evaluation.yml logs pupilfirst-web
docker compose -f docker-compose.evaluation.yml logs pupilfirst-worker

# Check service status
docker compose -f docker-compose.evaluation.yml ps

# Open Rails console
docker compose -f docker-compose.evaluation.yml exec pupilfirst-web bundle exec rails console
```

## Optional: pgAdmin (Database Browser)

```powershell
docker compose -f docker-compose.evaluation.yml --profile tools up -d

# pgAdmin URL: http://localhost:5053
# Email:    admin@local.dev
# Password: pgadmin_secret
#
# Add server in pgAdmin:
#   Host:     pupilfirst-db
#   Port:     5432
#   Database: pupilfirst_evaluation
#   Username: pupilfirst
#   Password: pupilfirst
```

## How to Reset Database

```powershell
docker compose -f docker-compose.evaluation.yml down -v
docker compose -f docker-compose.evaluation.yml up -d
```

Database schema + seed will be reloaded automatically on first boot.

## Backup & Restore

```powershell
.\backup.ps1
.\restore.ps1 .\backups\pupilfirst_db_YYYYMMDD_HHMMSS.sql
```

## Persistent Volumes

| Volume                    | Contents                    |
|---------------------------|-----------------------------|
| `pupilfirst-pgdata`       | PostgreSQL database         |
| `pupilfirst-redisdata`    | Redis data                  |
| `pupilfirst-storage`      | ActiveStorage uploads       |
| `pupilfirst-log`          | Rails logs                  |

## Note on File Uploads (AWS S3)

Pupilfirst is designed to use AWS S3 for file uploads.
For local evaluation, dummy AWS credentials are set and S3 uploads will fail silently.
Files stored via ActiveStorage will use local disk storage (`storage/` volume).

To enable real S3 uploads, set real AWS credentials in `.env`.

## Troubleshooting

**Web container restarting:**
```powershell
docker compose -f docker-compose.evaluation.yml logs pupilfirst-web | tail -30
# Usually a DB connection or seed error — ensure DB is healthy first
docker compose -f docker-compose.evaluation.yml ps pupilfirst-db
```

**Sidekiq worker errors:**
```powershell
docker compose -f docker-compose.evaluation.yml logs pupilfirst-worker
```
Worker errors are usually harmless for basic evaluation (OAuth callbacks, email delivery).
