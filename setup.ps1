# Script to setup the benchmarking tools - PowerShell
# Usage: .\setup.ps1

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  REST Performance Benchmark Setup         ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Java
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if ($javaCmd) {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "✓ Java $javaVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Java not found" -ForegroundColor Red
    exit 1
}

# Maven
$mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue
if ($mvnCmd) {
    $mvnVersion = mvn -version 2>&1 | Select-Object -First 1
    Write-Host "✓ Maven $mvnVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Maven not found" -ForegroundColor Red
    exit 1
}

# Docker
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerCmd) {
    $dockerVersion = docker --version
    Write-Host "✓ Docker $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Docker not found" -ForegroundColor Red
    exit 1
}

# Docker Compose
$composeCmd = Get-Command docker -ErrorAction SilentlyContinue
if ($composeCmd) {
    $composeVersion = docker compose version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker Compose $composeVersion" -ForegroundColor Green
    } else {
        $composeVersion = docker-compose --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Docker Compose $composeVersion" -ForegroundColor Green
        } else {
            Write-Host "✗ Docker Compose not found" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "✗ Docker Compose not found" -ForegroundColor Red
    exit 1
}

# JMeter
$jmeterCmd = Get-Command jmeter -ErrorAction SilentlyContinue
if ($jmeterCmd) {
    $jmeterVersion = jmeter --version 2>&1 | Select-Object -First 1
    Write-Host "✓ JMeter $jmeterVersion" -ForegroundColor Green
} else {
    Write-Host "⚠ JMeter not found in PATH" -ForegroundColor Yellow
    Write-Host "  Please install JMeter or add it to PATH" -ForegroundColor Yellow
}

Write-Host ""

# Build applications
Write-Host "Building applications..." -ForegroundColor Yellow
mvn clean install -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Build successful" -ForegroundColor Green
} else {
    Write-Host "✗ Build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Start infrastructure
Write-Host "Starting infrastructure (PostgreSQL, Prometheus, Grafana, InfluxDB)..." -ForegroundColor Yellow
Push-Location docker

# Try docker compose (newer) first, fallback to docker-compose
docker compose up -d postgres prometheus grafana influxdb 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    docker-compose up -d postgres prometheus grafana influxdb
}

Pop-Location

Write-Host "Waiting for services to start (45s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 45

# Check services
Write-Host ""
Write-Host "Checking service health..." -ForegroundColor Yellow

# Prometheus
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Prometheus is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Prometheus is not responding" -ForegroundColor Red
}

# Grafana
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Grafana is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Grafana might still be starting" -ForegroundColor Yellow
}

# InfluxDB
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8086/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ InfluxDB is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ InfluxDB is not responding" -ForegroundColor Red
}

# PostgreSQL
Push-Location docker
$result = docker exec benchmark-postgres pg_isready -U benchmark 2>&1
Pop-Location
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PostgreSQL is healthy" -ForegroundColor Green
} else {
    Write-Host "✗ PostgreSQL is not responding" -ForegroundColor Red
}

Write-Host ""

# Verify database
Write-Host "Verifying database initialization..." -ForegroundColor Yellow
Push-Location docker
$categoryCount = docker exec benchmark-postgres psql -U benchmark -d benchmark -t -c "SELECT COUNT(*) FROM category;" 2>&1 | ForEach-Object { $_.Trim() }
$itemCount = docker exec benchmark-postgres psql -U benchmark -d benchmark -t -c "SELECT COUNT(*) FROM item;" 2>&1 | ForEach-Object { $_.Trim() }
Pop-Location

if ($categoryCount -match '^\d+$' -and $itemCount -match '^\d+$') {
    if ([int]$categoryCount -ge 2000 -and [int]$itemCount -ge 100000) {
        Write-Host "✓ Database initialized: $categoryCount categories, $itemCount items" -ForegroundColor Green
    } else {
        Write-Host "⚠ Database might still be initializing" -ForegroundColor Yellow
        Write-Host "  Categories: $categoryCount / 2000" -ForegroundColor Yellow
        Write-Host "  Items: $itemCount / 100000" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ Could not verify database (might still be initializing)" -ForegroundColor Yellow
}

Write-Host ""

# Create results directory
if (-not (Test-Path "jmeter\results")) {
    New-Item -ItemType Directory -Path "jmeter\results" -Force | Out-Null
    Write-Host "✓ Created results directory" -ForegroundColor Green
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Setup Complete!                          ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Yellow
Write-Host "  • Grafana:    http://localhost:3000 (admin/admin)"
Write-Host "  • Prometheus: http://localhost:9090"
Write-Host "  • InfluxDB:   http://localhost:8086 (admin/adminadmin)"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run benchmarks with: .\run-benchmark.ps1 [variant] [scenario]"
Write-Host "     Examples:"
Write-Host "       .\run-benchmark.ps1 a all       # All scenarios on Variant A"
Write-Host "       .\run-benchmark.ps1 c 1-read-heavy  # Single scenario on Variant C"
Write-Host ""
Write-Host "  2. View monitoring dashboards in Grafana"
Write-Host ""
Write-Host "  3. Analyze results in jmeter\results\"
Write-Host ""

