# REST Performance Benchmark Runner - PowerShell
# Usage: .\run-benchmark.ps1 [variant] [scenario]
# Example: .\run-benchmark.ps1 a all
#          .\run-benchmark.ps1 c 1-read-heavy

param(
    [Parameter(Position=0)]
    [ValidateSet('a', 'A', 'c', 'C', 'd', 'D')]
    [string]$Variant = 'a',
    
    [Parameter(Position=1)]
    [string]$Scenario = 'all'
)

# Configuration
$Variant = $Variant.ToLower()
$ResultsDir = "jmeter\results"
$WaitTime = 30

# Validate variant
switch ($Variant) {
    'a' {
        $VariantName = "variant-a"
        $Port = 8081
        $Profile = "variant-a"
    }
    'c' {
        $VariantName = "variant-c"
        $Port = 8082
        $Profile = "variant-c"
    }
    'd' {
        $VariantName = "variant-d"
        $Port = 8083
        $Profile = "variant-d"
    }
    default {
        Write-Host "Error: Invalid variant. Use 'a', 'c', or 'd'" -ForegroundColor Red
        exit 1
    }
}

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  REST Performance Benchmark Runner        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Variant: $VariantName (Port: $Port)" -ForegroundColor Yellow
Write-Host "Scenario: $Scenario" -ForegroundColor Yellow
Write-Host ""

# Create results directory
if (-not (Test-Path $ResultsDir)) {
    New-Item -ItemType Directory -Path $ResultsDir -Force | Out-Null
}

# Function to stop variant
function Stop-Variant {
    Write-Host "Stopping $VariantName..." -ForegroundColor Yellow
    Push-Location docker
    docker compose --profile $Profile down
    Pop-Location
}

# Function to start variant
function Start-Variant {
    Write-Host "Starting $VariantName..." -ForegroundColor Yellow
    Push-Location docker
    docker compose --profile $Profile up -d
    Pop-Location
    
    Write-Host "Waiting ${WaitTime}s for startup..." -ForegroundColor Yellow
    Start-Sleep -Seconds $WaitTime
    
    # Health check
    Write-Host "Checking health..." -ForegroundColor Yellow
    try {
        # Utiliser UriBuilder pour éviter les problèmes avec le caractère &
        $uriBuilder = New-Object System.UriBuilder
        $uriBuilder.Scheme = "http"
        $uriBuilder.Host = "localhost"
        $uriBuilder.Port = $Port
        $uriBuilder.Path = "/categories"
        $uriBuilder.Query = "page=0&size=1"
        $uri = $uriBuilder.Uri.ToString()
        
        $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ $VariantName is healthy" -ForegroundColor Green
        } else {
            Write-Host "✗ $VariantName health check failed" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "✗ $VariantName health check failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to run JMeter scenario
function Run-JMeter {
    param(
        [string]$ScenarioFile,
        [string]$ScenarioName
    )
    
    $OutputFile = "$ResultsDir\$ScenarioName-$VariantName.jtl"
    $ReportDir = "$ResultsDir\$ScenarioName-$VariantName-report"
    
    # Clean up existing results
    if (Test-Path $OutputFile) { Remove-Item $OutputFile -Force }
    if (Test-Path $ReportDir) { Remove-Item $ReportDir -Recurse -Force }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
    Write-Host "Running: $ScenarioName" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
    
    # Check if jmeter is in PATH
    $jmeterCmd = Get-Command jmeter -ErrorAction SilentlyContinue
    if (-not $jmeterCmd) {
        Write-Host "Error: JMeter not found in PATH" -ForegroundColor Red
        Write-Host "Please add JMeter bin directory to PATH or use full path" -ForegroundColor Yellow
        exit 1
    }
    
    $jmeterArgs = @(
        "-n",
        "-t", "jmeter\scenarios\$ScenarioFile",
        "-Jtarget.host=localhost",
        "-Jtarget.port=$Port",
        "-l", $OutputFile,
        "-e",
        "-o", $ReportDir
    )
    
    & jmeter $jmeterArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $ScenarioName completed successfully" -ForegroundColor Green
        Write-Host "  Results: $OutputFile" -ForegroundColor Yellow
        Write-Host "  Report:  $ReportDir\index.html" -ForegroundColor Yellow
    } else {
        Write-Host "✗ $ScenarioName failed" -ForegroundColor Red
    }
}

# Function to export metrics
function Export-Metrics {
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $MetricsFile = "$ResultsDir\metrics-$VariantName-$Timestamp.txt"
    
    Write-Host ""
    Write-Host "Exporting Prometheus metrics..." -ForegroundColor Yellow
    
    try {
        if ($Variant -eq 'a') {
            $metrics = Invoke-WebRequest -Uri "http://localhost:9091/metrics" -UseBasicParsing
        } else {
            $metrics = Invoke-WebRequest -Uri "http://localhost:$Port/actuator/prometheus" -UseBasicParsing
        }
        $metrics.Content | Out-File -FilePath $MetricsFile -Encoding UTF8
        Write-Host "✓ Metrics exported to: $MetricsFile" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not export metrics: $_" -ForegroundColor Yellow
    }
}

# Trap to ensure cleanup
$ErrorActionPreference = "Stop"
trap {
    Stop-Variant
    break
}

# Stop any running variants
Write-Host "Cleaning up any running variants..." -ForegroundColor Yellow
Push-Location docker
docker compose --profile variant-a down 2>$null
docker compose --profile variant-c down 2>$null
docker compose --profile variant-d down 2>$null
Pop-Location

# Start the variant
Start-Variant

# Run scenarios
if ($Scenario -eq "all") {
    $scenarios = @(
        "1-read-heavy.jmx",
        "2-join-filter.jmx",
        "3-mixed-writes.jmx",
        "4-heavy-body.jmx"
    )
    
    foreach ($scenarioFile in $scenarios) {
        $scenarioName = [System.IO.Path]::GetFileNameWithoutExtension($scenarioFile)
        Run-JMeter -ScenarioFile $scenarioFile -ScenarioName $scenarioName
        Write-Host "Cooldown period (60s)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
    }
} else {
    $scenarioFile = "$Scenario.jmx"
    $scenarioName = $Scenario
    if (Test-Path "jmeter\scenarios\$scenarioFile") {
        Run-JMeter -ScenarioFile $scenarioFile -ScenarioName $scenarioName
    } else {
        Write-Host "Error: Scenario file not found: jmeter\scenarios\$scenarioFile" -ForegroundColor Red
        exit 1
    }
}

# Export metrics
Export-Metrics

# Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Benchmark Completed Successfully!        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Results location: $ResultsDir\" -ForegroundColor Yellow
Write-Host "View reports: Open HTML files in browser" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review JMeter HTML reports"
Write-Host "  2. Check Grafana dashboards: http://localhost:3000"
Write-Host "  3. Compare metrics across variants"
Write-Host ""

# Stop variant
Stop-Variant

