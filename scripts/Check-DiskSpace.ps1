<#
.SYNOPSIS
Checks local disk space and flags drives below a free space threshold.
#>

[CmdletBinding()]
param(
    [int]$MinimumFreePercent = 15,
    [string]$OutputPath
)

try {
    $results = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" | ForEach-Object {
        $sizeGb = [math]::Round($_.Size / 1GB, 2)
        $freeGb = [math]::Round($_.FreeSpace / 1GB, 2)
        $freePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)

        [PSCustomObject]@{
            ComputerName       = $env:COMPUTERNAME
            Drive              = $_.DeviceID
            SizeGB             = $sizeGb
            FreeGB             = $freeGb
            FreePercent        = $freePercent
            MinimumFreePercent = $MinimumFreePercent
            Status             = if ($freePercent -lt $MinimumFreePercent) { "Warning" } else { "Healthy" }
            Timestamp          = Get-Date
        }
    }

    $results | Format-Table -AutoSize

    if ($OutputPath) {
        $results | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Disk report exported to $OutputPath"
    }
}
catch {
    Write-Error "Failed to check disk space. $($_.Exception.Message)"
}
