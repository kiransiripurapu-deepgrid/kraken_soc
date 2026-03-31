#!/usr/bin/env powershell
# Monitor synthesis completion without blocking
param(
    [int]$CheckIntervalSeconds = 30,
    [int]$MaxWaitMinutes = 120,
    [int]$MaxAutoRestarts = 2,
    [int]$DriverEventLookbackMinutes = 180
)

$synth_dir = "C:\Users\kiran\fpga_project\mini_kraken\scripts\kraken_func\kraken_func.runs\synth_1"
$utilization_report = Join-Path $synth_dir "kraken_soc_func_utilization_synth.rpt"
$dcp_candidates = @(
    (Join-Path $synth_dir "kraken_soc_func_synth.dcp"),
    (Join-Path $synth_dir "kraken_soc_func.dcp")
)
$running_marker = Join-Path $synth_dir "__synthesis_is_running__"
$runme_bat = Join-Path $synth_dir "runme.bat"
$run_log = Join-Path $synth_dir "runme.log"
$monitor_log = Join-Path $synth_dir "synth_monitor.log"

$start_time = Get-Date
$timeout = New-TimeSpan -Minutes $MaxWaitMinutes
$restart_count = 0

function Write-MonitorLog {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    Add-Content -Path $monitor_log -Value $line
}

function Get-RecentDriverWatchdogEvents {
    param([datetime]$Since)

    try {
        $events = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Since} -ErrorAction SilentlyContinue |
            Where-Object {
                $_.ProviderName -eq 'Windows Error Reporting' -and
                $_.Message -match 'LiveKernelEvent' -and
                $_.Message -match 'WATCHDOG'
            } |
            Select-Object -First 5 TimeCreated, Id, ProviderName

        return $events
    }
    catch {
        return @()
    }
}

function Test-SynthesisComplete {
    $dcp_exists = $null -ne (Get-ExistingDcp)
    return (Test-Path $utilization_report) -and $dcp_exists
}

function Get-ExistingDcp {
    foreach ($cand in $dcp_candidates) {
        if (Test-Path $cand) {
            return $cand
        }
    }
    return $null
}

function Start-SynthesisRun {
    if (-not (Test-Path $runme_bat)) {
        throw "Cannot restart synthesis because run script is missing: $runme_bat"
    }

    Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "runme.bat" -WorkingDirectory $synth_dir -WindowStyle Hidden | Out-Null
}

if (-not (Test-Path $monitor_log)) {
    New-Item -Path $monitor_log -ItemType File -Force | Out-Null
}

Write-MonitorLog "Synthesis monitor started"
Write-MonitorLog "Monitoring report: $utilization_report"
Write-MonitorLog "Monitoring checkpoint candidates: $($dcp_candidates -join ', ')"
Write-MonitorLog "Auto restarts allowed: $MaxAutoRestarts"

do {
    $elapsed = (Get-Date) - $start_time
    $now = Get-Date
    $lookback_start = $now.AddMinutes(-1 * [Math]::Abs($DriverEventLookbackMinutes))
    
    # Check if Vivado process is still running
    $vivado_running = $null -ne (Get-Process vivado -ErrorAction SilentlyContinue | Select-Object -First 1)
    
    # Check for output files
    $util_exists = Test-Path $utilization_report
    $existing_dcp = Get-ExistingDcp
    $dcp_exists = $null -ne $existing_dcp
    $running = Test-Path $running_marker
    
    # Display status
    $status = "RUNNING"
    if (-not $vivado_running) { $status = "IDLE" }
    if ($util_exists) { $status = "COMPLETE" }
    
    Write-MonitorLog "Vivado=$status | Elapsed=$([int]$elapsed.TotalSeconds)s | Report=$util_exists | DCP=$dcp_exists | Marker=$running | Restarts=$restart_count"
    
    # Exit conditions
    if (Test-SynthesisComplete) {
        Write-MonitorLog "Synthesis completed successfully"
        Write-MonitorLog "Utilization report size: $((Get-Item $utilization_report).Length) bytes"
        Write-MonitorLog "Design checkpoint: $existing_dcp"
        Write-MonitorLog "Design checkpoint size: $((Get-Item $existing_dcp).Length) bytes"
        exit 0
    }
    
    if ($elapsed -gt $timeout) {
        Write-MonitorLog "Timeout after $MaxWaitMinutes minutes"
        exit 1
    }
    
    if (-not $vivado_running -and -not $util_exists) {
        $watchdog_events = Get-RecentDriverWatchdogEvents -Since $lookback_start
        if ($watchdog_events.Count -gt 0) {
            $event_times = ($watchdog_events | ForEach-Object { $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss") }) -join ", "
            Write-MonitorLog "Detected Windows LiveKernelEvent WATCHDOG entries in lookback window: $event_times"
        }

        if ($running -and $restart_count -lt $MaxAutoRestarts) {
            $restart_count++
            Write-MonitorLog "Vivado exited unexpectedly while synthesis marker is present; attempting auto-restart $restart_count/$MaxAutoRestarts"

            try {
                Start-SynthesisRun
                Start-Sleep -Seconds 10
                continue
            }
            catch {
                Write-MonitorLog "Auto-restart failed: $($_.Exception.Message)"
                exit 1
            }
        }

        if (Test-Path $run_log) {
            $tail = Get-Content -Path $run_log -Tail 10 -ErrorAction SilentlyContinue
            if ($tail) {
                Write-MonitorLog "Last runme.log lines:"
                $tail | ForEach-Object { Write-MonitorLog "  $_" }
            }
        }

        Write-MonitorLog "Vivado exited without generating synthesis outputs"
        exit 1
    }
    
    Start-Sleep -Seconds $CheckIntervalSeconds
} while ($true)
