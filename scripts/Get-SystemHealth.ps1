<#
.SYNOPSIS
Generates a basic system health report for the local computer.

.DESCRIPTION
Collects operating system, uptime, CPU, memory, disk, and network information.
#>

[CmdletBinding()]
param(
    [string]$OutputPath
)

function Get-UptimeDays {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    return [math]::Round(((Get-Date) - $lastBoot).TotalDays, 2)
}

try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $memoryTotalGb = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
    $memoryFreeGb = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $memoryUsedPercent = [math]::Round((($memoryTotalGb - $memoryFreeGb) / $memoryTotalGb) * 100, 2)

    $report = [PSCustomObject]@{
        ComputerName      = $env:COMPUTERNAME
        UserName          = $env:USERNAME
        OSName            = $os.Caption
        OSVersion         = $os.Version
        UptimeDays        = Get-UptimeDays
        CPUUsagePercent   = $cpuLoad
        MemoryTotalGB     = $memoryTotalGb
        MemoryFreeGB      = $memoryFreeGb
        MemoryUsedPercent = $memoryUsedPercent
        Timestamp         = Get-Date
    }

    $report | Format-List

    if ($OutputPath) {
        $report | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Report exported to $OutputPath"
    }
}
catch {
    Write-Error "Failed to generate system health report. $($_.Exception.Message)"
}
