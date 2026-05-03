<#
.SYNOPSIS
Checks whether specified Windows services are running.
#>

[CmdletBinding()]
param(
    [string[]]$ServiceName = @("WinRM", "Spooler", "W32Time", "BITS", "EventLog"),
    [string]$OutputPath
)

try {
    $results = foreach ($service in $ServiceName) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue

        if ($null -eq $svc) {
            [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                ServiceName  = $service
                DisplayName  = "Not Found"
                Status       = "Not Found"
                StartType    = "Unknown"
                Timestamp    = Get-Date
            }
        }
        else {
            $cimSvc = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$service'"
            [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                ServiceName  = $svc.Name
                DisplayName  = $svc.DisplayName
                Status       = $svc.Status
                StartType    = $cimSvc.StartMode
                Timestamp    = Get-Date
            }
        }
    }

    $results | Format-Table -AutoSize

    if ($OutputPath) {
        $results | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Service report exported to $OutputPath"
    }
}
catch {
    Write-Error "Failed to check service status. $($_.Exception.Message)"
}
